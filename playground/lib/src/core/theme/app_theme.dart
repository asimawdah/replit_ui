import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static final ThemeData light = _build(ReplitTheme.light(), Brightness.light);

  static final ThemeData dark = _build(ReplitTheme.dark(), Brightness.dark);

  static final ThemeData playgroundLight = _build(
    ReplitTheme.light().copyWith(colors: _playgroundLightColors),
    Brightness.light,
  );

  static final ThemeData playgroundDark = _build(
    ReplitTheme.dark().copyWith(colors: _playgroundDarkColors),
    Brightness.dark,
  );

  static final ReplitColors _playgroundLightColors = ReplitColors.light
      .copyWith(
        primary: const Color(0xFFE071A7),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0x14E071A7),
        onPrimaryContainer: const Color(0xFFE071A7),
        secondary: const Color(0xFFFF67B0),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0x14FF67B0),
        onSecondaryContainer: const Color(0xFFFF67B0),
        tertiary: const Color(0xFF3730A3),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0x143730A3),
        onTertiaryContainer: const Color(0xFF3730A3),
        error: const Color(0xFFC14A4A),
        onError: const Color(0xFFFFFFFF),
        errorContainer: const Color(0x0FC14A4A),
        onErrorContainer: const Color(0xFFC14A4A),
        success: const Color(0xFF249655),
        onSuccess: const Color(0xFFFFFFFF),
        successContainer: const Color(0x0F249655),
        onSuccessContainer: const Color(0xFF249655),
        warning: const Color(0xFFEE8D34),
        onWarning: const Color(0xFFFFFFFF),
        warningContainer: const Color(0x0FEE8D34),
        onWarningContainer: const Color(0xFFEE8D34),
        surface: const Color(0xFFF9F9F7),
        surfaceBright: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF111110),
        onSurfaceVariant: const Color(0xBF111110),
        onSurfaceMuted: const Color(0x80111110),
        onSurfaceDisabled: const Color(0x4D111110),
        surfaceContainerLowest: const Color(0x05111110),
        surfaceContainerLow: const Color(0x0A111110),
        surfaceContainer: const Color(0x0F111110),
        surfaceContainerHigh: const Color(0x14111110),
        surfaceContainerHighest: const Color(0x1A111110),
        outline: const Color(0x12111110),
        outlineVariant: const Color(0x1F111110),
        shadow: const Color(0x05111110),
        inverseSurface: const Color(0xFF111110),
        onInverseSurface: const Color(0xFFFFFFFF),
        inversePrimary: const Color(0xFFF5E9EE),
      );

  static final ReplitColors _playgroundDarkColors = ReplitColors.dark.copyWith(
    primary: const Color(0xFFE071A7),
    onPrimary: const Color(0xFF1E1E1E),
    primaryContainer: const Color(0x14E071A7),
    onPrimaryContainer: const Color(0xFFE071A7),
    secondary: const Color(0xFFFF67B0),
    onSecondary: const Color(0xFF1E1E1E),
    secondaryContainer: const Color(0x14FF67B0),
    onSecondaryContainer: const Color(0xFFFF67B0),
    tertiary: const Color(0xFF77A8FD),
    onTertiary: const Color(0xFF1E1E1E),
    tertiaryContainer: const Color(0x1477A8FD),
    onTertiaryContainer: const Color(0xFF77A8FD),
    error: const Color(0xFFFF6565),
    onError: const Color(0xFF1E1E1E),
    errorContainer: const Color(0x0FFF6565),
    onErrorContainer: const Color(0xFFFF6565),
    success: const Color(0xFF50D59D),
    onSuccess: const Color(0xFF1E1E1E),
    successContainer: const Color(0x0F50D59D),
    onSuccessContainer: const Color(0xFF50D59D),
    warning: const Color(0xFFFF9A3E),
    onWarning: const Color(0xFF1E1E1E),
    warningContainer: const Color(0x0FFF9A3E),
    onWarningContainer: const Color(0xFFFF9A3E),
    surface: const Color(0xFF171717),
    surfaceBright: const Color(0xFF1E1E1E),
    onSurface: const Color(0xFFFFFFFF),
    onSurfaceVariant: const Color(0xBFFFFFFF),
    onSurfaceMuted: const Color(0x80FFFFFF),
    onSurfaceDisabled: const Color(0x4DFFFFFF),
    surfaceContainerLowest: const Color(0x05FFFFFF),
    surfaceContainerLow: const Color(0x0AFFFFFF),
    surfaceContainer: const Color(0x0FFFFFFF),
    surfaceContainerHigh: const Color(0x14FFFFFF),
    surfaceContainerHighest: const Color(0x1AFFFFFF),
    outline: const Color(0x14FFFFFF),
    outlineVariant: const Color(0x1FFFFFFF),
    shadow: const Color(0x05FFFFFF),
    inverseSurface: const Color(0xFFFFFFFF),
    onInverseSurface: const Color(0xFF1E1E1E),
    inversePrimary: const Color(0xFF2B2025),
  );

  static ThemeData _build(ReplitTheme replitTheme, Brightness brightness) {
    final colors = replitTheme.colors;
    Color opaque(Color color) => Color.alphaBlend(color, colors.surface);

    final typography = ReplitTypography.standard
        .withFontFamily('Diatype')
        .withCodeFontFamily('Diatype Semi-Mono');
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: brightness,
        ).copyWith(
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          primaryContainer: opaque(colors.primaryContainer),
          onPrimaryContainer: colors.onPrimaryContainer,
          secondary: colors.secondary,
          onSecondary: colors.onSecondary,
          secondaryContainer: opaque(colors.secondaryContainer),
          onSecondaryContainer: colors.onSecondaryContainer,
          tertiary: colors.tertiary,
          onTertiary: colors.onTertiary,
          tertiaryContainer: opaque(colors.tertiaryContainer),
          onTertiaryContainer: colors.onTertiaryContainer,
          error: colors.error,
          onError: colors.onError,
          errorContainer: opaque(colors.errorContainer),
          onErrorContainer: colors.onErrorContainer,
          surface: colors.surface,
          surfaceDim: colors.surface,
          surfaceBright: colors.surfaceBright,
          surfaceTint: Colors.transparent,
          onSurface: colors.onSurface,
          onSurfaceVariant: colors.onSurfaceVariant,
          surfaceContainerLowest: opaque(colors.surfaceContainerLowest),
          surfaceContainerLow: opaque(colors.surfaceContainerLow),
          surfaceContainer: opaque(colors.surfaceContainer),
          surfaceContainerHigh: opaque(colors.surfaceContainerHigh),
          surfaceContainerHighest: opaque(colors.surfaceContainerHighest),
          outline: colors.outlineVariant,
          outlineVariant: colors.outline,
          shadow: colors.shadow,
          inverseSurface: colors.inverseSurface,
          onInverseSurface: colors.onInverseSurface,
          inversePrimary: colors.inversePrimary,
        );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surface,
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceBright,
        surfaceTintColor: Colors.transparent,
      ),
      fontFamily: 'Diatype',
      extensions: [replitTheme.copyWith(typography: typography)],
      useMaterial3: true,
    );
  }
}
