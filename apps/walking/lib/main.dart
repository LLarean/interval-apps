import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n/generated/app_localizations.dart';
import 'src/app.dart';
import 'src/settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (store, cues, packageInfo, music) = await (
    SettingsStore.open(),
    AssetCuePlayer.load(),
    PackageInfo.fromPlatform(),
    // Browsers cannot keep the chosen files, so the web version has no music.
    kIsWeb ? Future<MusicLibrary?>.value() : MusicLibrary.open(),
  ).wait;

  final settings = ValueNotifier(
    store.load(
      deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
    ),
  );
  settings.addListener(() => unawaited(store.save(settings.value)));

  // The web version runs only while its tab is open anyway.
  final session = kIsWeb
      ? null
      : await WorkoutMediaSession.start(
          channelName: lookupAppLocalizations(settings.value.language.locale)
              .appTitle,
          notificationIcon: 'drawable/ic_stat_walk',
        );

  runApp(
    WalkingApp(
      settings: settings,
      cues: cues,
      version: packageInfo.version,
      music: music,
      session: session,
    ),
  );
}
