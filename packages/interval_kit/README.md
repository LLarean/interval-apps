# interval_kit

The Flutter layer shared by the apps.

| Folder | What |
|---|---|
| `lib/src/app` | `IntervalApp` — the application shell every app is built from |
| `lib/src/workout` | `WorkoutController` and the main `WorkoutScreen` |
| `lib/src/widgets` | `ProgressRing`, `TimerFace`, `PillButton`, `ValueStepper`, `SettingLink`, `SettingsPage` |
| `lib/src/settings` | `AppLanguage`, `IntRange` and the setting steppers |
| `lib/src/audio` | `Cue`s and the players that play them |
| `lib/src/theme` | The palette and theme inherited from the Unity app |
| `lib/src/l10n` | Strings used by the shared widgets |
| `assets` | Ubuntu font and cue sounds — see [CREDITS.md](../../CREDITS.md) |

```sh
flutter test
flutter gen-l10n   # after editing lib/src/l10n/*.arb
```
