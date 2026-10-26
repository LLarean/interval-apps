import 'package:clock/clock.dart';

/// A source of steadily increasing time, unaffected by wall-clock changes.
abstract interface class MonotonicClock {
  Duration get now;
}

/// [MonotonicClock] backed by a stopwatch that starts on creation.
///
/// The stopwatch comes from `package:clock`, so it follows fake time in
/// tests run under `fakeAsync` or `testWidgets`.
final class StopwatchClock implements MonotonicClock {
  StopwatchClock() : _stopwatch = clock.stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  Duration get now => _stopwatch.elapsed;
}
