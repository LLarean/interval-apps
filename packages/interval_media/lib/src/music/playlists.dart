import 'package:flutter/foundation.dart';
import 'package:interval_kit/interval_kit.dart';

/// An audio file on the device.
@immutable
final class Track {
  const Track(this.path);

  final String path;

  /// The file name without folders and extension, e.g. `Morning run`.
  String get title {
    final name = path.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  @override
  bool operator ==(Object other) => other is Track && other.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'Track($path)';
}

/// The music chosen for each [Intensity] of a workout.
///
/// A missing or empty playlist means silence: only the cues are heard.
@immutable
final class Playlists {
  const Playlists([this._tracks = const {}]);

  final Map<Intensity, List<Track>> _tracks;

  List<Track> operator [](Intensity intensity) =>
      _tracks[intensity] ?? const [];

  Playlists withTracks(Intensity intensity, List<Track> tracks) =>
      Playlists({..._tracks, intensity: List.unmodifiable(tracks)});

  @override
  bool operator ==(Object other) =>
      other is Playlists &&
      Intensity.values.every(
        (intensity) => listEquals(other[intensity], this[intensity]),
      );

  @override
  int get hashCode =>
      Object.hashAll(Intensity.values.map((i) => Object.hashAll(this[i])));
}
