import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static final ThemeData light = _build(ReplitTheme.light(), Brightness.light);

  static final ThemeData dark = _build(ReplitTheme.dark(), Brightness.dark);

  static ThemeData _build(ReplitTheme replitTheme, Brightness brightness) {
    final colors = replitTheme.colors;
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
          primaryContainer: colors.primaryContainer,
          onPrimaryContainer: colors.onPrimaryContainer,
          secondary: colors.secondary,
          onSecondary: colors.onSecondary,
          secondaryContainer: colors.secondaryContainer,
          onSecondaryContainer: colors.onSecondaryContainer,
          tertiary: colors.tertiary,
          onTertiary: colors.onTertiary,
          tertiaryContainer: colors.tertiaryContainer,
          onTertiaryContainer: colors.onTertiaryContainer,
          error: colors.error,
          onError: colors.onError,
          errorContainer: colors.errorContainer,
          onErrorContainer: colors.onErrorContainer,
          surface: colors.surface,
          onSurface: colors.onSurface,
          surfaceContainerLowest: colors.surfaceContainerLowest,
          surfaceContainerLow: colors.surfaceContainerLow,
          surfaceContainer: colors.surfaceContainer,
          surfaceContainerHigh: colors.surfaceContainerHigh,
          surfaceContainerHighest: colors.surfaceContainerHighest,
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
      fontFamily: 'Diatype',
      extensions: [replitTheme.copyWith(typography: typography)],
      useMaterial3: true,
    );
  }
}
