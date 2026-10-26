@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';
import 'package:interval_testing/interval_testing.dart';
import 'package:walking/src/app.dart';
import 'package:walking/src/settings/walking_settings.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('README screenshots', (tester) async {
    usePhoneScreen(tester);
    final root = Directory.systemTemp.createTempSync('walking_screenshots_');
    addTearDown(() => root.deleteSync(recursive: true));
    final music = (await tester.runAsync(() async {
      final music = await MusicLibrary.open(root: root);
      await music.add(Intensity.high, [
        for (final title in [
          'Born to Run',
          'Mr. Blue Sky',
          'Walking on Sunshine',
        ])
          (name: '$title.mp3', read: () => Stream.value(const [0])),
      ]);
      return music;
    }))!;

    await tester.pumpWidget(
      WalkingApp(
        settings: ValueNotifier(
          const WalkingSettings(language: AppLanguage.english),
        ),
        cues: const SilentCuePlayer(),
        version: '0.1.0',
        keepScreenOn: ({required enabled}) async {},
        music: music,
        createPlayer: RecordingTrackPlayer.new,
      ),
    );

    await tester.tap(find.text('START'));
    await tester.pump(WalkingSettings.prepare + const Duration(seconds: 47));
    await tester.pump(const Duration(milliseconds: 600));
    await saveScreenshot(tester, '../../docs/images/walking-timer.png');

    await tester.tap(find.text('STOP'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('3 tracks'), 200);
    await tester.tap(find.text('3 tracks'));
    await tester.pumpAndSettle();
    await saveScreenshot(tester, '../../docs/images/walking-music.png');
  });
}
