import 'package:flutter/material.dart';

import 'progress_ring.dart';

/// The big countdown: a [ProgressRing] with the time and a caption inside.
class TimerFace extends StatelessWidget {
  const TimerFace({
    required this.time,
    required this.caption,
    required this.remainingFraction,
    required this.color,
    this.drainOver,
    super.key,
  });

  final String time;
  final String caption;
  final double remainingFraction;
  final Color color;
  final Duration? drainOver;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ProgressRing(
      remainingFraction: remainingFraction,
      color: color,
      drainOver: drainOver,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(child: Text(time, style: textTheme.displayLarge)),
            const SizedBox(height: 8),
            Text(caption, style: textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
