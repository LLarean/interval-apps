<div align="center">

# Interval Apps

**Free, open-source interval timers for Android and the web.**<br>
No ads, no account, no tracking. Works offline.

[![CI](https://github.com/LLarean/interval-apps/actions/workflows/ci.yml/badge.svg)](https://github.com/LLarean/interval-apps/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)](https://flutter.dev)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

<img src="docs/images/tabata-timer.png" width="240" alt="Tabata timer during a work interval">&nbsp;&nbsp;
<img src="docs/images/tabata-settings.png" width="240" alt="Tabata settings">&nbsp;&nbsp;
<img src="docs/images/walking-timer.png" width="240" alt="Japanese walking timer at a fast pace">

</div>

## The apps

| | App | What it does | Try it |
|---|---|---|---|
| <img src="apps/tabata/assets/icon/icon.png" width="48" alt=""> | **[Tabata Timer](apps/tabata)** | The classic protocol — 20 s of work, 10 s of rest, 8 rounds — with every number adjustable. | [Web](https://llarean.github.io/interval-apps/tabata/) · [RuStore](https://www.rustore.ru/catalog/app/com.LLarean.TabataTimer) |
| <img src="apps/walking/assets/icon/icon.png" width="48" alt=""> | **[Japanese Walking](apps/walking)** | Interval walking: 3 minutes fast, 3 minutes slow, 5 times — a 30-minute session. | [Web](https://llarean.github.io/interval-apps/walking/) |

Both apps speak English and Russian, play a sound when the phase changes and keep the screen on while the timer runs.

## Why a monorepo

The two apps are separate products with their own store listings, but they share almost everything underneath:

```mermaid
flowchart LR
  core["interval_core<br><sub>pure Dart engine</sub>"] --> kit["interval_kit<br><sub>theme · widgets · cues · app shell</sub>"]
  kit --> tabata["apps/tabata"]
  kit --> walking["apps/walking"]
  testing["interval_testing<br><sub>test helpers</sub>"] -.-> tabata
  testing -.-> walking
```

| Path | Contents |
|---|---|
| [`packages/interval_core`](packages/interval_core) | The workout engine: plans, phases and a timer that never drifts. Pure Dart, no Flutter. |
| [`packages/interval_kit`](packages/interval_kit) | Everything the apps share on screen: theme, widgets, sound cues, the workout screen and the app shell. |
| [`packages/interval_testing`](packages/interval_testing) | Helpers for widget tests and README screenshots. |
| [`apps/tabata`](apps/tabata) | The Tabata timer. Settings and phase names only. |
| [`apps/walking`](apps/walking) | The Japanese walking timer. Settings and phase names only. |

A fix in the engine or a widget lands in both apps with the next build. Read more in [the architecture notes](docs/ARCHITECTURE.md).

## Getting started

You need [Flutter 3.47](https://docs.flutter.dev/get-started/install) — the exact version is pinned in [`pubspec.yaml`](pubspec.yaml) — and, for Android builds, the Android SDK.

```sh
git clone https://github.com/LLarean/interval-apps.git
cd interval-apps
flutter pub get          # resolves the whole workspace at once

cd apps/tabata           # or apps/walking
flutter run -d chrome    # or pick an Android device
```

### Everyday commands

| Task | Command |
|---|---|
| Format | `dart format .` |
| Analyze everything | `flutter analyze` |
| Test the engine | `cd packages/interval_core && dart test` |
| Test a Flutter package or app | `cd <dir> && flutter test` |
| Regenerate screenshots | `cd apps/<app> && flutter test --tags screenshots --run-skipped` |
| Regenerate launcher icons | `cd apps/<app> && dart run flutter_launcher_icons` |
| Build a release | `cd apps/<app> && flutter build apk` / `flutter build web` |

CI runs the same checks on every pull request; see [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow.

## Roadmap

- [x] Tabata timer ported from Unity, with the original look
- [x] Japanese walking timer with sound cues
- [x] Web versions on GitHub Pages
- [ ] Walking: separate playlists for fast and slow intervals from the user's own music, cross-faded at every phase change
- [ ] Walking: keep running with the screen off (foreground service, lock-screen controls)
- [ ] Voice announcements as an alternative to sounds
- [ ] iOS builds

## History

The Tabata timer started as a [Unity project](https://github.com/LLarean/tabata-timer). It was rewritten in Flutter to get a much smaller app, a faster web version and native audio features the walking app needs. The design, sounds and settings carried over unchanged.

## Contributing

Bug reports, ideas and pull requests are welcome — start with [CONTRIBUTING.md](CONTRIBUTING.md).

## Credits and license

Sounds come from [Freesound](https://freesound.org) and the font is [Ubuntu](https://design.ubuntu.com/font); authors and licenses are listed in [CREDITS.md](CREDITS.md).

The code is licensed under the [Apache License 2.0](LICENSE).
