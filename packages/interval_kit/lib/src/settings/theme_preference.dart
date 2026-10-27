import 'package:flutter/material.dart';

/// Stores a [ThemeMode] as text.
///
/// [ThemeMode.system] has no stored value, so an app keeps following the
/// device until the user picks a theme.
extension ThemePreference on ThemeMode {
  /// The stored value, or `null` for [ThemeMode.system].
  String? get code => switch (this) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => null,
  };

  static ThemeMode fromCode(String? code) => switch (code) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
