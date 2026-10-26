import 'dart:ui';

import 'package:interval_core/interval_core.dart';

/// The palette inherited from the original Unity Tabata Timer.
abstract final class IntervalColors {
  static const background = Color(0xFFF4EFEB);
  static const surface = Color(0xFFE7DFDA);
  static const primary = Color(0xFF405D26);
  static const onPrimary = Color(0xFFFFFFFF);
  static const ink = Color(0xFF494949);
  static const muted = Color(0xFFAEA79C);

  static const high = Color(0xFFFF9500);
  static const low = Color(0xFF92A65F);
  static const idle = muted;

  static Color forIntensity(Intensity intensity) => switch (intensity) {
    Intensity.high => high,
    Intensity.prepare || Intensity.low => low,
  };
}
