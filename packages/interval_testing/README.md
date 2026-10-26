# interval_testing

Test helpers for the apps. Only ever a `dev_dependency`.

- `loadAppFonts()` — loads the Ubuntu and Material Icons fonts, so widget
  tests render real text.
- `usePhoneScreen(tester)` — a portrait, phone-sized test window.
- `saveScreenshot(tester, path)` — writes the current frame as a PNG; used to
  generate the README images.
