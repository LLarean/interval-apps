import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen on with the platform wakelock.
Future<void> keepScreenOnWithWakelock({required bool enabled}) =>
    WakelockPlus.toggle(enable: enabled);
