import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';
import 'package:walking/l10n/generated/app_localizations.dart';
import 'package:walking/src/settings/settings_screen.dart';
import 'package:walking/src/settings/walking_settings.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('walking_music_'));
  tearDown(() => root.deleteSync(recursive: true));

  PickedTrack picked(String name) =>
      (name: name, read: () => Stream.value(const [0]));

  Future<MusicLibrary> pumpSettings(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.english,
    Map<Intensity, List<String>> tracks = const {},
  }) async {
    // Tall enough for every setting, so nothing needs scrolling.
    tester.view
      ..physicalSize = const Size(600, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final library = (await tester.runAsync(() async {
      final library = await MusicLibrary.open(root: root);
      for (final MapEntry(key: intensity, value: names) in tracks.entries) {
        await library.add(intensity, names.map(picked));
      }
      return library;
    }))!;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildIntervalTheme(),
        locale: language.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          KitLocalizations.delegate,
        ],
        home: SettingsScreen(
          settings: ValueNotifier(WalkingSettings(language: language)),
          version: '1.2.3',
          music: library,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return library;
  }

  testWidgets('shows how many tracks each pace has', (tester) async {
    await pumpSettings(
      tester,
      tracks: {
        Intensity.high: ['a.mp3', 'b.mp3'],
      },
    );

    expect(find.text('Fast pace music'), findsOneWidget);
    expect(find.text('2 tracks'), findsOneWidget);
    expect(find.text('No music'), findsOneWidget);
  });

  testWidgets('counts tracks in Russian', (tester) async {
    await pumpSettings(
      tester,
      language: AppLanguage.russian,
      tracks: {
        Intensity.high: ['a.mp3', 'b.mp3', 'c.mp3', 'd.mp3', 'e.mp3'],
        Intensity.low: ['a.mp3'],
      },
    );

    expect(find.text('5 треков'), findsOneWidget);
    expect(find.text('1 трек'), findsOneWidget);
  });

  testWidgets('lists and removes the tracks of a pace', (tester) async {
    final library = await pumpSettings(
      tester,
      tracks: {
        Intensity.low: ['Calm.mp3', 'Rain.mp3'],
      },
    );
    await tester.tap(find.text('2 tracks'));
    await tester.pumpAndSettle();

    expect(find.text('SLOW PACE'), findsOneWidget);
    expect(find.text('Calm'), findsOneWidget);
    expect(find.text('Rain'), findsOneWidget);

    await tester.runAsync(
      () => tester.tap(find.bySemanticsLabel('Remove Calm')),
    );
    await tester.runAsync(() async {
      while (library.value[Intensity.low].length > 1) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pumpAndSettle();

    expect(find.text('Calm'), findsNothing);
    expect(find.text('Rain'), findsOneWidget);
  });

  testWidgets('explains an empty playlist', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.text('No music').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Only the sounds will play'), findsOneWidget);
    expect(find.text('ADD TRACKS'), findsOneWidget);
  });
}
