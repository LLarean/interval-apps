/// How hard the user is working during a [Phase].
///
/// The values are deliberately app-neutral: Tabata calls [high] "work" and
/// [low] "rest", interval walking calls them "fast" and "slow".
enum Intensity {
  /// Countdown before the first round.
  prepare,

  /// The demanding part of a round.
  high,

  /// The recovery part of a round.
  low,
}

/// A single contiguous stretch of a workout.
final class Phase {
  const Phase({
    required this.intensity,
    required this.duration,
    required this.round,
  }) : assert(round >= 0, 'round must not be negative');

  final Intensity intensity;
  final Duration duration;

  /// One-based round this phase belongs to, or `0` for [Intensity.prepare].
  final int round;

  @override
  bool operator ==(Object other) =>
      other is Phase &&
      other.intensity == intensity &&
      other.duration == duration &&
      other.round == round;

  @override
  int get hashCode => Object.hash(intensity, duration, round);

  @override
  String toString() => 'Phase(${intensity.name}, $duration, round $round)';
}
