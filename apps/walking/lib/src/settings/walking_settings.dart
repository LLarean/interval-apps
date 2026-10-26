import 'package:flutter/foundation.dart';
import 'package:interval_kit/interval_kit.dart';

/// Everything the user can configure in the walking app.
@immutable
final class WalkingSettings {
  const WalkingSettings({
    required this.language,
    this.rounds = 5,
    this.fastMinutes = 3,
    this.slowMinutes = 3,
  });

  static const roundsRange = IntRange(1, 20);
  static const fastRange = IntRange(1, 10);
  static const slowRange = IntRange(1, 10);

  /// Time to put the phone away before the first fast interval.
  static const prepare = Duration(seconds: 10);

  final AppLanguage language;
  final int rounds;
  final int fastMinutes;
  final int slowMinutes;

  /// Rounds of fast then slow walking; the last slow interval is the
  /// cool-down. The defaults give the classic 30-minute session.
  WorkoutPlan toPlan() => WorkoutPlan.intervals(
    rounds: rounds,
    prepare: prepare,
    high: Duration(minutes: fastMinutes),
    low: Duration(minutes: slowMinutes),
  );

  WalkingSettings copyWith({
    AppLanguage? language,
    int? rounds,
    int? fastMinutes,
    int? slowMinutes,
  }) => WalkingSettings(
    language: language ?? this.language,
    rounds: rounds ?? this.rounds,
    fastMinutes: fastMinutes ?? this.fastMinutes,
    slowMinutes: slowMinutes ?? this.slowMinutes,
  );

  @override
  bool operator ==(Object other) =>
      other is WalkingSettings &&
      other.language == language &&
      other.rounds == rounds &&
      other.fastMinutes == fastMinutes &&
      other.slowMinutes == slowMinutes;

  @override
  int get hashCode => Object.hash(language, rounds, fastMinutes, slowMinutes);
}
