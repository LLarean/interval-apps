import 'dart:async';

import 'monotonic_clock.dart';
import 'timer_event.dart';
import 'timer_snapshot.dart';
import 'workout_plan.dart';

/// Lifecycle of an [IntervalTimer].
enum TimerStatus { ready, running, paused, finished }

/// Runs a [WorkoutPlan] in real time.
///
/// Time is measured with a [MonotonicClock] rather than by counting ticks,
/// so a late or skipped wake-up never makes the countdown drift: the next
/// [snapshot] is simply computed from the true elapsed time. The timer only
/// wakes up when the displayed second changes.
final class IntervalTimer {
  IntervalTimer(WorkoutPlan plan, {MonotonicClock? clock})
    : _plan = plan,
      _clock = clock ?? StopwatchClock(),
      _lastSnapshot = TimerSnapshot.initial(plan);

  final MonotonicClock _clock;
  final _snapshots = StreamController<TimerSnapshot>.broadcast();
  final _events = StreamController<TimerEvent>.broadcast();

  WorkoutPlan _plan;
  TimerStatus _status = TimerStatus.ready;
  TimerSnapshot _lastSnapshot;

  /// Time spent running before the current run started.
  Duration _banked = Duration.zero;

  /// Clock reading when the current run started; `null` unless running.
  Duration? _runStartedAt;
  Timer? _wakeUp;

  WorkoutPlan get plan => _plan;

  TimerStatus get status => _status;

  /// The workout state right now, computed on demand.
  TimerSnapshot get snapshot => _plan.snapshotAt(_elapsed);

  /// Emits whenever the displayed second, the phase or the [status] changes.
  Stream<TimerSnapshot> get snapshots => _snapshots.stream;

  /// Emits phase changes and the end of the workout.
  Stream<TimerEvent> get events => _events.stream;

  Duration get _elapsed {
    final runStartedAt = _runStartedAt;
    final running = runStartedAt == null
        ? Duration.zero
        : _clock.now - runStartedAt;
    final elapsed = _banked + running;
    final total = _plan.totalDuration;
    return elapsed < total ? elapsed : total;
  }

  /// Starts the workout or resumes it after [pause].
  void start() {
    switch (_status) {
      case TimerStatus.running:
        return;
      case TimerStatus.finished:
        _rewind();
      case TimerStatus.ready:
      case TimerStatus.paused:
        break;
    }

    final isFirstRun = _status == TimerStatus.ready;
    _status = TimerStatus.running;
    _runStartedAt = _clock.now;
    if (isFirstRun) {
      _events.add(PhaseStarted(_plan.phases.first));
    }
    _update();
  }

  /// Freezes the countdown; [start] continues from the same moment.
  void pause() {
    if (_status != TimerStatus.running) {
      return;
    }

    _banked = _elapsed;
    _runStartedAt = null;
    _wakeUp?.cancel();
    _status = TimerStatus.paused;
    _publish(snapshot);
  }

  void toggle() => _status == TimerStatus.running ? pause() : start();

  /// Stops the workout and returns to its very beginning.
  void reset() {
    _rewind();
    _publish(snapshot);
  }

  /// Replaces the plan and resets the timer, e.g. after a settings change.
  void replacePlan(WorkoutPlan plan) {
    _plan = plan;
    reset();
  }

  Future<void> dispose() async {
    _wakeUp?.cancel();
    await Future.wait([_snapshots.close(), _events.close()]);
  }

  void _rewind() {
    _wakeUp?.cancel();
    _banked = Duration.zero;
    _runStartedAt = null;
    _status = TimerStatus.ready;
  }

  void _update() {
    final current = snapshot;

    for (
      var index = _lastSnapshot.phaseIndex + 1;
      index <= current.phaseIndex;
      index++
    ) {
      _events.add(PhaseStarted(_plan.phases[index]));
    }

    if (current.isFinished) {
      _banked = _plan.totalDuration;
      _runStartedAt = null;
      _status = TimerStatus.finished;
      _events.add(const WorkoutFinished());
      _publish(current);
      return;
    }

    _publish(current);
    _scheduleWakeUp(current);
  }

  /// Sleeps until the countdown is due to show the next whole second.
  void _scheduleWakeUp(TimerSnapshot current) {
    final nextSecond = Duration(seconds: current.remainingSeconds - 1);
    final delay = current.remainingInPhase - nextSecond;

    _wakeUp?.cancel();
    _wakeUp = Timer(delay, _update);
  }

  void _publish(TimerSnapshot current) {
    _lastSnapshot = current;
    if (!_snapshots.isClosed) {
      _snapshots.add(current);
    }
  }
}
