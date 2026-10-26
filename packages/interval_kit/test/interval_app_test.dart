import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';

void main() {
  final plan = WorkoutPlan.intervals(
    rounds: 1,
    prepare: const Duration(seconds: 3),
    high: const Duration(seconds: 5),
    low: const Duration(seconds: 5),
  );

  Widget app({required WorkoutAttachment attach}) => IntervalApp(
    settings: ValueNotifier(0),
    planOf: (_) => plan,
    languageOf: (_) => AppLanguage.english,
    cues: const SilentCuePlayer(),
    keepScreenOn: ({required enabled}) async {},
    onGenerateTitle: (_) => 'Test',
    localizationsDelegates: const [],
    supportedLocales: const [Locale('en')],
    phaseLabel: (_, phase) => phase.intensity.name,
    formatTime: (snapshot) => '${snapshot.remainingSeconds}',
    settingsBuilder: (_) => const SizedBox(),
    attach: attach,
  );

  testWidgets('attaches to the workout once and detaches on dispose', (
    tester,
  ) async {
    final attached = <WorkoutController>[];
    var detached = 0;

    await tester.pumpWidget(
      app(
        attach: (workout) {
          attached.add(workout);
          return () => detached++;
        },
      ),
    );
    await tester.pump();

    expect(attached, hasLength(1));
    expect(attached.single.plan, plan);
    expect(detached, 0);

    await tester.pumpWidget(const SizedBox());

    expect(detached, 1);
  });
}
