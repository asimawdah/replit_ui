import 'package:material_ui/material_ui.dart';

/// Host overrides for [ReplitToast]'s look, on top of the theme tokens.
///
/// Every field is optional; null falls back to the token-derived default
/// noted on the field. Install one on [ReplitTheme.toastStyle] to restyle
/// every toast — the ones `showReplitToast` floats included; a widget's own
/// `style` wins field by field. The glyph is where a toast carries its
/// meaning, so the failure form is one override:
///
/// ```dart
/// showReplitToast(
///   context: context,
///   icon: Icons.error_outline,
///   message: 'Image upload failed. Try again',
///   style: ReplitToastStyle(iconColor: context.replitColors.error),
/// )
/// ```
@immutable
class ReplitToastStyle {
  const ReplitToastStyle({
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.dismissIconColor,
    this.messageStyle,
  });

  /// The card's fill. Defaults to `surfaceBright` at 80%.
  final Color? backgroundColor;

  /// The card's hairline. Defaults to `outlineVariant`.
  final Color? borderColor;

  /// The leading glyph. Defaults to `onSurface`; a failure toast passes
  /// `error`, a success one `success`.
  final Color? iconColor;

  /// The dismiss cross. Defaults to `onSurfaceVariant`.
  final Color? dismissIconColor;

  /// Merged over the message's default `labelMediumEmphasised` +
  /// `onSurface` style.
  final TextStyle? messageStyle;

  /// A copy where [other]'s fields win over this style's.
  ReplitToastStyle merge(ReplitToastStyle? other) {
    if (other == null) return this;
    return ReplitToastStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      iconColor: other.iconColor ?? iconColor,
      dismissIconColor: other.dismissIconColor ?? dismissIconColor,
      messageStyle: other.messageStyle ?? messageStyle,
    );
  }

  /// Linear interpolation, for theme transitions. A null [other] returns
  /// this style unchanged.
  ReplitToastStyle lerp(ReplitToastStyle? other, double t) {
    if (other == null) return this;
    return ReplitToastStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      dismissIconColor: Color.lerp(dismissIconColor, other.dismissIconColor, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplitToastStyle &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.iconColor == iconColor &&
        other.dismissIconColor == dismissIconColor &&
        other.messageStyle == messageStyle;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    borderColor,
    iconColor,
    dismissIconColor,
    messageStyle,
  );
}
