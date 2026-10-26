// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Japanese Walking';

  @override
  String get phasePrepare => 'Get ready';

  @override
  String get phaseFast => 'Fast pace';

  @override
  String get phaseSlow => 'Slow pace';

  @override
  String get settingRounds => 'Rounds';

  @override
  String get settingFast => 'Fast, min';

  @override
  String get settingSlow => 'Slow, min';

  @override
  String get settingMusicFast => 'Fast pace music';

  @override
  String get settingMusicSlow => 'Slow pace music';

  @override
  String musicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: 'No music',
    );
    return '$_temp0';
  }

  @override
  String get musicEmpty =>
      'Only the sounds will play. Add your own tracks to walk to music.';

  @override
  String get musicAdd => 'Add tracks';

  @override
  String musicRemove(String title) {
    return 'Remove $title';
  }

  @override
  String get musicAddFailed => 'Could not add the tracks';
}
