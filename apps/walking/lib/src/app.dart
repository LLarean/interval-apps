import 'package:flutter/widgets.dart';
import 'package:interval_kit/interval_kit.dart';

import '../l10n/generated/app_localizations.dart';
import 'settings/settings_screen.dart';
import 'settings/walking_settings.dart';

class WalkingApp extends StatelessWidget {
  const WalkingApp({
    required this.settings,
    required this.cues,
    required this.version,
    this.keepScreenOn = keepScreenOnWithWakelock,
    super.key,
  });

  final ValueNotifier<WalkingSettings> settings;
  final CuePlayer cues;
  final String version;
  final KeepScreenOn keepScreenOn;

  @override
  Widget build(BuildContext context) {
    return IntervalApp(
      settings: settings,
      planOf: (settings) => settings.toPlan(),
      languageOf: (settings) => settings.language,
      cues: cues,
      keepScreenOn: keepScreenOn,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      phaseLabel: _phaseLabel,
      formatTime: _formatTime,
      settingsBuilder: (_) =>
          SettingsScreen(settings: settings, version: version),
    );
  }

  /// `m:ss`, e.g. `2:59`.
  static String _formatTime(TimerSnapshot snapshot) {
    final seconds = snapshot.remainingSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  static String _phaseLabel(BuildContext context, Phase phase) {
    final l10n = AppLocalizations.of(context);
    return switch (phase.intensity) {
      Intensity.prepare => l10n.phasePrepare,
      Intensity.high => l10n.phaseFast,
      Intensity.low => l10n.phaseSlow,
    };
  }
}
