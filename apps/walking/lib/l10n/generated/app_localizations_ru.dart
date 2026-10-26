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

  @override
  String get settingMusicFast => 'Музыка быстрого темпа';

  @override
  String get settingMusicSlow => 'Музыка медленного темпа';

  @override
  String musicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
      zero: 'Без музыки',
    );
    return '$_temp0';
  }

  @override
  String get musicEmpty =>
      'Будут звучать только сигналы. Добавьте свои треки, чтобы идти под музыку.';

  @override
  String get musicAdd => 'Добавить треки';

  @override
  String musicRemove(String title) {
    return 'Убрать $title';
  }

  @override
  String get musicAddFailed => 'Не удалось добавить треки';
}
