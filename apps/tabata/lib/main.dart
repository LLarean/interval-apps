import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/app.dart';
import 'src/settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (store, cues, packageInfo) = await (
    SettingsStore.open(),
    AssetCuePlayer.load(),
    PackageInfo.fromPlatform(),
  ).wait;

  final settings = ValueNotifier(
    store.load(
      deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
    ),
  );
  settings.addListener(() => unawaited(store.save(settings.value)));

  runApp(
    TabataApp(settings: settings, cues: cues, version: packageInfo.version),
  );
}
