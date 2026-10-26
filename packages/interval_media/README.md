# interval_media

Music and the media session for the walking app, kept out of `interval_kit`
so that apps without them do not pick up their plugins and permissions.

| Folder | What |
|---|---|
| `lib/src/music` | `MusicLibrary`, which keeps the user's tracks for each intensity, and `PhaseMusic`, which cross-fades between them as the workout changes pace |
| `lib/src/session` | `WorkoutMediaSession` — the notification and lock-screen controls, and the foreground service that keeps the workout running with the screen off |

`PhaseMusic` talks to players through the small `TrackPlayer` interface, so
its fades are tested with fake players and fake time; `JustAudioTrackPlayer`
is the real one. `WorkoutMediaSession` is tested the same way, without the
platform service.

An app using the session must declare the service in its Android manifest and
make its activity an `AudioServiceActivity`; see `apps/walking`.

```sh
flutter test
```
