import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_kit/interval_kit.dart';

void main() {
  /// Expects the ring drawn half full: the track, then the half arc.
  void expectHalfFull(WidgetTester tester) {
    expect(
      tester.renderObject(
        find.descendant(
          of: find.byType(ProgressRing),
          matching: find.byType(CustomPaint),
        ),
      ),
      paints
        ..arc(sweepAngle: math.pi * 2)
        ..arc(sweepAngle: -math.pi),
    );
  }

  Future<void> pumpRing(WidgetTester tester) => tester.pumpWidget(
    const Center(
      child: SizedBox.square(
        dimension: 200,
        child: ProgressRing(
          remainingFraction: 1,
          drainOver: Duration(seconds: 20),
          color: Color(0xFF00FF00),
        ),
      ),
    ),
  );

  testWidgets('drains in step with the clock', (tester) async {
    await pumpRing(tester);
    await tester.pump(const Duration(seconds: 10));
    expectHalfFull(tester);
  });

  testWidgets('keeps real time when the system turns animations off', (
    tester,
  ) async {
    // Android does this in battery saver mode or with "Remove animations".
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpRing(tester);
    await tester.pump(const Duration(seconds: 10));
    expectHalfFull(tester);
  });
}
