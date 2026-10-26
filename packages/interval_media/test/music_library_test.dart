import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('music_library_'));
  tearDown(() => root.deleteSync(recursive: true));

  PickedTrack picked(String name, [String content = 'audio']) =>
      (name: name, read: () => Stream.value(content.codeUnits));

  List<String> titles(MusicLibrary library, Intensity intensity) => [
    for (final track in library.value[intensity]) track.title,
  ];

  test('starts empty', () async {
    final library = await MusicLibrary.open(root: root);

    expect(library.value, const Playlists());
  });

  test('copies chosen tracks into the playlist, in name order', () async {
    final library = await MusicLibrary.open(root: root);
    var notified = 0;
    library.addListener(() => notified++);

    await library.add(Intensity.high, [picked('b.mp3'), picked('A.mp3')]);

    expect(titles(library, Intensity.high), ['A', 'b']);
    expect(library.value[Intensity.low], isEmpty);
    expect(notified, 1);
    expect(
      File(library.value[Intensity.high].first.path).readAsStringSync(),
      'audio',
    );
  });

  test('keeps the playlists between launches', () async {
    final first = await MusicLibrary.open(root: root);
    await first.add(Intensity.low, [picked('calm.ogg')]);

    final second = await MusicLibrary.open(root: root);

    expect(titles(second, Intensity.low), ['calm']);
  });

  test('replaces a track added again under the same name', () async {
    final library = await MusicLibrary.open(root: root);
    await library.add(Intensity.high, [picked('song.mp3', 'old')]);
    await library.add(Intensity.high, [picked('song.mp3', 'new')]);

    final tracks = library.value[Intensity.high];
    expect(tracks, hasLength(1));
    expect(File(tracks.single.path).readAsStringSync(), 'new');
  });

  test('removes a track and its file', () async {
    final library = await MusicLibrary.open(root: root);
    await library.add(Intensity.high, [picked('one.mp3'), picked('two.mp3')]);
    final one = library.value[Intensity.high].first;

    await library.remove(Intensity.high, one);

    expect(titles(library, Intensity.high), ['two']);
    expect(File(one.path).existsSync(), isFalse);
  });

  test('ignores a copy that was interrupted', () async {
    Directory('${root.path}/high').createSync(recursive: true);
    File('${root.path}/high/broken.mp3.part').writeAsStringSync('half');

    final library = await MusicLibrary.open(root: root);

    expect(library.value[Intensity.high], isEmpty);
  });

  test('titles tracks by file name', () {
    expect(const Track('/music/high/Morning run.mp3').title, 'Morning run');
    expect(const Track(r'C:\music\high\no_extension').title, 'no_extension');
  });
}
