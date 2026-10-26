import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:tabata/src/settings/tabata_settings.dart';

void main() {
  test('defaults to the classic 4-minute protocol after a countdown', () {
    final plan = const TabataSettings(language: AppLanguage.english).toPlan();

    expect(plan.rounds, 8);
    expect(plan.phases.first.duration, const Duration(seconds: 10));
    expect(plan.phases.last.intensity, Intensity.high);
    expect(plan.totalDuration, const Duration(minutes: 4));
  });
}
