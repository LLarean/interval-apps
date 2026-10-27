import 'package:flutter/material.dart';

import 'interval_colors.dart';

/// Builds the light or dark theme every app shares.
ThemeData buildIntervalTheme({Brightness brightness = Brightness.light}) {
  final colors = brightness == Brightness.dark
      ? IntervalColors.dark
      : IntervalColors.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: brightness,
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    surface: colors.background,
    onSurface: colors.ink,
    surfaceContainerHighest: colors.surface,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    fontFamily: 'Ubuntu',
    package: 'interval_kit',
    extensions: [colors],
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: colors.ink, displayColor: colors.ink)
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontSize: 112,
            fontWeight: FontWeight.w700,
            height: 1,
            color: colors.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: colors.muted,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.ink,
          ),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
    iconTheme: IconThemeData(color: colors.muted, size: 36),
  );
}
