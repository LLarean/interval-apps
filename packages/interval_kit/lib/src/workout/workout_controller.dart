import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:interval_core/interval_core.dart';

import '../audio/cue.dart';
import '../audio/cue_player.dart';

/// Turns keeping the screen on during a workout on or off.
typedef KeepScreenOn = Future<void> Function({required bool enabled});

/// Drives one workout screen: runs the [IntervalTimer], plays the cues and
/// keeps the screen awake while the timer is running.
class WorkoutController extends ChangeNotifier {
  WorkoutController({
    required WorkoutPlan plan,
    required this._cues,
    required this._keepScreenOn,
    MonotonicClock? clock,
  }) : _timer = IntervalTimer(plan, clock: clock) {
    _snapshot = _timer.snapshot;
    _subscriptions = [
      _timer.snapshots.listen(_onSnapshot),
      _timer.events.listen(_onEvent),
    ];
  }

  final CuePlayer _cues;
  final KeepScreenOn _keepScreenOn;
  final IntervalTimer _timer;
  late final List<StreamSubscription<Object>> _subscriptions;
  late TimerSnapshot _snapshot;

  TimerSnapshot get snapshot => _snapshot;

  WorkoutPlan get plan => _timer.plan;

  TimerStatus get status => _timer.status;

  bool get isRunning => status == TimerStatus.running;

  /// Starts, pauses or resumes the workout.
  void toggle() {
    unawaited(_cues.play(Cue.tap));
    _timer.toggle();
    _syncScreen();
  }

  void reset() {
    unawaited(_cues.play(Cue.tap));
    _timer.reset();
    _syncScreen();
  }

  /// Applies new settings. The current workout is abandoned.
  void replacePlan(WorkoutPlan plan) {
    _timer.replacePlan(plan);
    _syncScreen();
  }

  void _onSnapshot(TimerSnapshot snapshot) {
    _snapshot = snapshot;
    notifyListeners();
  }

  void _onEvent(TimerEvent event) {
    switch (event) {
      case PhaseStarted(:final phase):
        if (Cue.forPhase(phase) case final cue?) {
          unawaited(_cues.play(cue));
        }
      case WorkoutFinished():
        unawaited(_cues.play(Cue.finish));
        _timer.reset();
        _syncScreen();
    }
  }

  void _syncScreen() => unawaited(_keepScreenOn(enabled: isRunning));

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_timer.dispose());
    unawaited(_keepScreenOn(enabled: false));
    super.dispose();
  }
}
