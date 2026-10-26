/// Test helpers shared by the apps.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real app fonts, so screenshots show text instead of boxes.
Future<void> loadAppFonts() async {
  final fonts = {
    'packages/interval_kit/Ubuntu': [
      'packages/interval_kit/assets/fonts/Ubuntu-R.ttf',
      'packages/interval_kit/assets/fonts/Ubuntu-M.ttf',
      'packages/interval_kit/assets/fonts/Ubuntu-B.ttf',
    ],
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
  };

  for (final MapEntry(key: family, value: assets) in fonts.entries) {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

/// Renders the screen like a phone in portrait orientation.
void usePhoneScreen(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2280)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

/// Saves what is on screen as a PNG at [path].
Future<void> saveScreenshot(WidgetTester tester, String path) async {
  final element = tester.binding.rootElement!;
  await tester.runAsync(() async {
    final image = await captureImage(element);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File(path)..parent.createSync(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}
