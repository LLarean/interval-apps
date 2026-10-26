# interval_core

The workout engine shared by the apps. Pure Dart — no Flutter dependency.

```dart
final plan = WorkoutPlan.intervals(
  rounds: 5,
  high: const Duration(minutes: 3),
  low: const Duration(minutes: 3),
);

final timer = IntervalTimer(plan)
  ..events.listen(print) // PhaseStarted(...), WorkoutFinished()
  ..snapshots.listen((snapshot) => print(snapshot.remainingSeconds))
  ..start();
```

- `WorkoutPlan` — an immutable list of `Phase`s, with a builder for the usual
  "prepare, then N × (high, low)" shape.
- `IntervalTimer` — runs a plan against a monotonic clock; see
  [the architecture notes](../../docs/ARCHITECTURE.md) for why it never drifts.

```sh
dart test
```
