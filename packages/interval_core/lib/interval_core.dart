/// Platform-independent interval workout engine.
///
/// A [WorkoutPlan] is an ordered list of [Phase]s. An [IntervalTimer] runs
/// a plan against a monotonic clock and reports [TimerSnapshot]s and
/// [TimerEvent]s, so the remaining time never drifts regardless of how
/// often (or how late) the host gets to run.
library;

export 'src/interval_timer.dart';
export 'src/monotonic_clock.dart';
export 'src/phase.dart';
export 'src/timer_event.dart';
export 'src/timer_snapshot.dart';
export 'src/workout_plan.dart';
