@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_testing/interval_testing.dart';
import 'package:walking/src/app.dart';
import 'package:walking/src/settings/walking_settings.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('README screenshots', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      WalkingApp(
        settings: ValueNotifier(
          const WalkingSettings(language: AppLanguage.english),
        ),
        cues: const SilentCuePlayer(),
        version: '0.1.0',
        keepScreenOn: ({required enabled}) async {},
      ),
    );

    await tester.tap(find.text('START'));
    await tester.pump(WalkingSettings.prepare + const Duration(seconds: 47));
    await tester.pump(const Duration(milliseconds: 600));
    await saveScreenshot(tester, '../../docs/images/walking-timer.png');

    await tester.tap(find.text('STOP'));
    await tester.pumpAndSettle();
  });
}
