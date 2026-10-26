import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application name.
  ///
  /// In en, this message translates to:
  /// **'Japanese Walking'**
  String get appTitle;

  /// Status during the countdown before the walk.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get phasePrepare;

  /// Status while walking briskly.
  ///
  /// In en, this message translates to:
  /// **'Fast pace'**
  String get phaseFast;

  /// Status while walking at a relaxed pace.
  ///
  /// In en, this message translates to:
  /// **'Slow pace'**
  String get phaseSlow;

  /// Label of the number of fast + slow rounds setting.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get settingRounds;

  /// Label of the fast interval length setting, in minutes.
  ///
  /// In en, this message translates to:
  /// **'Fast, min'**
  String get settingFast;

  /// Label of the slow interval length setting, in minutes.
  ///
  /// In en, this message translates to:
  /// **'Slow, min'**
  String get settingSlow;

  /// Label of the link to the playlist played while walking fast.
  ///
  /// In en, this message translates to:
  /// **'Fast pace music'**
  String get settingMusicFast;

  /// Label of the link to the playlist played while walking slowly.
  ///
  /// In en, this message translates to:
  /// **'Slow pace music'**
  String get settingMusicSlow;

  /// How many tracks a playlist has.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No music} =1{1 track} other{{count} tracks}}'**
  String musicTrackCount(int count);

  /// Shown in place of an empty playlist.
  ///
  /// In en, this message translates to:
  /// **'Only the sounds will play. Add your own tracks to walk to music.'**
  String get musicEmpty;

  /// Button that opens the file picker to add tracks to the playlist.
  ///
  /// In en, this message translates to:
  /// **'Add tracks'**
  String get musicAdd;

  /// Screen-reader label of the button that removes a track from the playlist.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String musicRemove(String title);

  /// Shown when copying the chosen files failed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the tracks'**
  String get musicAddFailed;

  /// Second line of the notification shown while walking.
  ///
  /// In en, this message translates to:
  /// **'Round {round} of {rounds}'**
  String notificationRound(int round, int rounds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
