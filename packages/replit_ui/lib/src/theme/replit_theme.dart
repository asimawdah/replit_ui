import 'package:material_ui/material_ui.dart';

import '../styles/replit_chat_view_style.dart';
import '../styles/replit_code_block_style.dart';
import '../styles/replit_composer_style.dart';
import '../styles/replit_confirmation_style.dart';
import '../styles/replit_error_state_style.dart';
import '../styles/replit_markdown_style.dart';
import '../styles/replit_menu_style.dart';
import '../styles/replit_message_actions_style.dart';
import '../styles/replit_message_style.dart';
import '../styles/replit_pill_style.dart';
import '../styles/replit_suggestion_style.dart';
import '../styles/replit_thread_list_style.dart';
import '../styles/replit_toast_style.dart';
import '../styles/replit_tool_style.dart';
import 'replit_colors.dart';
import 'replit_syntax_colors.dart';
import 'replit_typography.dart';

/// The replit_ui design tokens — colors and typography — installed as a
/// [ThemeExtension]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [ReplitTheme.light()]),
///   darkTheme: ThemeData(
///     brightness: Brightness.dark,
///     extensions: [ReplitTheme.dark()],
///   ),
/// )
/// ```
///
/// Components read tokens via [ReplitThemeContext] (`context.replitTheme`,
/// `context.replitColors`, …). When no [ReplitTheme] is installed, a preset
/// matching the ambient [ThemeData.brightness] is used, so replit_ui works
/// with zero host setup.
///
/// Beyond the tokens, the theme can carry component styles — app-wide
/// defaults for a widget family's look ([menuStyle], [markdownStyle], …).
/// A widget's own style object wins over the theme's, field by field, and
/// the tokens sit beneath both.
///
/// Spacing and corner radii are not tokens: following Material's structure,
/// each component bakes its own metrics from the design file and exposes
/// per-widget overrides (`padding:`, `borderRadius:`) where hosts retheme.
class ReplitTheme extends ThemeExtension<ReplitTheme> {
  const ReplitTheme({
    required this.colors,
    this.typography = ReplitTypography.standard,
    this.syntax,
    this.composerStyle,
    this.messageStyle,
    this.menuStyle,
    this.markdownStyle,
    this.codeBlockStyle,
    this.confirmationStyle,
    this.errorStateStyle,
    this.messageActionsStyle,
    this.pillStyle,
    this.suggestionStyle,
    this.threadListStyle,
    this.toastStyle,
    this.toolStyle,
    this.chatViewStyle,
  });

  /// Light preset.
  factory ReplitTheme.light() =>
      const ReplitTheme(colors: ReplitColors.light, syntax: ReplitSyntaxColors.light);

  /// Dark preset.
  factory ReplitTheme.dark() =>
      const ReplitTheme(colors: ReplitColors.dark, syntax: ReplitSyntaxColors.dark);

  final ReplitColors colors;

  /// The type scale — [ReplitTypography.standard] unless the host set one.
  final ReplitTypography typography;

  /// Syntax token colors for code blocks. Null resolves to the preset
  /// matching the ambient brightness — unlike [typography], the right
  /// default depends on which way the theme leans, which a constructor
  /// default can't see.
  final ReplitSyntaxColors? syntax;

  /// App-wide default for every `ReplitComposer`.
  final ReplitComposerStyle? composerStyle;

  /// App-wide default for every `ReplitMessage` — threads included.
  final ReplitMessageStyle? messageStyle;

  /// App-wide default for every `ReplitMenu` and `ReplitModelSelector`.
  final ReplitMenuStyle? menuStyle;

  /// App-wide default for every `ReplitMarkdown` — assistant turns included.
  final ReplitMarkdownStyle? markdownStyle;

  /// App-wide default for every `ReplitCodeBlock` — markdown fences and
  /// code parts included.
  final ReplitCodeBlockStyle? codeBlockStyle;

  /// App-wide default for every `ReplitConfirmation` — confirmation parts
  /// in a thread included.
  final ReplitConfirmationStyle? confirmationStyle;

  /// App-wide default for every `ReplitErrorState` — failed turns included.
  final ReplitErrorStateStyle? errorStateStyle;

  /// App-wide default for every `ReplitMessageActions`.
  final ReplitMessageActionsStyle? messageActionsStyle;

  /// App-wide default for every `ReplitPill`.
  final ReplitPillStyle? pillStyle;

  /// App-wide default for every `ReplitSuggestion`.
  final ReplitSuggestionStyle? suggestionStyle;

  /// App-wide default for every `ReplitThreadList`.
  final ReplitThreadListStyle? threadListStyle;

  /// App-wide default for every `ReplitToast` — the ones `showReplitToast`
  /// floats included.
  final ReplitToastStyle? toastStyle;

  /// App-wide default for every `ReplitTool` — tool parts in a thread
  /// included.
  final ReplitToolStyle? toolStyle;

  /// App-wide default for `ReplitChatView.style` — the drop treatment's
  /// gradient, glyph and label.
  final ReplitChatViewStyle? chatViewStyle;

