import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';

void main() {
  test('stores a picked theme and nothing for the device theme', () {
    expect(ThemeMode.light.code, 'light');
    expect(ThemeMode.dark.code, 'dark');
    expect(ThemeMode.system.code, isNull);

    for (final mode in ThemeMode.values) {
      expect(ThemePreference.fromCode(mode.code), mode);
    }
    expect(ThemePreference.fromCode('sepia'), ThemeMode.system);
  });
}
