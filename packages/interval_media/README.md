# interval_media

Music for the walking app, kept out of `interval_kit` so that apps without it
do not pick up its plugins and permissions.

| Folder | What |
|---|---|
| `lib/src/music` | `Playlists` per intensity and `PhaseMusic`, which cross-fades between them as the workout changes pace |

`PhaseMusic` talks to players through the small `TrackPlayer` interface, so
its fades are tested with fake players and fake time; `JustAudioTrackPlayer`
is the real one.

```sh
flutter test
```
