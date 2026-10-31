import 'package:material_ui/material_ui.dart';

/// Host overrides for [ReplitErrorState]'s look, on top of the theme tokens.
///
/// Every field is optional; null falls back to the token-derived default
/// noted on the field. Install one on [ReplitTheme.errorStateStyle] to
/// restyle every error card — failed turns in a thread included; a
/// widget's own `style` wins field by field:
///
/// ```dart
/// ReplitErrorState(
///   message: 'The model is overloaded.',
///   style: const ReplitErrorStateStyle(glyphColor: Color(0xFFB65C33)),
/// )
/// ```
@immutable
class ReplitErrorStateStyle {
  const ReplitErrorStateStyle({
    this.backgroundColor,
    this.borderColor,
    this.glyphColor,
    this.titleStyle,
    this.messageStyle,
  });

  /// The card's fill. Defaults to `surfaceContainer`.
  final Color? backgroundColor;

  /// The card's hairline. Defaults to `error` at 40%.
  final Color? borderColor;

  /// The error glyph. Defaults to `error`.
  final Color? glyphColor;

  /// Merged over the title's default `bodyMediumEmphasised` +
  /// `onSurface` style.
  final TextStyle? titleStyle;

  /// Merged over the message's default `bodyMedium` + `onSurfaceVariant`
  /// style.
  final TextStyle? messageStyle;

  /// A copy where [other]'s fields win over this style's.
  ReplitErrorStateStyle merge(ReplitErrorStateStyle? other) {
    if (other == null) return this;
    return ReplitErrorStateStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      glyphColor: other.glyphColor ?? glyphColor,
      titleStyle: other.titleStyle ?? titleStyle,
      messageStyle: other.messageStyle ?? messageStyle,
    );
  }

  /// Linear interpolation, for theme transitions. A null [other] returns
  /// this style unchanged.
  ReplitErrorStateStyle lerp(ReplitErrorStateStyle? other, double t) {
    if (other == null) return this;
    return ReplitErrorStateStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      glyphColor: Color.lerp(glyphColor, other.glyphColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplitErrorStateStyle &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.glyphColor == glyphColor &&
        other.titleStyle == titleStyle &&
        other.messageStyle == messageStyle;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    borderColor,
    glyphColor,
    titleStyle,
    messageStyle,
  );
}
