import 'package:interval_core/interval_core.dart';

/// A short sound that tells the user something without looking at the screen.
enum Cue {
  /// A button was pressed.
  tap,

  /// A high-intensity phase begins.
  high,

  /// A low-intensity phase begins.
  low,

  /// The workout is over.
  finish;

  /// The cue announcing [phase], if it deserves one. The countdown before
  /// the first round starts silently, right after the [tap] of the button.
  static Cue? forPhase(Phase phase) => switch (phase.intensity) {
    Intensity.prepare => null,
    Intensity.high => high,
    Intensity.low => low,
  };
}
