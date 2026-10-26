import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'playlists.dart';

/// An audio file the user has chosen, not yet in the library.
typedef PickedTrack = ({String name, Stream<List<int>> Function() read});

/// The user's own music, one playlist per [Intensity].
///
/// Chosen files are copied into the app's private storage: the picker's
/// copies and content links may disappear, the library's tracks must not.
/// Each playlist is a folder, played in file-name order.
final class MusicLibrary extends ChangeNotifier
    implements ValueListenable<Playlists> {
  MusicLibrary._(this._root, this._playlists);

  /// Opens the library in [root], by default inside the app's support
  /// directory.
  static Future<MusicLibrary> open({Directory? root}) async {
    root ??= Directory(
      p.join((await getApplicationSupportDirectory()).path, 'music'),
    );
    var playlists = const Playlists();
    for (final intensity in Intensity.values) {
      playlists = playlists.withTracks(
        intensity,
        await _scan(_folder(root, intensity)),
      );
    }
    return MusicLibrary._(root, playlists);
  }

  final Directory _root;
  Playlists _playlists;

  @override
  Playlists get value => _playlists;

  /// Copies [tracks] into the playlist of [intensity]. A file with the same
  /// name replaces the one already there.
  Future<void> add(Intensity intensity, Iterable<PickedTrack> tracks) async {
    final folder = _folder(_root, intensity);
    await folder.create(recursive: true);
    for (final track in tracks) {
      final target = File(p.join(folder.path, p.basename(track.name)));
      // Written under a temporary name, so an interrupted copy never shows
      // up as a broken track.
      final partial = File('${target.path}.part');
      final sink = partial.openWrite();
      await sink.addStream(track.read());
      await sink.close();
      await partial.rename(target.path);
    }
    await _rescan(intensity);
  }

  /// Lets the user choose audio files for [intensity] and adds them.
  /// Returns how many were added; none if the user changed their mind.
  Future<int> choose(Intensity intensity) async {
    final files = await FilePicker.pickFiles(type: FileType.audio);
    if (files.isEmpty) return 0;
    await add(intensity, [
      for (final file in files) (name: file.name, read: file.readAsByteStream),
    ]);
    // The picker keeps its own copies; the library has its own now.
    await FilePicker.clearTemporaryFiles();
    return files.length;
  }

  Future<void> remove(Intensity intensity, Track track) async {
    final file = File(track.path);
    if (p.isWithin(_folder(_root, intensity).path, file.path) &&
        await file.exists()) {
      await file.delete();
    }
    await _rescan(intensity);
  }

  Future<void> _rescan(Intensity intensity) async {
    _playlists = _playlists.withTracks(
      intensity,
      await _scan(_folder(_root, intensity)),
    );
    notifyListeners();
  }

  static Directory _folder(Directory root, Intensity intensity) =>
      Directory(p.join(root.path, intensity.name));

  static Future<List<Track>> _scan(Directory folder) async {
    if (!await folder.exists()) return const [];
    final paths = [
      for (final entity in await folder.list().toList())
        if (entity is File && !entity.path.endsWith('.part')) entity.path,
    ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [for (final path in paths) Track(path)];
  }
}
