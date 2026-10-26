import 'dart:ui';

/// The languages the apps are translated into.
enum AppLanguage {
  russian('ru'),
  english('en');

  const AppLanguage(this.code);

  /// ISO 639-1 code, also used as the stored value.
  final String code;

  Locale get locale => Locale(code);

  /// Short label shown in the language switch, e.g. `RU`.
  String get label => code.toUpperCase();

  static AppLanguage fromCode(String? code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => english,
  );

  /// The best match for the device [locales], falling back to English.
  static AppLanguage fromLocales(List<Locale> locales) {
    for (final locale in locales) {
      for (final language in values) {
        if (language.code == locale.languageCode) {
          return language;
        }
      }
    }
    return english;
  }
}
