@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_testing/interval_testing.dart';
import 'package:tabata/src/app.dart';
import 'package:tabata/src/settings/tabata_settings.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('README screenshots', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      TabataApp(
        settings: ValueNotifier(
          const TabataSettings(language: AppLanguage.english),
        ),
        cues: const SilentCuePlayer(),
        version: '0.1.0',
        keepScreenOn: ({required enabled}) async {},
      ),
    );

    await tester.tap(find.text('START'));
    await tester.pump(const Duration(seconds: 18));
    await tester.pump(const Duration(milliseconds: 600));
    await saveScreenshot(tester, '../../docs/images/tabata-timer.png');

    await tester.tap(find.text('STOP'));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await saveScreenshot(tester, '../../docs/images/tabata-settings.png');
  });
}
