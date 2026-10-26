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
}
