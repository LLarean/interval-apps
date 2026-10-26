# Architecture

A short tour of the decisions behind the code, for anyone about to change it.

## Layers

```
apps/tabata, apps/walking   what makes each app different: settings, phase names
          │        │
          │   packages/interval_media   music per pace, media session (walking only)
          │        │
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
- its settings screen, built from the shared steppers;
- optionally, an `attach` callback for anything else that should follow the
  workout. The walking app attaches its music and media session there.

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

### Music and the screen off

The walking app's extras live in `interval_media`, so the Tabata app does not
pick up their plugins and Android permissions.

- `MusicLibrary` copies the files the user picks into the app's own storage,
  one folder per intensity. The picker's copies and `content://` links can
  vanish; the library's files cannot.
- `PhaseMusic` keeps one player per intensity and follows the workout: silence
  during the countdown, a three-second cross-fade at every change of pace,
  an instant stop on pause. Each player keeps its position, so the next fast
  phase continues the fast music. Players hide behind `TrackPlayer`, which
  lets the fades be tested with fake time.
- `WorkoutMediaSession` (on top of `audio_service`) shows the phase as "now
  playing" in the notification and on the lock screen, and maps its buttons
  and headset clicks to the workout. While the workout runs, the media service
  stays in the foreground and holds a partial wake lock, so the Dart timer
  keeps firing with the screen off. A paused or finished workout releases
  both.

Our cues ask for transient, duckable audio focus, so Android lowers the music
under every beep and brings it back afterwards.

## Localisation

Strings live in ARB files: shared ones (start, stop, settings…) in
`interval_kit`, app-specific ones in each app. Generated code is committed so
the project builds right after cloning; CI checks that it is up to date.
