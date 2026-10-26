import 'package:interval_core/interval_core.dart';
import 'package:test/test.dart';

void main() {
  group('WorkoutPlan.intervals', () {
    test('builds the classic Tabata sequence without a trailing rest', () {
      final plan = WorkoutPlan.intervals(
        rounds: 2,
        prepare: const Duration(seconds: 10),
        high: const Duration(seconds: 20),
        low: const Duration(seconds: 10),
        lowAfterLastRound: false,
      );

      expect(plan.phases.map((phase) => phase.intensity), [
        Intensity.prepare,
        Intensity.high,
        Intensity.low,
        Intensity.high,
      ]);
      expect(plan.phases.map((phase) => phase.round), [0, 1, 1, 2]);
      expect(plan.rounds, 2);
      expect(plan.totalDuration, const Duration(seconds: 60));
    });

    test('keeps the trailing low phase for interval walking', () {
      final plan = WorkoutPlan.intervals(
        rounds: 5,
        high: const Duration(minutes: 3),
        low: const Duration(minutes: 3),
      );

      expect(plan.phases, hasLength(10));
      expect(plan.phases.last.intensity, Intensity.low);
      expect(plan.totalDuration, const Duration(minutes: 30));
    });

    test('drops phases without duration', () {
      final plan = WorkoutPlan.intervals(
        rounds: 1,
        high: const Duration(seconds: 5),
        low: const Duration(seconds: 5),
      );

      expect(plan.phases.first.intensity, Intensity.high);
    });

    test('compares by phases', () {
      WorkoutPlan build() => WorkoutPlan.intervals(
        rounds: 3,
        high: const Duration(seconds: 20),
        low: const Duration(seconds: 10),
      );

      expect(build(), build());
      expect(build().hashCode, build().hashCode);
    });

    test('rejects a plan without rounds', () {
      expect(
        () => WorkoutPlan.intervals(
          rounds: 0,
          high: const Duration(seconds: 1),
          low: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('WorkoutPlan.snapshotAt', () {
    final plan = WorkoutPlan.intervals(
      rounds: 2,
      prepare: const Duration(seconds: 10),
      high: const Duration(seconds: 20),
      low: const Duration(seconds: 10),
      lowAfterLastRound: false,
    );

    test('starts in the first phase with all of its time left', () {
      final snapshot = plan.snapshotAt(Duration.zero);

      expect(snapshot.phase.intensity, Intensity.prepare);
      expect(snapshot.remainingSeconds, 10);
      expect(snapshot.remainingFraction, 1.0);
      expect(snapshot.isFinished, isFalse);
    });

    test('rounds the remaining time up like a countdown', () {
      final snapshot = plan.snapshotAt(const Duration(milliseconds: 9001));

      expect(snapshot.remainingSeconds, 1);
    });

    test('moves to the next phase exactly at the boundary', () {
      final snapshot = plan.snapshotAt(const Duration(seconds: 10));

      expect(snapshot.phase.intensity, Intensity.high);
      expect(snapshot.phase.round, 1);
      expect(snapshot.remainingSeconds, 20);
    });

    test('is finished once all the time has passed', () {
      final snapshot = plan.snapshotAt(const Duration(minutes: 5));

      expect(snapshot.isFinished, isTrue);
      expect(snapshot.remainingSeconds, 0);
      expect(snapshot.phase.round, 2);
    });
  });
}
