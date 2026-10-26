import 'package:flutter/material.dart';
import 'package:interval_kit/interval_kit.dart';

import '../../l10n/generated/app_localizations.dart';
import 'walking_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.settings,
    required this.version,
    super.key,
  });

  final ValueNotifier<WalkingSettings> settings;
  final String version;

  void _update(WalkingSettings Function(WalkingSettings) change) =>
      settings.value = change(settings.value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: settings,
      builder: (context, current, _) => SettingsPage(
        title: KitLocalizations.of(context).settings,
        footer: Text(version, style: Theme.of(context).textTheme.labelSmall),
        children: [
          LanguageStepper(
            value: current.language,
            onChanged: (value) => _update((s) => s.copyWith(language: value)),
          ),
          IntSettingStepper(
            label: l10n.settingRounds,
            value: current.rounds,
            range: WalkingSettings.roundsRange,
            onChanged: (value) => _update((s) => s.copyWith(rounds: value)),
          ),
          IntSettingStepper(
            label: l10n.settingFast,
            value: current.fastMinutes,
            range: WalkingSettings.fastRange,
            onChanged: (value) =>
                _update((s) => s.copyWith(fastMinutes: value)),
          ),
          IntSettingStepper(
            label: l10n.settingSlow,
            value: current.slowMinutes,
            range: WalkingSettings.slowRange,
            onChanged: (value) =>
                _update((s) => s.copyWith(slowMinutes: value)),
          ),
        ],
      ),
    );
  }
}
