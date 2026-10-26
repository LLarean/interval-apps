import 'phase.dart';
import 'timer_snapshot.dart';

/// An immutable, ordered sequence of [Phase]s.
final class WorkoutPlan {
  WorkoutPlan(Iterable<Phase> phases)
    : phases = List.unmodifiable(
        phases.where((phase) => phase.duration > Duration.zero),
      ) {
    if (this.phases.isEmpty) {
      throw ArgumentError.value(phases, 'phases', 'must contain time');
    }
  }

  /// Builds the classic "prepare, then N × (high, low)" interval plan.
  ///
  /// When [lowAfterLastRound] is `false` the workout ends right after the
  /// last high phase, as in Tabata. Interval walking keeps the final slow
  /// phase as a cool-down.
  factory WorkoutPlan.intervals({
    required int rounds,
    required Duration high,
    required Duration low,
    Duration prepare = Duration.zero,
    bool lowAfterLastRound = true,
  }) {
    if (rounds < 1) {
      throw ArgumentError.value(rounds, 'rounds', 'must be at least 1');
    }

    return WorkoutPlan([
      Phase(intensity: Intensity.prepare, duration: prepare, round: 0),
      for (var round = 1; round <= rounds; round++) ...[
        Phase(intensity: Intensity.high, duration: high, round: round),
        if (round < rounds || lowAfterLastRound)
          Phase(intensity: Intensity.low, duration: low, round: round),
      ],
    ]);
  }

  final List<Phase> phases;

  @override
  bool operator ==(Object other) =>
      other is WorkoutPlan && _listEquals(other.phases, phases);

  @override
  int get hashCode => Object.hashAll(phases);

  int get rounds => phases.last.round;

  Duration get totalDuration =>
      phases.fold(Duration.zero, (total, phase) => total + phase.duration);

  /// Describes the workout as it looks [elapsed] after it started.
  TimerSnapshot snapshotAt(Duration elapsed) {
    if (elapsed < Duration.zero) {
      throw ArgumentError.value(elapsed, 'elapsed', 'must not be negative');
    }

    var phaseStart = Duration.zero;
    for (var index = 0; index < phases.length; index++) {
      final phase = phases[index];
      final phaseEnd = phaseStart + phase.duration;
      if (elapsed < phaseEnd) {
        return TimerSnapshot(
          plan: this,
          phaseIndex: index,
          elapsedInPhase: elapsed - phaseStart,
        );
      }
      phaseStart = phaseEnd;
    }

    return TimerSnapshot(
      plan: this,
      phaseIndex: phases.length - 1,
      elapsedInPhase: phases.last.duration,
    );
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
