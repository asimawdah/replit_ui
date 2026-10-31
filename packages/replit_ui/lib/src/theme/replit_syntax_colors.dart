import 'package:material_ui/material_ui.dart';

/// Syntax token colors for the code block.
///
/// Eight roles cover what the built-in highlighter distinguishes; plain
/// code takes the ambient ink (`ReplitColors.onSurface`), so no role exists
/// for it. Unlike the ink ramp these are resolved, opaque colors — a hue
/// at an alpha would drift on the code block's washed ground.
///
@immutable
class ReplitSyntaxColors {
  const ReplitSyntaxColors({
    required this.keyword,
    required this.type,
    required this.function,
    required this.string,
    required this.number,
    required this.comment,
    required this.meta,
    required this.punctuation,
  });

  /// Reserved words and control flow — `class`, `if`, `return`.
  final Color keyword;

  /// Type names: uppercase identifiers and language primitives.
  final Color type;

  /// A call or declaration site — an identifier ahead of its `(`.
  final Color function;

  /// String literals, quotes included.
  final Color string;

  /// Numeric literals.
  final Color number;

  /// Comments.
  final Color comment;

  /// Annotations, decorators and shell variables — `@override`, `$HOME`.
  final Color meta;

  /// Brackets, separators and operators.
  final Color punctuation;

  static const ReplitSyntaxColors light = ReplitSyntaxColors(
    keyword: Color(0xFFC63200),
    type: Color(0xFF767270),
    function: Color(0xFF312E2E),
    string: Color(0xFF625E5C),
    number: Color(0xFFA82A00),
    comment: Color(0xFF767270),
    meta: Color(0xFF625E5C),
    punctuation: Color(0xFF312E2E),
  );

  static const ReplitSyntaxColors dark = ReplitSyntaxColors(
    keyword: Color(0xFFFF764D),
    type: Color(0xFFFFB199),
    function: Color(0xFFDBD4CF),
    string: Color(0xFFC5C5C5),
    number: Color(0xFFEDEDED),
    comment: Color(0xFFC5C5C5),
    meta: Color(0xFFDBD4CF),
    punctuation: Color(0xFFDBD4CF),
  );

  ReplitSyntaxColors copyWith({
    Color? keyword,
    Color? type,
    Color? function,
    Color? string,
    Color? number,
    Color? comment,
    Color? meta,
    Color? punctuation,
  }) {
    return ReplitSyntaxColors(
      keyword: keyword ?? this.keyword,
      type: type ?? this.type,
      function: function ?? this.function,
      string: string ?? this.string,
      number: number ?? this.number,
      comment: comment ?? this.comment,
      meta: meta ?? this.meta,
      punctuation: punctuation ?? this.punctuation,
    );
  }

  ReplitSyntaxColors lerp(ReplitSyntaxColors? other, double t) {
    if (other == null) return this;
    return ReplitSyntaxColors(
      keyword: Color.lerp(keyword, other.keyword, t)!,
      type: Color.lerp(type, other.type, t)!,
      function: Color.lerp(function, other.function, t)!,
      string: Color.lerp(string, other.string, t)!,
      number: Color.lerp(number, other.number, t)!,
      comment: Color.lerp(comment, other.comment, t)!,
      meta: Color.lerp(meta, other.meta, t)!,
      punctuation: Color.lerp(punctuation, other.punctuation, t)!,
    );
  }
}
