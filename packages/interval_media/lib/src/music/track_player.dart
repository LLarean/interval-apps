import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'playlists.dart';

/// Plays one playlist in a loop.
abstract interface class TrackPlayer {
  /// Replaces the playlist and starts again from its first track.
  Future<void> setTracks(List<Track> tracks);

  /// Starts or resumes playback; returns once it has been requested.
  Future<void> play();

  /// Pauses playback, keeping the position for the next [play].
  Future<void> pause();

  /// Sets the volume, from `0.0` to `1.0`.
  Future<void> setVolume(double volume);

  Future<void> dispose();
}

/// A [TrackPlayer] backed by `just_audio`.
final class JustAudioTrackPlayer implements TrackPlayer {
  final _player = AudioPlayer();

  @override
  Future<void> setTracks(List<Track> tracks) async {
    if (tracks.isEmpty) {
      await _player.stop();
      await _player.clearAudioSources();
      return;
    }
    await _player.setLoopMode(LoopMode.all);
    await _player.setAudioSources([
      for (final track in tracks) AudioSource.file(track.path),
    ], preload: false);
  }

  // just_audio's play() completes only when playback stops.
  @override
  Future<void> play() async => unawaited(_player.play());

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() => _player.dispose();
}

/// Records what is asked of a player, for tests.
@visibleForTesting
final class RecordingTrackPlayer implements TrackPlayer {
  var tracks = const <Track>[];
  var trackChanges = 0;
  var playing = false;
  var plays = 0;
  var disposed = false;
  final volumes = <double>[];

  double get volume => volumes.isEmpty ? 1 : volumes.last;

  @override
  Future<void> setTracks(List<Track> tracks) async {
    this.tracks = tracks;
    trackChanges++;
  }

  @override
  Future<void> play() async {
    playing = true;
    plays++;
  }

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);

  @override
  Future<void> dispose() async => disposed = true;
}
