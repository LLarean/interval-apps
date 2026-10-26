import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/interval_colors.dart';

/// A circular countdown that empties clockwise from the top.
///
/// The ring shows [remainingFraction]. While [drainOver] is non-null it keeps
/// draining smoothly towards empty over that duration, so the caller only
/// needs to update it when the remaining time is re-measured (once a second
/// is plenty) instead of every frame.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    required this.remainingFraction,
    required this.color,
    this.drainOver,
    this.child,
    super.key,
  });

  final double remainingFraction;
  final Color color;
  final Duration? drainOver;
  final Widget? child;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  static const _colorDuration = Duration(milliseconds: 500);

  late final AnimationController _fraction = AnimationController(
    vsync: this,
    value: widget.remainingFraction,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingFraction != oldWidget.remainingFraction ||
        widget.drainOver != oldWidget.drainOver) {
      _sync();
    }
  }

  void _sync() {
    _fraction.value = widget.remainingFraction;
    final drainOver = widget.drainOver;
    if (drainOver != null && drainOver > Duration.zero) {
      _fraction.animateTo(0, duration: drainOver);
    }
  }

  @override
  void dispose() {
    _fraction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.color),
      duration: _colorDuration,
      builder: (context, color, child) => CustomPaint(
        painter: _RingPainter(
          fraction: _fraction,
          color: color ?? widget.color,
        ),
        child: child,
      ),
      child: AspectRatio(aspectRatio: 1, child: Center(child: widget.child)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color})
    : super(repaint: fraction);

  final Animation<double> fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide * 0.06;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - strokeWidth) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      paint..color = IntervalColors.surface,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      -math.pi * 2 * fraction.value,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.fraction != fraction;
}
