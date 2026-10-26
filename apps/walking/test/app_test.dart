import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';
import 'package:walking/src/app.dart';
import 'package:walking/src/settings/walking_settings.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, AppLanguage language) async {
    await tester.pumpWidget(
      WalkingApp(
        settings: ValueNotifier(WalkingSettings(language: language)),
        cues: const SilentCuePlayer(),
        version: '1.2.3',
        keepScreenOn: ({required enabled}) async {},
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts with a short countdown', (tester) async {
    await pumpApp(tester, AppLanguage.english);

    expect(find.text('0:10'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('GET READY'), findsOneWidget);
  });

  testWidgets('moves on to the fast pace', (tester) async {
    await pumpApp(tester, AppLanguage.russian);

    await tester.tap(find.text('СТАРТ'));
    await tester.pump(WalkingSettings.prepare);

    expect(find.text('БЫСТРЫЙ ТЕМП'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);

    await tester.tap(find.text('СТОП'));
    await tester.pumpAndSettle();
  });

  testWidgets('plays the fast playlist while walking fast', (tester) async {
    final root = Directory.systemTemp.createTempSync('walking_app_');
    addTearDown(() => root.deleteSync(recursive: true));
    final music = (await tester.runAsync(() async {
      final music = await MusicLibrary.open(root: root);
      await music.add(Intensity.high, [
        (name: 'fast.mp3', read: () => Stream.value(const [0])),
      ]);
      return music;
    }))!;
    final players = <RecordingTrackPlayer>[];

    await tester.pumpWidget(
      WalkingApp(
        settings: ValueNotifier(
          const WalkingSettings(language: AppLanguage.english),
        ),
        cues: const SilentCuePlayer(),
        version: '1.2.3',
        keepScreenOn: ({required enabled}) async {},
        music: music,
        createPlayer: () {
          final player = RecordingTrackPlayer();
          players.add(player);
          return player;
        },
      ),
    );
    await tester.tap(find.text('START'));
    await tester.pump(WalkingSettings.prepare + const Duration(seconds: 5));

    final [fast, slow] = players;
    expect(fast.tracks.single.title, 'fast');
    expect(fast.playing, isTrue);
    expect(fast.volume, 1);
    expect(slow.playing, isFalse);

    await tester.tap(find.text('STOP'));
    await tester.pumpAndSettle();
  });

  testWidgets('describes the walk in the notification', (tester) async {
    final session = WorkoutMediaSession();
    await tester.pumpWidget(
      WalkingApp(
        settings: ValueNotifier(
          const WalkingSettings(language: AppLanguage.russian),
        ),
        cues: const SilentCuePlayer(),
        version: '1.2.3',
        keepScreenOn: ({required enabled}) async {},
        session: session,
      ),
    );

    await tester.tap(find.text('СТАРТ'));
    await tester.pump();
    expect(session.mediaItem.value?.title, 'Приготовьтесь');
    expect(session.mediaItem.value?.artist, 'Раунд 1 из 5');

    await tester.pump(WalkingSettings.prepare + const Duration(minutes: 3));
    expect(session.mediaItem.value?.title, 'Медленный темп');
    expect(session.playbackState.value.playing, isTrue);

    await tester.tap(find.text('СТОП'));
    await tester.pumpAndSettle();
    expect(session.playbackState.value.playing, isFalse);
  });
}
