import 'package:material_ui/material_ui.dart';

import '../theme/replit_syntax_colors.dart';

// The highlighting engine behind ReplitCodeBlock. The registry types are
// re-exported through replit_code_block.dart so hosts can add languages; the
// engine itself is not part of the public surface.
//
// The string-in / TextSpan-out shape follows serverpod's syntax_highlight,
// but where that package walks TextMate grammars loaded from assets (and so
// needs async setup), this one compiles a language's ordered rule table
// into a single alternated regex and colors matches in one synchronous
// pass. Rule order is precedence: at the same position the earlier rule's
// alternative wins, which is how a keyword inside a comment stays a
// comment.

/// The token classes the built-in highlighter distinguishes, each colored
/// by the matching [ReplitSyntaxColors] role. Anything no rule claims stays
/// plain ink.
enum ReplitSyntaxToken {
  /// Reserved words and control flow — `class`, `if`, `return`.
  keyword,

  /// Type names: uppercase identifiers and language primitives.
  type,

  /// A call or declaration site — an identifier ahead of its `(`.
  function,

  /// String literals, quotes included.
  string,

  /// Numeric literals.
  number,

  /// Comments.
  comment,

  /// Annotations, decorators and shell variables — `@override`, `$HOME`.
  meta,

  /// Brackets, separators and operators.
  punctuation,
}

/// One highlighting rule: every match of [pattern] reads as [token].
///
/// [pattern] is regex *source*, not a [RegExp] — the language joins its
/// rules into one alternation, so a pattern must not contain named groups
/// or numbered backreferences (plain `(…)` groups are fine).
@immutable
class ReplitSyntaxRule {
  const ReplitSyntaxRule(this.token, this.pattern);

  final ReplitSyntaxToken token;
  final String pattern;
}

/// A language the code block can highlight: an id, lookup aliases, and an
/// ordered rule table.
///
/// The built-ins cover the fences an assistant most often emits — Dart,
/// JSON, JavaScript/TypeScript, Python, shell, YAML, HTML, CSS and SQL.
/// Hosts extend the set:
///
/// ```dart
/// ReplitCodeLanguage.register(
///   const ReplitCodeLanguage(
///     id: 'lisp',
///     rules: [ReplitSyntaxRule(ReplitSyntaxToken.comment, r';[^\n]*')],
///   ),
/// );
/// ```
///
/// Rules earlier in the table take precedence, so comments and strings
/// come first.
@immutable
class ReplitCodeLanguage {
  const ReplitCodeLanguage({
    required this.id,
    this.aliases = const [],
    required this.rules,
    this.caseSensitive = true,
  });

  /// Canonical name, lowercase by convention — what a fence info string
  /// usually carries.
  final String id;

  /// Other names [find] resolves, e.g. `'py'` for `'python'`.
  final List<String> aliases;

  /// Ordered by precedence.
  final List<ReplitSyntaxRule> rules;

  /// False compiles the whole table case-insensitively — for languages
  /// like SQL whose keywords come in either case (Dart regexes have no
  /// inline `(?i)`).
  final bool caseSensitive;

  static final Map<String, ReplitCodeLanguage> _registry = () {
    final map = <String, ReplitCodeLanguage>{};
    for (final language in [
      dart,
      json,
      javascript,
      python,
      bash,
      yaml,
      html,
      css,
      sql,
      plain,
    ]) {
      _add(map, language);
    }
    return map;
  }();

  static void _add(
    Map<String, ReplitCodeLanguage> map,
    ReplitCodeLanguage language,
  ) {
    map[language.id.toLowerCase()] = language;
    for (final alias in language.aliases) {
      map[alias.toLowerCase()] = language;
    }
  }

  /// Makes [language] resolvable through [find], replacing any earlier
  /// registration of the same id or alias.
  static void register(ReplitCodeLanguage language) {
    // Drop every key still resolving to the replaced language: an alias
    // the replacement doesn't relist must not keep serving the old
    // instance, which shares the new one's compiled-pattern slot.
    final id = language.id.toLowerCase();
    _registry.removeWhere((_, earlier) => earlier.id.toLowerCase() == id);
    _add(_registry, language);
    ReplitSyntaxHighlighter._invalidate(language.id);
  }

  /// The language for [id] — or an alias, case-insensitively — and null
  /// when unknown: the caller renders plain, never an error.
  static ReplitCodeLanguage? find(String? id) {
    if (id == null) return null;
    return _registry[id.trim().toLowerCase()];
  }

  /// No rules: source renders in plain ink. The explicit registration lets
  /// `'text'` fences resolve rather than fall through as unknown (the
  /// rendering is the same either way).
  static const ReplitCodeLanguage plain = ReplitCodeLanguage(
    id: 'plain',
    aliases: ['text', 'txt'],
    rules: [],
  );

