import 'package:fake_async/fake_async.dart';
import 'package:interval_core/interval_core.dart';
import 'package:test/test.dart';

void main() {
  final plan = WorkoutPlan.intervals(
    rounds: 2,
    prepare: const Duration(seconds: 3),
    high: const Duration(seconds: 4),
    low: const Duration(seconds: 2),
    lowAfterLastRound: false,
  );

  void withTimer(void Function(FakeAsync async, IntervalTimer timer) body) {
    fakeAsync((async) {
      final timer = IntervalTimer(plan);
      body(async, timer);
      timer.dispose();
      async.flushMicrotasks();
    });
  }

  test('is ready and shows the first phase before starting', () {
    withTimer((async, timer) {
      expect(timer.status, TimerStatus.ready);
      expect(timer.snapshot.remainingSeconds, 3);
    });
  });

  test('counts down once per second', () {
    withTimer((async, timer) {
      final seconds = <int>[];
      timer.snapshots.listen((snapshot) {
        seconds.add(snapshot.remainingSeconds);
      });

      timer.start();
      async.elapse(const Duration(seconds: 3));

      expect(seconds, [3, 2, 1, 4]);
    });
  });

  test('announces every phase and the end of the workout', () {
    withTimer((async, timer) {
      final events = <TimerEvent>[];
      timer.events.listen(events.add);

      timer.start();
      async.elapse(plan.totalDuration);

      expect(events.whereType<PhaseStarted>().map((e) => e.phase), [
        ...plan.phases,
      ]);
      expect(events.last, isA<WorkoutFinished>());
      expect(timer.status, TimerStatus.finished);
    });
  });

  test('does not drift when wake-ups are late', () {
    withTimer((async, timer) {
      timer.start();
      // Simulate a busy host: time passes without timers getting a chance.
      async.elapseBlocking(const Duration(milliseconds: 3500));

      expect(timer.snapshot.phase.intensity, Intensity.high);
      expect(timer.snapshot.remainingSeconds, 4);
    });
  });

  test('pause freezes the countdown and start resumes it', () {
    withTimer((async, timer) {
      timer.start();
      async.elapse(const Duration(milliseconds: 1500));
      timer.pause();
      async.elapse(const Duration(minutes: 1));

      expect(timer.status, TimerStatus.paused);
      expect(timer.snapshot.elapsedInPhase, const Duration(milliseconds: 1500));

      timer.start();
      async.elapse(const Duration(milliseconds: 1500));

      expect(timer.snapshot.phase.intensity, Intensity.high);
    });
  });

  test('resuming does not announce the current phase again', () {
    withTimer((async, timer) {
      final events = <TimerEvent>[];
      timer.events.listen(events.add);

      timer
        ..start()
        ..pause()
        ..start();
      async.flushMicrotasks();

      expect(events, hasLength(1));
    });
  });

  test('reset returns to the beginning', () {
    withTimer((async, timer) {
      timer.start();
      async.elapse(const Duration(seconds: 5));
      timer.reset();

      expect(timer.status, TimerStatus.ready);
      expect(timer.snapshot, TimerSnapshot.initial(plan));
    });
  });

  test('starting a finished workout runs it again', () {
    withTimer((async, timer) {
      timer.start();
      async.elapse(plan.totalDuration);
      timer.start();

      expect(timer.status, TimerStatus.running);
      expect(timer.snapshot.phaseIndex, 0);
    });
  });

  test('replacing the plan resets the timer', () {
    withTimer((async, timer) {
      final walking = WorkoutPlan.intervals(
        rounds: 5,
        high: const Duration(minutes: 3),
        low: const Duration(minutes: 3),
      );

      timer
        ..start()
        ..replacePlan(walking);

      expect(timer.status, TimerStatus.ready);
      expect(timer.snapshot.remainingSeconds, 180);
    });
  });
}
