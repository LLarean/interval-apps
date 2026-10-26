# Architecture

A short tour of the decisions behind the code, for anyone about to change it.

## Layers

```
apps/tabata, apps/walking   what makes each app different: settings, phase names
          │
packages/interval_kit       Flutter: theme, widgets, cues, workout screen, app shell
          │
packages/interval_core      pure Dart: plans, phases, the timer
```

Dependencies only point down. `interval_core` knows nothing about Flutter, so
its logic is tested on the plain Dart VM in milliseconds.

## The timer never counts ticks

The Unity version subtracted one second each time a one-second coroutine woke
up. Every late wake-up — a busy frame, a paused app — made it drift.

`IntervalTimer` instead remembers *when* it started (on a monotonic clock) and
computes the state from the true elapsed time:

- `WorkoutPlan.snapshotAt(elapsed)` is a pure function: given how long the
  workout has been running, it returns the phase and the time left.
- The timer schedules a single wake-up for the moment the displayed second is
  due to change. If the wake-up comes late, the next snapshot is still right.
- Phase changes and the end of the workout are reported as `TimerEvent`s,
  separately from the per-second `TimerSnapshot`s.

The ring on screen does not depend on snapshots for smoothness either:
`ProgressRing` animates towards empty over the remaining time and re-syncs once
a second, so the animation is fluid while the engine wakes up once per second.

## Apps are configuration

`IntervalApp` in `interval_kit` owns the workout controller, applies settings
(the language, and a new plan when the workout changes) and opens the settings
screen. An app passes in:

- its settings as a `ValueNotifier`, and how to turn them into a `WorkoutPlan`;
- what each phase is called and how time is written (`12` or `2:59`);
- its settings screen, built from the shared steppers.

Everything else is shared, which is why each app is only a few small files.

## State management

Plain Flutter: `ChangeNotifier`, `ValueNotifier` and `ListenableBuilder`. Each
app has one screen of state, so a state-management package would add more
concepts than it removes. Dependencies are passed through constructors, which
keeps every widget easy to test with fakes (`SilentCuePlayer`, a no-op
`keepScreenOn`).

## Time in tests

`StopwatchClock` uses `package:clock`, so under `fakeAsync` and `testWidgets`
it follows fake time. A whole 30-minute walk runs in a test instantly and
deterministically.

## Sound

Cues are short, preloaded MP3s played through `audioplayers`. They *duck* other
audio instead of stopping it, so music from another app keeps playing.

The walking roadmap (the user's own playlists, running with the screen off)
needs a media session and an Android foreground service. That will live in a
new package next to `interval_kit`, so the Tabata app does not pick up
permissions it does not need.

## Localisation

Strings live in ARB files: shared ones (start, stop, settings…) in
`interval_kit`, app-specific ones in each app. Generated code is committed so
the project builds right after cloning; CI checks that it is up to date.