  static const ReplitCodeLanguage dart = ReplitCodeLanguage(
    id: 'dart',
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'//[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"r?'''[\s\S]*?'''"),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'r?"""[\s\S]*?"""'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"r?'(?:\\.|[^'\\\n])*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'r?"(?:\\.|[^"\\\n])*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'@[A-Za-z_][A-Za-z0-9_]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'\b0[xX][0-9a-fA-F_]+\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:abstract|as|assert|async|await|base|break|case|catch|class|'
        r'const|continue|covariant|default|deferred|do|dynamic|else|enum|'
        r'export|extends|extension|external|factory|false|final|finally|for|'
        r'get|hide|if|implements|import|in|interface|is|late|library|mixin|'
        r'new|null|on|operator|part|required|rethrow|return|sealed|set|show|'
        r'static|super|switch|sync|this|throw|true|try|typedef|var|void|when|'
        r'while|with|yield)\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'\b(?:int|double|num|bool)\b'),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_]*\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.function,
        r'\b[a-z_][A-Za-z0-9_]*(?=\s*\()',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|^~?]+',
      ),
    ],
  );

  static const ReplitCodeLanguage json = ReplitCodeLanguage(
    id: 'json',
    aliases: ['jsonc'],
    rules: [
      // Line comments aren't JSON, but assistants emit them anyway (and
      // jsonc makes them official).
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'//[^\n]*'),
      // A key: a string ahead of its colon — must outrank the value rule.
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'"(?:\\.|[^"\\])*"(?=\s*:)'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'"(?:\\.|[^"\\])*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.keyword, r'\b(?:true|false|null)\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[{}\[\],:]+'),
    ],
  );

  /// One C-family table serves both: TypeScript is close enough to
  /// JavaScript at highlighting depth that separate tables would only
  /// drift.
  static const ReplitCodeLanguage javascript = ReplitCodeLanguage(
    id: 'javascript',
    aliases: ['js', 'jsx', 'typescript', 'ts', 'tsx'],
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'//[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'`[\s\S]*?`'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"'(?:\\.|[^'\\\n])*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'"(?:\\.|[^"\\\n])*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'@[A-Za-z_$][A-Za-z0-9_$]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'\b0[xX][0-9a-fA-F_]+n?\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?n?\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:abstract|as|async|await|break|case|catch|class|const|continue|'
        r'debugger|declare|default|delete|do|else|enum|export|extends|false|'
        r'finally|for|from|function|get|if|implements|import|in|infer|'
        r'instanceof|interface|is|keyof|let|namespace|new|null|of|override|'
        r'private|protected|public|readonly|return|satisfies|set|static|'
        r'super|switch|this|throw|true|try|type|typeof|undefined|var|void|'
        r'while|with|yield)\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.type,
        r'\b(?:any|bigint|boolean|never|number|object|string|symbol|'
        r'unknown)\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_$]*\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.function,
        r'\b[A-Za-z_$][A-Za-z0-9_$]*(?=\s*\()',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|^~?]+',
      ),
    ],
  );

  static const ReplitCodeLanguage python = ReplitCodeLanguage(
    id: 'python',
    aliases: ['py'],
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'#[^\n]*'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.string,
        r"(?:[rbfuRBFU]{1,2})?'''[\s\S]*?'''",
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.string,
        r'(?:[rbfuRBFU]{1,2})?"""[\s\S]*?"""',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.string,
        r"(?:[rbfuRBFU]{1,2})?'(?:\\.|[^'\\\n])*'",
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.string,
        r'(?:[rbfuRBFU]{1,2})?"(?:\\.|[^"\\\n])*"',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'@[A-Za-z_][A-Za-z0-9_.]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'\b0[xXoObB][0-9a-fA-F_]+\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:and|as|assert|async|await|break|case|class|continue|def|del|'
        r'elif|else|except|False|finally|for|from|global|if|import|in|is|'
        r'lambda|match|None|nonlocal|not|or|pass|raise|return|self|True|try|'
        r'while|with|yield)\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.type,
        r'\b(?:bool|bytes|dict|float|frozenset|int|list|object|set|str|'
        r'tuple)\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_]*\b'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.function,
        r'\b[a-z_][A-Za-z0-9_]*(?=\s*\()',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|@^~]+',
      ),
    ],
  );

  static const ReplitCodeLanguage bash = ReplitCodeLanguage(
    id: 'bash',
    aliases: ['sh', 'shell', 'zsh'],
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'#[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"'[^']*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'"(?:\\.|[^"\\])*"'),
      // Variables and expansions get the meta ink — the shell's one real
      // syntax.
      ReplitSyntaxRule(
        ReplitSyntaxToken.meta,
        r'\$\{[^}\n]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\$[?$!#@*0-9-]',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:alias|break|case|cd|continue|declare|do|done|echo|elif|else|'
        r'esac|exit|export|fi|for|function|if|in|local|read|return|select|'
        r'set|shift|source|then|unset|until|while)\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'\b\d+\b'),
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[|&;<>(){}\[\]=]+'),
    ],
  );

  static const ReplitCodeLanguage yaml = ReplitCodeLanguage(
    id: 'yaml',
    aliases: ['yml'],
    rules: [
      // Line-start or whitespace before the #, so a fragment mid-word
      // (an URL) doesn't comment the rest of the line. The consumed
      // space is invisible in the comment ink.
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'(?:^|[ \t])#[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'^(?:---|\.\.\.)'),
      // Quoted and plain keys, ahead of the string and keyword rules so
      // `on:` (GitHub Actions) reads as a key, not a boolean.
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'"(?:\\.|[^"\\\n])*"(?=\s*:)'),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r"'[^'\n]*'(?=\s*:)"),
      ReplitSyntaxRule(
        ReplitSyntaxToken.type,
        r'[A-Za-z_][\w./$-]*(?=:(?:[ \t]|$))',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'"(?:\\.|[^"\\\n])*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"'[^'\n]*'"),
      // Anchors, aliases and tags.
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'[&*][\w-]+|!!?[\w/-]+'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:true|True|TRUE|false|False|FALSE|null|Null|NULL|yes|Yes|YES|'
        r'no|No|NO|on|On|ON|off|Off|OFF)\b|~',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[\[\]{}:,>|-]+'),
    ],
  );

  static const ReplitCodeLanguage html = ReplitCodeLanguage(
    id: 'html',
    aliases: ['xml'],
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'<!--[\s\S]*?-->'),
      // Doctype, CDATA and processing instructions — CDATA spelled out
      // first, since its body may hold the > that ends the generic <!…>.
      ReplitSyntaxRule(
        ReplitSyntaxToken.meta,
        r'<!\[CDATA\[[\s\S]*?\]\]>|<![^>]*>|<\?[\s\S]*?\?>',
      ),
      // Attribute values only — anchored on the =, so quoted prose in
      // text content stays plain.
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'=\s*"[^"]*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"=\s*'[^']*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.keyword, r'</?[A-Za-z][\w-]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'[A-Za-z-]+(?==)'),
      // Entities.
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'&[a-zA-Z]+;|&#\d+;'),
      // One angle at a time: a + run would swallow the < opening a
      // comment or CDATA section straight after a closing >.
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[<>/=]'),
    ],
  );

  static const ReplitCodeLanguage css = ReplitCodeLanguage(
    id: 'css',
    aliases: ['scss', 'less'],
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      // Line-start or whitespace before the // — as with YAML's # — so an
      // unquoted url(http://…) doesn't comment out the rest of the line.
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'(?:^|[ \t])//[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r'"(?:\\.|[^"\\\n])*"'),
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"'(?:\\.|[^'\\\n])*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.keyword, r'@[\w-]+'),
      ReplitSyntaxRule(ReplitSyntaxToken.keyword, r'!important\b'),
      // Hex colors before the class/id selector rule — at the same `#`
      // they win, and `#bada55` is a color even when it spells a word.
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'#[0-9a-fA-F]{3,8}\b'),
      ReplitSyntaxRule(ReplitSyntaxToken.function, r'[.#][A-Za-z_][\w-]*'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.number,
        r'\b\d+(?:\.\d+)?(?:px|em|rem|vh|vw|vmin|vmax|ms|s|fr|deg|ch|pt|%)?',
      ),
      // Property names — also custom properties (`--ink`).
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'[-a-zA-Z][-\w]*(?=\s*:)'),
      // Value functions: rgb(), var(), calc().
      ReplitSyntaxRule(ReplitSyntaxToken.function, r'[a-zA-Z-]+(?=\()'),
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[{}();:,>+~*]+'),
    ],
  );

  static const ReplitCodeLanguage sql = ReplitCodeLanguage(
    id: 'sql',
    aliases: ['mysql', 'postgres', 'postgresql', 'sqlite'],
    // SQL keywords come uppercase and lowercase; one flag beats listing
    // both cases through the whole table.
    caseSensitive: false,
    rules: [
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'--[^\n]*'),
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      ReplitSyntaxRule(ReplitSyntaxToken.comment, r'#[^\n]*'),
      // Doubled '' is the escape; " and ` quote identifiers.
      ReplitSyntaxRule(ReplitSyntaxToken.string, r"'(?:''|[^'\n])*'"),
      ReplitSyntaxRule(ReplitSyntaxToken.type, r'"[^"\n]*"|`[^`\n]*`'),
      // Bind parameters and session variables.
      ReplitSyntaxRule(ReplitSyntaxToken.meta, r'@\w+|:\w+|\$\d+'),
      ReplitSyntaxRule(
        ReplitSyntaxToken.keyword,
        r'\b(?:select|from|where|insert|into|values|update|set|delete|create|'
        r'table|view|index|drop|alter|add|column|primary|key|foreign|'
        r'references|constraint|unique|not|null|default|and|or|in|is|like|'
        r'between|exists|case|when|then|else|end|join|inner|left|right|full|'
        r'outer|cross|on|as|group|by|having|order|asc|desc|limit|offset|'
        r'union|all|distinct|with|returning|begin|commit|rollback|'
        r'transaction|if|replace|temporary|cascade|check|database|schema|'
        r'grant|revoke|true|false)\b',
      ),
      ReplitSyntaxRule(
        ReplitSyntaxToken.type,
        r'\b(?:int|integer|bigint|smallint|serial|decimal|numeric|real|float|'
        r'double|precision|boolean|bool|char|varchar|text|date|time|'
        r'timestamp|timestamptz|interval|blob|bytea|json|jsonb|uuid)\b',
      ),
      ReplitSyntaxRule(ReplitSyntaxToken.number, r'\b\d+(?:\.\d+)?\b'),
      ReplitSyntaxRule(ReplitSyntaxToken.function, r'[a-z_]\w*(?=\s*\()'),
      ReplitSyntaxRule(ReplitSyntaxToken.punctuation, r'[();,.=<>!:+*/-]+'),
    ],
  );
}

/// Colors source through a language's rule table — synchronously: no
/// assets, no setup call, safe to run in `build`.
abstract final class ReplitSyntaxHighlighter {
  /// Compiled alternations, keyed by language id. [ReplitCodeLanguage.register]
  /// invalidates its id here so a replacement table takes effect.
  static final Map<String, RegExp> _compiled = {};

  static void _invalidate(String id) => _compiled.remove(id);

  static RegExp _patternFor(ReplitCodeLanguage language) {
    return _compiled.putIfAbsent(language.id, () {
      // Each rule in its own named group: whichever group a match filled
      // names the rule that won, without counting the rule's internal
      // groups.
      final source = [
        for (var i = 0; i < language.rules.length; i++)
          '(?<g$i>${language.rules[i].pattern})',
      ].join('|');
      return RegExp(
        source,
        multiLine: true,
        caseSensitive: language.caseSensitive,
      );
    });
  }

  /// [code] as a single [TextSpan]: plain stretches in [style], each rule
  /// match in the [colors] role of its token. Null or empty [language]
  /// renders the whole string plain.
  static TextSpan highlight(
    String code, {
    ReplitCodeLanguage? language,
    required TextStyle style,
    required ReplitSyntaxColors colors,
  }) {
    if (language == null || language.rules.isEmpty || code.isEmpty) {
      return TextSpan(text: code, style: style);
    }

    final rules = language.rules;
    final pattern = _patternFor(language);
    final children = <TextSpan>[];
    var position = 0;

    for (final match in pattern.allMatches(code)) {
      if (match.end == match.start) continue;
      if (match.start > position) {
        children.add(TextSpan(text: code.substring(position, match.start)));
      }

      ReplitSyntaxToken? token;
      for (var i = 0; i < rules.length; i++) {
        if (match.namedGroup('g$i') != null) {
          token = rules[i].token;
          break;
        }
      }

      children.add(
        TextSpan(
          text: code.substring(match.start, match.end),
          style: token == null
              ? null
              : TextStyle(color: _colorFor(token, colors)),
        ),
      );
      position = match.end;
    }

    if (position < code.length) {
      children.add(TextSpan(text: code.substring(position)));
    }

    return TextSpan(style: style, children: children);
  }

  static Color _colorFor(ReplitSyntaxToken token, ReplitSyntaxColors colors) {
    return switch (token) {
      ReplitSyntaxToken.keyword => colors.keyword,
      ReplitSyntaxToken.type => colors.type,
      ReplitSyntaxToken.function => colors.function,
      ReplitSyntaxToken.string => colors.string,
      ReplitSyntaxToken.number => colors.number,
      ReplitSyntaxToken.comment => colors.comment,
      ReplitSyntaxToken.meta => colors.meta,
      ReplitSyntaxToken.punctuation => colors.punctuation,
    };
  }
}
