import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';

void main() {
  const prepare = Duration(seconds: 2);
  const phase = Duration(seconds: 10);
  const crossfade = Duration(seconds: 3);
  final plan = WorkoutPlan.intervals(
    rounds: 2,
    prepare: prepare,
    high: phase,
    low: phase,
  );
  final fastTracks = [const Track('/music/fast/one.mp3')];
  final slowTracks = [const Track('/music/slow/two.mp3')];

  void withMusic(
    void Function(
      FakeAsync async,
      WorkoutController workout,
      RecordingTrackPlayer fast,
      RecordingTrackPlayer slow,
      ValueNotifier<Playlists> playlists,
    )
    body, {
    Playlists? initial,
  }) {
    fakeAsync((async) {
      final workout = WorkoutController(
        plan: plan,
        cues: const SilentCuePlayer(),
        keepScreenOn: ({required enabled}) async {},
      );
      final playlists = ValueNotifier(
        initial ??
            const Playlists()
                .withTracks(Intensity.high, fastTracks)
                .withTracks(Intensity.low, slowTracks),
      );
      final players = <RecordingTrackPlayer>[];
      final music = PhaseMusic(
        workout: workout,
        playlists: playlists,
        createPlayer: () {
          final player = RecordingTrackPlayer();
          players.add(player);
          return player;
        },
      );
      async.flushMicrotasks();

      body(async, workout, players[0], players[1], playlists);

      music.dispose();
      workout.dispose();
      async.flushMicrotasks();
    });
  }

  test('loads each playlist into its own player', () {
    withMusic((async, _, fast, slow, _) {
      expect(fast.tracks, fastTracks);
      expect(slow.tracks, slowTracks);
    });
  });

  test('stays silent during the countdown', () {
    withMusic((async, workout, fast, slow, _) {
      workout.toggle();
      async.elapse(prepare - const Duration(milliseconds: 100));

      expect(fast.playing, isFalse);
      expect(slow.playing, isFalse);
    });
  });

  test('fades the fast music in when the fast phase starts', () {
    withMusic((async, workout, fast, slow, _) {
      workout.toggle();
      async.elapse(prepare + const Duration(milliseconds: 100));

      expect(fast.playing, isTrue);
      expect(fast.volume, lessThan(0.1));

      async.elapse(crossfade);

      expect(fast.volume, 1);
      expect(slow.playing, isFalse);
    });
  });

  test('cross-fades into the slow music at the change of pace', () {
    withMusic((async, workout, fast, slow, _) {
      workout.toggle();
      async.elapse(prepare + phase + crossfade ~/ 2);

      expect(fast.playing, isTrue);
      expect(slow.playing, isTrue);
      expect(fast.volume, closeTo(0.5, 0.05));
      expect(slow.volume, closeTo(0.5, 0.05));

      async.elapse(crossfade);

      expect(fast.playing, isFalse);
      expect(slow.volume, 1);
    });
  });

  test('continues the fast music where it stopped', () {
    withMusic((async, workout, fast, _, _) {
      workout.toggle();
      async.elapse(prepare + phase * 2 + crossfade);

      expect(fast.plays, 2);
      expect(fast.trackChanges, 1, reason: 'the playlist is not reloaded');
    });
  });

  test('goes quiet at once on pause and fades back on resume', () {
    withMusic((async, workout, fast, _, _) {
      workout.toggle();
      async.elapse(prepare + crossfade);
      workout.toggle();
      async.flushMicrotasks();

      expect(fast.playing, isFalse);

      workout.toggle();
      async.elapse(crossfade);

      expect(fast.playing, isTrue);
      expect(fast.volume, 1);
    });
  });

  test('fades out after a reset', () {
    withMusic((async, workout, fast, _, _) {
      workout.toggle();
      async.elapse(prepare + crossfade);
      workout.reset();
      async.flushMicrotasks();

      expect(fast.playing, isTrue);

      async.elapse(crossfade);

      expect(fast.playing, isFalse);
      expect(fast.volume, 0);
    });
  });

  test('leaves the player alone for a phase without music', () {
    withMusic((async, workout, fast, slow, _) {
      workout.toggle();
      async.elapse(plan.totalDuration);

      expect(fast.plays, plan.rounds);
      expect(slow.plays, 0);
      expect(slow.volumes, isEmpty);
    }, initial: const Playlists().withTracks(Intensity.high, fastTracks));
  });

  test('starts music chosen in the middle of a phase', () {
    withMusic((async, workout, _, slow, playlists) {
      workout.toggle();
      async.elapse(prepare + phase + const Duration(seconds: 1));
      final more = [...slowTracks, const Track('/music/slow/three.mp3')];
      playlists.value = playlists.value.withTracks(Intensity.low, more);
      async.elapse(crossfade);

      expect(slow.tracks, more);
      expect(slow.playing, isTrue);
      expect(slow.volume, 1);
    });
  });

  test('releases the players', () {
    late RecordingTrackPlayer fastPlayer;
    withMusic((async, _, fast, _, _) => fastPlayer = fast);

    expect(fastPlayer.disposed, isTrue);
  });
}
