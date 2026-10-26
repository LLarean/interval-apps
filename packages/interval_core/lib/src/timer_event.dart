import 'phase.dart';

/// Something noteworthy that happened while an [IntervalTimer] was running.
sealed class TimerEvent {
  const TimerEvent();
}

/// A phase has begun, including the first one when the workout starts.
final class PhaseStarted extends TimerEvent {
  const PhaseStarted(this.phase);

  final Phase phase;

  @override
  String toString() => 'PhaseStarted($phase)';
}

/// The last phase has ended.
final class WorkoutFinished extends TimerEvent {
  const WorkoutFinished();

  @override
  String toString() => 'WorkoutFinished()';
}
