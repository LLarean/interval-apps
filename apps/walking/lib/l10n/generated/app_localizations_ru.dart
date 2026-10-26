// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Японская ходьба';

  @override
  String get phasePrepare => 'Приготовьтесь';

  @override
  String get phaseFast => 'Быстрый темп';

  @override
  String get phaseSlow => 'Медленный темп';

  @override
  String get settingRounds => 'Раунды';

  @override
  String get settingFast => 'Быстро, мин';

  @override
  String get settingSlow => 'Медленно, мин';
}
