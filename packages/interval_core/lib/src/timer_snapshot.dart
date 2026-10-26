import 'phase.dart';
import 'workout_plan.dart';

/// The state of a [WorkoutPlan] at one moment in time.
final class TimerSnapshot {
  const TimerSnapshot({
    required this.plan,
    required this.phaseIndex,
    required this.elapsedInPhase,
  });

  /// The snapshot of a workout that has not started yet.
  factory TimerSnapshot.initial(WorkoutPlan plan) =>
      TimerSnapshot(plan: plan, phaseIndex: 0, elapsedInPhase: Duration.zero);

  final WorkoutPlan plan;
  final int phaseIndex;
  final Duration elapsedInPhase;

  Phase get phase => plan.phases[phaseIndex];

  Duration get remainingInPhase => phase.duration - elapsedInPhase;

  /// Whole seconds left in the phase, rounded up the way people read a
  /// countdown: `20` right after a 20 s phase starts, `1` during its last
  /// second.
  int get remainingSeconds {
    final micros = remainingInPhase.inMicroseconds;
    return (micros + Duration.microsecondsPerSecond - 1) ~/
        Duration.microsecondsPerSecond;
  }

  /// Fraction of the phase still ahead, from `1.0` down to `0.0`.
  double get remainingFraction =>
      remainingInPhase.inMicroseconds / phase.duration.inMicroseconds;

  bool get isFinished =>
      phaseIndex == plan.phases.length - 1 && remainingInPhase <= Duration.zero;

  @override
  bool operator ==(Object other) =>
      other is TimerSnapshot &&
      identical(other.plan, plan) &&
      other.phaseIndex == phaseIndex &&
      other.elapsedInPhase == elapsedInPhase;

  @override
  int get hashCode => Object.hash(plan, phaseIndex, elapsedInPhase);

  @override
  String toString() =>
      'TimerSnapshot(phase $phaseIndex: $phase, ${remainingSeconds}s left)';
}
