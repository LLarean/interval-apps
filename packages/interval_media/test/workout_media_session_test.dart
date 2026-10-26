import 'package:audio_service/audio_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';

void main() {
  const prepare = Duration(seconds: 2);
  const phase = Duration(seconds: 10);
  final plan = WorkoutPlan.intervals(
    rounds: 2,
    prepare: prepare,
    high: phase,
    low: phase,
  );

  void withSession(
    void Function(
      FakeAsync async,
      WorkoutController workout,
      WorkoutMediaSession session,
      List<PlaybackState> states,
    )
    body,
  ) {
    fakeAsync((async) {
      final workout = WorkoutController(
        plan: plan,
        cues: const SilentCuePlayer(),
        keepScreenOn: ({required enabled}) async {},
      );
      final session = WorkoutMediaSession();
      final states = <PlaybackState>[];
      final subscription = session.playbackState.skip(1).listen(states.add);
      final unfollow = session.follow(
        workout,
        describe: (snapshot) => (
          title: snapshot.phase.intensity.name,
          subtitle: 'Round ${snapshot.phase.round}',
        ),
      );
      async.flushMicrotasks();

      body(async, workout, session, states);

      unfollow();
      subscription.cancel();
      workout.dispose();
      async.flushMicrotasks();
    });
  }

  test('stays idle until the workout starts', () {
    withSession((async, _, session, _) {
      expect(session.playbackState.value.processingState, isIdle);
    });
  });

  test('shows the running phase with a pause button', () {
    withSession((async, workout, session, _) {
      workout.toggle();
      async.elapse(prepare + const Duration(seconds: 1));

      final state = session.playbackState.value;
      expect(state.processingState, AudioProcessingState.ready);
      expect(state.playing, isTrue);
      expect(state.controls, [MediaControl.pause, MediaControl.stop]);
      expect(session.mediaItem.value?.title, 'high');
      expect(session.mediaItem.value?.artist, 'Round 1');
      expect(session.mediaItem.value?.duration, phase);
    });
  });

  test('publishes changes of phase, not every second', () {
    withSession((async, workout, _, states) {
      workout.toggle();
      async.elapse(prepare + phase + const Duration(seconds: 1));

      final shown = states.where((state) => state.processingState != isIdle);
      expect(shown, hasLength(3), reason: 'countdown, fast and slow');
      expect(shown.last.updatePosition, Duration.zero);
    });
  });

  test('pauses, resumes and stops the workout from the notification', () {
    withSession((async, workout, session, _) {
      workout.toggle();
      async.elapse(prepare + const Duration(seconds: 4));

      session.pause();
      async.flushMicrotasks();
      expect(workout.status, TimerStatus.paused);
      expect(session.playbackState.value.playing, isFalse);
      expect(session.playbackState.value.controls.first, MediaControl.play);
      expect(
        session.playbackState.value.updatePosition,
        const Duration(seconds: 4),
      );

      session.play();
      async.flushMicrotasks();
      expect(workout.isRunning, isTrue);

      session.stop();
      async.flushMicrotasks();
      expect(workout.status, TimerStatus.ready);
      expect(session.playbackState.value.processingState, isIdle);
    });
  });

  test('goes idle when the workout is over', () {
    withSession((async, workout, session, _) {
      workout.toggle();
      async.elapse(plan.totalDuration);

      expect(session.playbackState.value.processingState, isIdle);
    });
  });
}

const isIdle = AudioProcessingState.idle;
