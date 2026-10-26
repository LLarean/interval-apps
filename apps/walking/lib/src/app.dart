import 'package:flutter/widgets.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';

import '../l10n/generated/app_localizations.dart';
import 'settings/settings_screen.dart';
import 'settings/walking_settings.dart';

class WalkingApp extends StatelessWidget {
  const WalkingApp({
    required this.settings,
    required this.cues,
    required this.version,
    this.keepScreenOn = keepScreenOnWithWakelock,
    this.music,
    this.createPlayer = JustAudioTrackPlayer.new,
    super.key,
  });

  final ValueNotifier<WalkingSettings> settings;
  final CuePlayer cues;
  final String version;
  final KeepScreenOn keepScreenOn;

  /// The user's playlists, or `null` where music is not supported.
  final MusicLibrary? music;
  final TrackPlayer Function() createPlayer;

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
          SettingsScreen(settings: settings, version: version, music: music),
      attach: _attachMusic,
    );
  }

  VoidCallback _attachMusic(WorkoutController workout) {
    final music = this.music;
    if (music == null) return () {};
    return PhaseMusic(
      workout: workout,
      playlists: music,
      createPlayer: createPlayer,
    ).dispose;
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
