import 'package:material_ui/material_ui.dart';

const String? _fontFamily = null;
const String _monoFontFamily = 'monospace';
const String? _fontPackage = null;

/// The standard cuts of the mono roles, which double as the constructor
/// defaults for [ReplitTypography.code] and [ReplitTypography.codeInline].
const TextStyle _standardCode = TextStyle(
  fontFamily: _monoFontFamily,
  package: _fontPackage,
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.6,
);
const TextStyle _standardCodeInline = TextStyle(
  fontFamily: _monoFontFamily,
  package: _fontPackage,
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

/// Text style tokens for replit_ui components.
///
/// Follows the Material 3 type scale (display / headline / title / body /
/// label, each in large / medium / small), so a host can map an existing M3
/// text theme across. Styles are colorless — components combine them with
/// [ReplitColors] tokens (e.g.
/// `typography.bodyLarge.copyWith(color: colors.onSurface)`).
@immutable
class ReplitTypography {
  const ReplitTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleLargeEmphasised,
    required this.titleMedium,
    required this.titleMediumEmphasised,
    required this.titleSmall,
    required this.titleSmallEmphasised,
    required this.bodyLarge,
    required this.bodyLargeEmphasised,
    required this.bodyLargeDark,
    required this.bodyMedium,
    required this.bodyMediumEmphasised,
    required this.bodyMediumDark,
    required this.bodySmall,
    required this.bodySmallEmphasised,
    required this.bodySmallDark,
    required this.labelLarge,
    required this.labelLargeEmphasised,
    required this.labelMedium,
    required this.labelMediumEmphasised,
    required this.labelSmall,
    required this.labelSmallEmphasised,
    this.code = _standardCode,
    this.codeInline = _standardCodeInline,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;

  /// Headings — single-line at 1.0. Each size pairs the regular cut
  /// (w400) with an emphasised one (w700).
  final TextStyle titleLarge;
  final TextStyle titleLargeEmphasised;
  final TextStyle titleMedium;
  final TextStyle titleMediumEmphasised;
  final TextStyle titleSmall;
  final TextStyle titleSmallEmphasised;

  /// Prose and composer input.
  /// Each size carries three weights: regular (w400), emphasised (w500) and
  /// dark (w700).
  final TextStyle bodyLarge;
  final TextStyle bodyLargeEmphasised;
  final TextStyle bodyLargeDark;
  final TextStyle bodyMedium;
  final TextStyle bodyMediumEmphasised;
  final TextStyle bodyMediumDark;
  final TextStyle bodySmall;
  final TextStyle bodySmallEmphasised;
  final TextStyle bodySmallDark;

  /// Controls — each size pairs the regular cut (w400) with an emphasised
  /// one (w500), like the body roles.
  final TextStyle labelLarge;
  final TextStyle labelLargeEmphasised;
  final TextStyle labelMedium;
  final TextStyle labelMediumEmphasised;
  final TextStyle labelSmall;
  final TextStyle labelSmallEmphasised;

  /// The code block's body, in the host's monospace face: 13 on a taller line
  /// (1.6), so a block reads as inset material, not a continuing
  /// paragraph.
  final TextStyle code;

  /// The mono face a step under prose size, for inline code spans.
  final TextStyle codeInline;

  /// The type scale, inheriting the host's text face and monospace fallback.
  static const ReplitTypography standard = ReplitTypography(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 52,
      fontWeight: FontWeight.w400,
      height: 0.95,
      letterSpacing: -1.56,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 46,
      fontWeight: FontWeight.w400,
      height: 0.95,
      letterSpacing: -1.38,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 40,
      fontWeight: FontWeight.w400,
      height: 0.95,
      letterSpacing: -1.2,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 0.95,
      letterSpacing: -1.08,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 0.95,
      letterSpacing: -0.96,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: -0.56,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: -0.48,
    ),
    titleLargeEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -0.48,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 21,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: -0.42,
    ),
    titleMediumEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 21,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -0.42,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: -0.36,
    ),
    titleSmallEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -0.36,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    bodyLargeEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    bodyLargeDark: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    bodyMediumEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    bodyMediumDark: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    bodySmallEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    bodySmallDark: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.8,
    ),
    labelLargeEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.8,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.7,
    ),
    labelMediumEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.7,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.6,
    ),
    labelSmallEmphasised: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.6,
    ),
  );

  /// The same scale set in [fontFamily] instead of the host's default face.
  /// The mono roles keep their own face — swap those with
  /// [withCodeFontFamily].
  ///
  /// Pass [package] when the font ships inside a package rather than the app.
  /// The library does not bundle Diatype. Replit-branded hosts can register
  /// their licensed copy in the app and use this method to select it.
  ///
  /// Each style is rebuilt from the four things the scale carries — size,
  /// weight, line height and tracking — so anything else set on a customised
  /// style is dropped rather than half-kept.
  ReplitTypography withFontFamily(String fontFamily, {String? package}) {
    TextStyle reface(TextStyle style) => TextStyle(
      fontFamily: fontFamily,
      package: package,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      height: style.height,
      letterSpacing: style.letterSpacing,
    );

    return ReplitTypography(
      displayLarge: reface(displayLarge),
      displayMedium: reface(displayMedium),
      displaySmall: reface(displaySmall),
      headlineLarge: reface(headlineLarge),
      headlineMedium: reface(headlineMedium),
      headlineSmall: reface(headlineSmall),
      titleLarge: reface(titleLarge),
      titleLargeEmphasised: reface(titleLargeEmphasised),
      titleMedium: reface(titleMedium),
      titleMediumEmphasised: reface(titleMediumEmphasised),
      titleSmall: reface(titleSmall),
      titleSmallEmphasised: reface(titleSmallEmphasised),
      bodyLarge: reface(bodyLarge),
      bodyLargeEmphasised: reface(bodyLargeEmphasised),
      bodyLargeDark: reface(bodyLargeDark),
      bodyMedium: reface(bodyMedium),
      bodyMediumEmphasised: reface(bodyMediumEmphasised),
      bodyMediumDark: reface(bodyMediumDark),
      bodySmall: reface(bodySmall),
      bodySmallEmphasised: reface(bodySmallEmphasised),
      bodySmallDark: reface(bodySmallDark),
      labelLarge: reface(labelLarge),
      labelLargeEmphasised: reface(labelLargeEmphasised),
      labelMedium: reface(labelMedium),
      labelMediumEmphasised: reface(labelMediumEmphasised),
      labelSmall: reface(labelSmall),
      labelSmallEmphasised: reface(labelSmallEmphasised),
      code: code,
      codeInline: codeInline,
    );
  }

  /// The same scale with only [code] and [codeInline] set in [fontFamily] —
  /// for hosts swapping the mono face while keeping the prose one.
  ///
  /// Rebuilt from size, weight and line height, like [withFontFamily].
  ReplitTypography withCodeFontFamily(String fontFamily, {String? package}) {
    TextStyle reface(TextStyle style) => TextStyle(
      fontFamily: fontFamily,
      package: package,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      height: style.height,
      letterSpacing: style.letterSpacing,
    );

    return copyWith(code: reface(code), codeInline: reface(codeInline));
  }

  /// [style] at [fontWeight] and/or [fontStyle].
  ///
  /// Equivalent to `style.copyWith(fontWeight: …, fontStyle: …)`. It existed
  /// only while typefaces came from `google_fonts`, which registered each
  /// cut as its own family that `copyWith` could not reach. The engine
  /// resolves the nearest weight declared by the host's font.
  @Deprecated(
    'Use style.copyWith(fontWeight:, fontStyle:) — the bundled families '
    'declare every cut. Will be removed in replit_ui 0.6.0.',
  )
  static TextStyle recut(
    TextStyle style, {
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) => style.copyWith(fontWeight: fontWeight, fontStyle: fontStyle);

  ReplitTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleLargeEmphasised,
    TextStyle? titleMedium,
    TextStyle? titleMediumEmphasised,
    TextStyle? titleSmall,
    TextStyle? titleSmallEmphasised,
    TextStyle? bodyLarge,
    TextStyle? bodyLargeEmphasised,
    TextStyle? bodyLargeDark,
    TextStyle? bodyMedium,
    TextStyle? bodyMediumEmphasised,
    TextStyle? bodyMediumDark,
    TextStyle? bodySmall,
    TextStyle? bodySmallEmphasised,
    TextStyle? bodySmallDark,
    TextStyle? labelLarge,
    TextStyle? labelLargeEmphasised,
    TextStyle? labelMedium,
    TextStyle? labelMediumEmphasised,
    TextStyle? labelSmall,
    TextStyle? labelSmallEmphasised,
    TextStyle? code,
    TextStyle? codeInline,
  }) {
    return ReplitTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleLargeEmphasised: titleLargeEmphasised ?? this.titleLargeEmphasised,
      titleMedium: titleMedium ?? this.titleMedium,
      titleMediumEmphasised:
          titleMediumEmphasised ?? this.titleMediumEmphasised,
      titleSmall: titleSmall ?? this.titleSmall,
      titleSmallEmphasised: titleSmallEmphasised ?? this.titleSmallEmphasised,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyLargeEmphasised: bodyLargeEmphasised ?? this.bodyLargeEmphasised,
      bodyLargeDark: bodyLargeDark ?? this.bodyLargeDark,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodyMediumEmphasised: bodyMediumEmphasised ?? this.bodyMediumEmphasised,
      bodyMediumDark: bodyMediumDark ?? this.bodyMediumDark,
      bodySmall: bodySmall ?? this.bodySmall,
      bodySmallEmphasised: bodySmallEmphasised ?? this.bodySmallEmphasised,
      bodySmallDark: bodySmallDark ?? this.bodySmallDark,
      labelLarge: labelLarge ?? this.labelLarge,
      labelLargeEmphasised: labelLargeEmphasised ?? this.labelLargeEmphasised,
      labelMedium: labelMedium ?? this.labelMedium,
      labelMediumEmphasised:
          labelMediumEmphasised ?? this.labelMediumEmphasised,
      labelSmall: labelSmall ?? this.labelSmall,
      labelSmallEmphasised: labelSmallEmphasised ?? this.labelSmallEmphasised,
      code: code ?? this.code,
      codeInline: codeInline ?? this.codeInline,
    );
  }

  ReplitTypography lerp(ReplitTypography? other, double t) {
    if (other == null) return this;
    return ReplitTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleLargeEmphasised: TextStyle.lerp(
        titleLargeEmphasised,
        other.titleLargeEmphasised,
        t,
      )!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleMediumEmphasised: TextStyle.lerp(
        titleMediumEmphasised,
        other.titleMediumEmphasised,
        t,
      )!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      titleSmallEmphasised: TextStyle.lerp(
        titleSmallEmphasised,
        other.titleSmallEmphasised,
        t,
      )!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyLargeEmphasised: TextStyle.lerp(
        bodyLargeEmphasised,
        other.bodyLargeEmphasised,
        t,
      )!,
      bodyLargeDark: TextStyle.lerp(bodyLargeDark, other.bodyLargeDark, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodyMediumEmphasised: TextStyle.lerp(
        bodyMediumEmphasised,
        other.bodyMediumEmphasised,
        t,
      )!,
      bodyMediumDark: TextStyle.lerp(bodyMediumDark, other.bodyMediumDark, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodySmallEmphasised: TextStyle.lerp(
        bodySmallEmphasised,
        other.bodySmallEmphasised,
        t,
      )!,
      bodySmallDark: TextStyle.lerp(bodySmallDark, other.bodySmallDark, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelLargeEmphasised: TextStyle.lerp(
        labelLargeEmphasised,
        other.labelLargeEmphasised,
        t,
      )!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelMediumEmphasised: TextStyle.lerp(
        labelMediumEmphasised,
        other.labelMediumEmphasised,
        t,
      )!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      labelSmallEmphasised: TextStyle.lerp(
        labelSmallEmphasised,
        other.labelSmallEmphasised,
        t,
      )!,
      code: TextStyle.lerp(code, other.code, t)!,
      codeInline: TextStyle.lerp(codeInline, other.codeInline, t)!,
    );
  }
}
