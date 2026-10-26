// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tabata Timer';

  @override
  String get phasePrepare => 'Get ready';

  @override
  String get phaseWork => 'Work';

  @override
  String get phaseRest => 'Rest';

  @override
  String get settingRounds => 'Rounds';

  @override
  String get settingWork => 'Work, sec';

  @override
  String get settingRest => 'Rest, sec';
}
