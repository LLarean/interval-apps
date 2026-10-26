import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:interval_kit/interval_kit.dart';

import 'playlists.dart';
import 'track_player.dart';

/// Plays a separate playlist during high and low phases of a workout.
///
/// At every change of pace the music of the finished phase fades out while
/// the next one fades in. Each playlist remembers where it stopped, so the
/// next fast phase continues the fast music instead of starting it over.
/// Nothing plays during the countdown, and a phase without tracks is silent.
final class PhaseMusic {
  PhaseMusic({
    required this._workout,
    required this._playlists,
    required TrackPlayer Function() createPlayer,
    this.crossfade = const Duration(seconds: 3),
  }) : _channels = {
         for (final intensity in [Intensity.high, Intensity.low])
           intensity: _Channel(createPlayer()),
       } {
    _onPlaylistsChanged();
    _sync();
    _workout.addListener(_sync);
    _playlists.addListener(_onPlaylistsChanged);
  }

  /// How long one playlist takes to fade into the other.
  final Duration crossfade;

  final WorkoutController _workout;
  final ValueListenable<Playlists> _playlists;
  final Map<Intensity, _Channel> _channels;

  void _onPlaylistsChanged() {
    for (final MapEntry(key: intensity, value: channel) in _channels.entries) {
      channel.setTracks(_playlists.value[intensity], fadeIn: crossfade);
    }
  }

  void _sync() {
    final intensity = _workout.snapshot.phase.intensity;
    final paused = _workout.status == TimerStatus.paused;

    for (final MapEntry(key: key, value: channel) in _channels.entries) {
      if (_workout.isRunning && key == intensity) {
        channel.fadeIn(crossfade);
      } else {
        // A paused workout should go quiet at once, not three seconds later.
        channel.fadeOut(paused ? Duration.zero : crossfade);
      }
    }
  }

  void dispose() {
    _workout.removeListener(_sync);
    _playlists.removeListener(_onPlaylistsChanged);
    for (final channel in _channels.values) {
      channel.dispose();
    }
  }
}

/// One playlist and its player, faded in and out on request.
final class _Channel {
  _Channel(this._player);

  static const _fadeStep = Duration(milliseconds: 50);

  final TrackPlayer _player;
  var _tracks = const <Track>[];
  var _audible = false;
  var _playing = false;
  var _volume = 0.0;
  Timer? _fade;

  /// Player calls run one after another, in the order they were made.
  Future<void> _queue = Future.value();

  void setTracks(List<Track> tracks, {required Duration fadeIn}) {
    if (listEquals(tracks, _tracks)) return;
    _tracks = tracks;
    _fade?.cancel();
    if (_playing) {
      _playing = false;
      _run(_player.pause);
    }
    _volume = 0;
    _run(() => _player.setTracks(tracks));
    if (_audible) _fadeTo(1, fadeIn);
  }

  void fadeIn(Duration duration) {
    if (_audible) return;
    _audible = true;
    _fadeTo(1, duration);
  }

  void fadeOut(Duration duration) {
    if (!_audible) return;
    _audible = false;
    _fadeTo(0, duration);
  }

  void _fadeTo(double target, Duration duration) {
    _fade?.cancel();
    if (_tracks.isEmpty) return;
    if (target > 0 && !_playing) {
      _playing = true;
      _setVolume(_volume);
      _run(_player.play);
    }

    if (duration <= Duration.zero) {
      _setVolume(target);
      _pauseIfSilent();
      return;
    }

    final start = _volume;
    final steps = math.max(
      1,
      duration.inMicroseconds ~/ _fadeStep.inMicroseconds,
    );
    var step = 0;
    _fade = Timer.periodic(_fadeStep, (timer) {
      step++;
      _setVolume(start + (target - start) * step / steps);
      if (step == steps) {
        timer.cancel();
        _pauseIfSilent();
      }
    });
  }

  void _setVolume(double volume) {
    _volume = volume;
    _run(() => _player.setVolume(volume));
  }

  void _pauseIfSilent() {
    if (!_audible && _playing) {
      _playing = false;
      _run(_player.pause);
    }
  }

  void _run(Future<void> Function() action) {
    _queue = _queue.then((_) => action()).catchError((Object error) {
      // A track that cannot be played must not silence the rest.
      debugPrint('Music player error: $error');
    });
  }

  void dispose() {
    _fade?.cancel();
    _run(_player.dispose);
  }
}
