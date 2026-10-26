# Contributing

Thanks for helping! This guide covers how the repository is organised and
what a good change looks like.

## Ground rules

- **Small, focused pull requests.** One idea per PR, ideally a few commits.
- **Tests come with the change.** Engine logic belongs in `interval_core` and
  is tested there; screens get widget tests.
- **Shared first.** If both apps need something, it goes into a package, not
  into each app.
- **CI must be green.** It runs the same commands you can run locally (below).

## Setup

1. Install the Flutter version pinned in the root [`pubspec.yaml`](pubspec.yaml)
   (`environment: flutter:`).
2. For Android builds, install the Android SDK and accept its licences with
   `flutter doctor --android-licenses`.
3. Run `flutter pub get` once in the repository root. The repository is a
   [pub workspace](https://dart.dev/tools/pub/workspaces), so this resolves
   every package and app together and creates a single `pubspec.lock`.

## Before you push

```sh
dart format .
flutter analyze
(cd packages/interval_core && dart test)
for dir in packages/interval_kit packages/interval_media apps/tabata apps/walking; do (cd "$dir" && flutter test); done
```

If you changed text, edit the `.arb` files and run `flutter gen-l10n` in that
package or app. The generated files are committed, and CI fails if they are
out of date.

If you changed how a screen looks, regenerate the README screenshots:

```sh
cd apps/tabata && flutter test --tags screenshots --run-skipped
cd apps/walking && flutter test --tags screenshots --run-skipped
```

## Commits

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org):

```
<type>(<scope>): <summary in the imperative, lower case>
```

- **Types:** `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`,
  `build`, `ci`, `chore`.
- **Scopes:** `core`, `kit`, `testing`, `tabata`, `walking`, or none when a
  change spans the repository.
- Explain *why* in the body when the summary does not make it obvious.

Examples from the history: `feat(core): add drift-free interval workout
engine`, `fix(kit): scale the countdown ring with the screen`.

## Adding a language

1. Add a value to `AppLanguage` in `interval_kit`.
2. Add `kit_<code>.arb` to `packages/interval_kit/lib/src/l10n` and
   `app_<code>.arb` to `lib/l10n` of every app.
3. Run `flutter gen-l10n` in each of them.
4. Add `values-<code>/strings.xml` with the app name under
   `android/app/src/main/res` of every app.

## Releases

Each app is released on its own, from a tag named after it:

```sh
git tag tabata-v1.1.0   # or walking-v0.2.0
git push origin tabata-v1.1.0
```

The [release workflow](.github/workflows/release.yml) builds a signed APK and
App Bundle and attaches them to a GitHub release. Bump `version:` in the app's
`pubspec.yaml` first — the part after `+` is the Android version code and must
grow with every store upload.

### Signing

Release signing reads `android/key.properties`, which is git-ignored:

```properties
storeFile=upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`storeFile` is relative to `android/app`. Without the file, release builds are
signed with the debug key, which is fine for testing but not for a store.

For CI, add these repository secrets:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
| `ANDROID_KEY_ALIAS` | the key alias |
| `ANDROID_KEY_PASSWORD` | the key password |

The Tabata app keeps the application id `com.LLarean.TabataTimer` of the Unity
version. To update the existing store listing it must be signed with **the same
key** the Unity builds used.
