import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
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
}
