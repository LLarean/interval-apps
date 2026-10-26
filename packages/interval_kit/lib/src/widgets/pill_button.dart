import 'package:flutter/material.dart';

import '../theme/interval_colors.dart';
import 'press_scale.dart';

/// The large rounded primary action, e.g. START / STOP.
class PillButton extends StatelessWidget {
  const PillButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onPressed != null,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: IntervalColors.primary,
          foregroundColor: IntervalColors.onPrimary,
          minimumSize: const Size(248, 68),
          shape: const StadiumBorder(),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: Text(label.toUpperCase()),
      ),
    );
  }
}

/// A borderless secondary action, e.g. RESET.
class FlatTextButton extends StatelessWidget {
  const FlatTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onPressed != null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: IntervalColors.primary,
          minimumSize: const Size(160, 56),
          shape: const StadiumBorder(),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: Text(label.toUpperCase()),
      ),
    );
  }
}
