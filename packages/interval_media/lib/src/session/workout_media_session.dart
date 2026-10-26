import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:interval_kit/interval_kit.dart';

/// How a moment of the workout reads in the notification, e.g.
/// `Fast pace` and `Round 2 of 5`.
typedef DescribeWorkout = ({String title, String subtitle}) Function(
  TimerSnapshot snapshot,
);

/// The workout as the system sees it: a "now playing" notification and
/// lock-screen card with pause and stop buttons, also driven by headsets.
///
/// While the workout runs, the platform's media service stays in the
/// foreground and holds a wake lock, so the timer, its cues and the music
/// carry on with the screen off. A paused or finished workout releases it.
final class WorkoutMediaSession extends BaseAudioHandler {
  @visibleForTesting
  WorkoutMediaSession();

  /// Registers the session with the platform. Call once, before `runApp`.
  ///
  /// [notificationIcon] is a monochrome Android drawable, such as
  /// `drawable/ic_stat_workout`.
  static Future<WorkoutMediaSession> start({
    required String channelName,
    required String notificationIcon,
  }) => AudioService.init(
    builder: WorkoutMediaSession.new,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'workout',
      androidNotificationChannelName: channelName,
      androidNotificationIcon: notificationIcon,
      androidNotificationOngoing: true,
    ),
  );

  WorkoutController? _workout;
  DescribeWorkout? _describe;

  /// The phase and status last shown, to publish only real changes: the
  /// system moves the progress bar on its own between them.
  (int, TimerStatus)? _shown;

  /// Mirrors [workout] until the returned callback is called.
  VoidCallback follow(
    WorkoutController workout, {
    required DescribeWorkout describe,
  }) {
    _workout = workout;
    _describe = describe;
    _shown = null;
    workout.addListener(_publish);
    _publish();

    return () {
      workout.removeListener(_publish);
      _workout = null;
      playbackState.add(PlaybackState());
    };
  }

  void _publish() {
    final workout = _workout!;
    final snapshot = workout.snapshot;
    final shown = (snapshot.phaseIndex, workout.status);
    if (shown == _shown) return;
    _shown = shown;

    // An idle session has no notification and lets the service stop.
    if (workout.status == TimerStatus.ready) {
      playbackState.add(PlaybackState());
      return;
    }

    final (:title, :subtitle) = _describe!(snapshot);
    mediaItem.add(
      MediaItem(
        id: 'workout',
        title: title,
        artist: subtitle,
        duration: snapshot.phase.duration,
      ),
    );
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: workout.isRunning,
        controls: [
          if (workout.isRunning) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        updatePosition: snapshot.elapsedInPhase,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (_workout case final workout? when !workout.isRunning) workout.toggle();
  }

  @override
  Future<void> pause() async {
    if (_workout case final workout? when workout.isRunning) workout.toggle();
  }

  @override
  Future<void> stop() async => _workout?.reset();
}
