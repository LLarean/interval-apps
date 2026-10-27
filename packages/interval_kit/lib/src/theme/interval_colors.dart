import 'package:flutter/material.dart';
import 'package:interval_core/interval_core.dart';

/// The palette of the apps, in a light and a dark variant.
///
/// The light one is inherited from the original Unity Tabata Timer; the dark
/// one keeps its warm greys and the same phase colours.
@immutable
final class IntervalColors extends ThemeExtension<IntervalColors> {
  const IntervalColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.ink,
    required this.muted,
    required this.high,
    required this.low,
  });

  static const light = IntervalColors(
    background: Color(0xFFF4EFEB),
    surface: Color(0xFFE7DFDA),
    primary: Color(0xFF405D26),
    onPrimary: Color(0xFFFFFFFF),
    ink: Color(0xFF494949),
    muted: Color(0xFFAEA79C),
    high: Color(0xFFFF9500),
    low: Color(0xFF92A65F),
  );

  static const dark = IntervalColors(
    background: Color(0xFF1C1A18),
    surface: Color(0xFF2D2926),
    primary: Color(0xFF6B9A3E),
    onPrimary: Color(0xFFFFFFFF),
    ink: Color(0xFFECE6E0),
    muted: Color(0xFF8F877C),
    high: Color(0xFFFF9500),
    low: Color(0xFF92A65F),
  );

  /// The palette of the current theme.
  static IntervalColors of(BuildContext context) =>
      Theme.of(context).extension<IntervalColors>() ?? light;

  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color ink;
  final Color muted;
  final Color high;
  final Color low;

  Color get idle => muted;

  Color forIntensity(Intensity intensity) => switch (intensity) {
    Intensity.high => high,
    Intensity.prepare || Intensity.low => low,
  };

  @override
  IntervalColors copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? onPrimary,
    Color? ink,
    Color? muted,
    Color? high,
    Color? low,
  }) => IntervalColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    high: high ?? this.high,
    low: low ?? this.low,
  );

  @override
  IntervalColors lerp(IntervalColors? other, double t) {
    if (other == null) {
      return this;
    }
    return IntervalColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      high: Color.lerp(high, other.high, t)!,
      low: Color.lerp(low, other.low, t)!,
    );
  }
}
