import 'package:material_ui/material_ui.dart';

/// Host overrides for [ReplitSuggestion]'s look, on top of the theme tokens.
///
/// Every field is optional; null falls back to the token-derived default
/// noted on the field. Install one on [ReplitTheme.suggestionStyle] to
/// restyle every suggestion; a widget's own `style` wins field by field:
///
/// ```dart
/// ReplitSuggestion(
///   label: 'Plan my week',
///   style: const ReplitSuggestionStyle(borderColor: Color(0x33336699)),
/// )
/// ```
@immutable
class ReplitSuggestionStyle {
  const ReplitSuggestionStyle({
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.foregroundColor,
    this.labelStyle,
  });

  /// The row's fill. Defaults to ink at 2% on the outlined form and
  /// transparent on the plain one.
  final Color? backgroundColor;

  /// The outlined form's hairline. Defaults to `outline`; the
  /// plain form draws none regardless.
  final Color? borderColor;

  /// The fill while hovered. Defaults to `surfaceContainerLow`.
  final Color? hoverColor;

  /// Icon and label ink at rest. Defaults to `onSurface` on the outlined
  /// form and `onSurfaceVariant` on the plain one; hover lifts both to
  /// `onSurface`, and disabled paints `onSurfaceDisabled`, regardless.
  final Color? foregroundColor;

  /// Merged over the default label style.
  final TextStyle? labelStyle;

  /// A copy where [other]'s fields win over this style's.
  ReplitSuggestionStyle merge(ReplitSuggestionStyle? other) {
    if (other == null) return this;
    return ReplitSuggestionStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      hoverColor: other.hoverColor ?? hoverColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      labelStyle: other.labelStyle ?? labelStyle,
    );
  }

  /// Linear interpolation, for theme transitions. A null [other] returns
  /// this style unchanged.
  ReplitSuggestionStyle lerp(ReplitSuggestionStyle? other, double t) {
    if (other == null) return this;
    return ReplitSuggestionStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplitSuggestionStyle &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.hoverColor == hoverColor &&
        other.foregroundColor == foregroundColor &&
        other.labelStyle == labelStyle;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    borderColor,
    hoverColor,
    foregroundColor,
    labelStyle,
  );
}