  @override
  ReplitTheme copyWith({
    ReplitColors? colors,
    ReplitTypography? typography,
    ReplitSyntaxColors? syntax,
    ReplitComposerStyle? composerStyle,
    ReplitMessageStyle? messageStyle,
    ReplitMenuStyle? menuStyle,
    ReplitMarkdownStyle? markdownStyle,
    ReplitCodeBlockStyle? codeBlockStyle,
    ReplitConfirmationStyle? confirmationStyle,
    ReplitErrorStateStyle? errorStateStyle,
    ReplitMessageActionsStyle? messageActionsStyle,
    ReplitPillStyle? pillStyle,
    ReplitSuggestionStyle? suggestionStyle,
    ReplitThreadListStyle? threadListStyle,
    ReplitToastStyle? toastStyle,
    ReplitToolStyle? toolStyle,
    ReplitChatViewStyle? chatViewStyle,
  }) {
    return ReplitTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      syntax: syntax ?? this.syntax,
      composerStyle: composerStyle ?? this.composerStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      menuStyle: menuStyle ?? this.menuStyle,
      markdownStyle: markdownStyle ?? this.markdownStyle,
      codeBlockStyle: codeBlockStyle ?? this.codeBlockStyle,
      confirmationStyle: confirmationStyle ?? this.confirmationStyle,
      errorStateStyle: errorStateStyle ?? this.errorStateStyle,
      messageActionsStyle: messageActionsStyle ?? this.messageActionsStyle,
      pillStyle: pillStyle ?? this.pillStyle,
      suggestionStyle: suggestionStyle ?? this.suggestionStyle,
      threadListStyle: threadListStyle ?? this.threadListStyle,
      toastStyle: toastStyle ?? this.toastStyle,
      toolStyle: toolStyle ?? this.toolStyle,
      chatViewStyle: chatViewStyle ?? this.chatViewStyle,
    );
  }

  @override
  ReplitTheme lerp(ThemeExtension<ReplitTheme>? other, double t) {
    if (other is! ReplitTheme) return this;
    return ReplitTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      syntax: syntax == null ? other.syntax : syntax!.lerp(other.syntax, t),
      composerStyle: composerStyle == null
          ? other.composerStyle
          : composerStyle!.lerp(other.composerStyle, t),
      messageStyle: messageStyle == null
          ? other.messageStyle
          : messageStyle!.lerp(other.messageStyle, t),
      menuStyle: menuStyle == null
          ? other.menuStyle
          : menuStyle!.lerp(other.menuStyle, t),
      markdownStyle: markdownStyle == null
          ? other.markdownStyle
          : markdownStyle!.lerp(other.markdownStyle, t),
      codeBlockStyle: codeBlockStyle == null
          ? other.codeBlockStyle
          : codeBlockStyle!.lerp(other.codeBlockStyle, t),
      confirmationStyle: confirmationStyle == null
          ? other.confirmationStyle
          : confirmationStyle!.lerp(other.confirmationStyle, t),
      errorStateStyle: errorStateStyle == null
          ? other.errorStateStyle
          : errorStateStyle!.lerp(other.errorStateStyle, t),
      messageActionsStyle: messageActionsStyle == null
          ? other.messageActionsStyle
          : messageActionsStyle!.lerp(other.messageActionsStyle, t),
      pillStyle: pillStyle == null
          ? other.pillStyle
          : pillStyle!.lerp(other.pillStyle, t),
      suggestionStyle: suggestionStyle == null
          ? other.suggestionStyle
          : suggestionStyle!.lerp(other.suggestionStyle, t),
      threadListStyle: threadListStyle == null
          ? other.threadListStyle
          : threadListStyle!.lerp(other.threadListStyle, t),
      toastStyle: toastStyle == null
          ? other.toastStyle
          : toastStyle!.lerp(other.toastStyle, t),
      toolStyle: toolStyle == null
          ? other.toolStyle
          : toolStyle!.lerp(other.toolStyle, t),
      chatViewStyle: chatViewStyle == null
          ? other.chatViewStyle
          : chatViewStyle!.lerp(other.chatViewStyle, t),
    );
  }
}

/// Token access for widgets: `context.replitColors.primary`,
/// `context.replitTypography.bodyLarge`, …
extension ReplitThemeContext on BuildContext {
  /// The installed [ReplitTheme], or a brightness-matched preset if none is.
  ReplitTheme get replitTheme {
    final theme = Theme.of(this);
    return theme.extension<ReplitTheme>() ??
        (theme.brightness == Brightness.dark
            ? ReplitTheme.dark()
            : ReplitTheme.light());
  }

  ReplitColors get replitColors => replitTheme.colors;
  ReplitTypography get replitTypography => replitTheme.typography;

  /// Syntax colors: the installed set, or the preset matching the ambient
  /// brightness when the theme carries none.
  ReplitSyntaxColors get replitSyntaxColors {
    final syntax = replitTheme.syntax;
    if (syntax != null) return syntax;
    return Theme.of(this).brightness == Brightness.dark
        ? ReplitSyntaxColors.dark
        : ReplitSyntaxColors.light;
  }
}
