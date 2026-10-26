import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';

void main() {
  group('IntRange', () {
    const range = IntRange(2, 4);

    test('steps inside the bounds', () {
      expect(range.step(3, 1), 4);
      expect(range.step(3, -1), 2);
    });

    test('refuses to step outside the bounds', () {
      expect(range.step(4, 1), isNull);
      expect(range.step(2, -1), isNull);
    });

    test('clamps stored values', () {
      expect(range.clamp(100), 4);
      expect(range.clamp(-1), 2);
    });
  });

  group('AppLanguage', () {
    test('picks the first supported device language', () {
      expect(
        AppLanguage.fromLocales(const [Locale('de'), Locale('ru')]),
        AppLanguage.russian,
      );
    });

    test('falls back to English', () {
      expect(
        AppLanguage.fromLocales(const [Locale('ja')]),
        AppLanguage.english,
      );
      expect(AppLanguage.fromCode(null), AppLanguage.english);
    });
  });
}
