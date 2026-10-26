import 'package:flutter/material.dart';

import '../theme/interval_colors.dart';
import 'press_scale.dart';

/// A labelled plate that opens a screen of its own, sized like a
/// [ValueStepper] so the two line up in a settings list.
class SettingLink extends StatelessWidget {
  const SettingLink({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;

  /// A short summary of the current choice, e.g. `3 tracks`.
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.titleMedium),
        const SizedBox(height: 10),
        PressScale(
          child: Material(
            color: IntervalColors.surface,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                width: 252,
                height: 96,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(icon, color: IntervalColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
