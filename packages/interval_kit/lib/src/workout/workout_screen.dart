import 'package:flutter/material.dart';
import 'package:interval_core/interval_core.dart';

import '../l10n/generated/kit_localizations.dart';
import '../theme/interval_colors.dart';
import '../widgets/pill_button.dart';
import '../widgets/timer_face.dart';
import 'workout_controller.dart';

/// The main screen of every app: countdown ring, phase, start and reset.
///
/// Apps only decide how phases are named and how time is written.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({
    required this.controller,
    required this.phaseLabel,
    required this.formatTime,
    required this.onOpenSettings,
    super.key,
  });

  final WorkoutController controller;
  final String Function(BuildContext context, Phase phase) phaseLabel;
  final String Function(TimerSnapshot snapshot) formatTime;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = KitLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final snapshot = controller.snapshot;
            final running = controller.isRunning;
            final status = controller.status == TimerStatus.paused
                ? l10n.paused
                : phaseLabel(context, snapshot.phase);

            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: l10n.settings,
                    padding: const EdgeInsets.all(16),
                    onPressed: onOpenSettings,
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: TimerFace(
                      time: formatTime(snapshot),
                      caption:
                          '${snapshot.phase.round}/${snapshot.plan.rounds}',
                      remainingFraction: snapshot.remainingFraction,
                      color: running
                          ? IntervalColors.forIntensity(
                              snapshot.phase.intensity,
                            )
                          : IntervalColors.idle,
                      drainOver: running ? snapshot.remainingInPhase : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    status.toUpperCase(),
                    style: textTheme.titleLarge,
                  ),
                ),
                const Spacer(flex: 2),
                PillButton(
                  label: running ? l10n.stop : l10n.start,
                  onPressed: controller.toggle,
                ),
                const Spacer(),
                FlatTextButton(label: l10n.reset, onPressed: controller.reset),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
