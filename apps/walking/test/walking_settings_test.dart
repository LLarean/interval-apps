import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:walking/src/settings/walking_settings.dart';

void main() {
  test('defaults to 5 × (3 min fast + 3 min slow)', () {
    final plan = const WalkingSettings(language: AppLanguage.english).toPlan();

    expect(plan.rounds, 5);
    expect(
      plan.totalDuration,
      const Duration(minutes: 30) + WalkingSettings.prepare,
    );
    expect(plan.phases.last.intensity, Intensity.low);
  });
}
