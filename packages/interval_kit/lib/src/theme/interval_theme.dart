import 'package:flutter/material.dart';

import 'interval_colors.dart';

/// Builds the light theme every app shares.
ThemeData buildIntervalTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: IntervalColors.primary,
    primary: IntervalColors.primary,
    onPrimary: IntervalColors.onPrimary,
    surface: IntervalColors.background,
    onSurface: IntervalColors.ink,
    surfaceContainerHighest: IntervalColors.surface,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: IntervalColors.background,
    fontFamily: 'Ubuntu',
    package: 'interval_kit',
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: IntervalColors.ink, displayColor: IntervalColors.ink)
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontSize: 112,
            fontWeight: FontWeight.w700,
            height: 1,
            color: IntervalColors.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: IntervalColors.ink,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: IntervalColors.muted,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: IntervalColors.ink,
          ),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
    iconTheme: const IconThemeData(color: IntervalColors.muted, size: 36),
  );
}
