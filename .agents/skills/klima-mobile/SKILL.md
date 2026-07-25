---
name: klima-mobile
description: >-
  Flutter conventions for Klima mobile/. Use when editing screens, models,
  providers, or services — matches the existing Provider-based app, not a forced
  BLoC clean-architecture rewrite.
---

# Klima Mobile

Paraphrased lightly from personal Flutter guidance, **adapted to this tree**.

## Reality of `mobile/`

```text
lib/
  constants/   theme, mocks, app constants
  models/      Hazard, Report, SafeZone, …
  providers/   ChangeNotifier + Provider
  screens/     UI routes
  services/    api, location, notification, storage
  widgets/     shared UI
```

Do **not** force a BLoC/get_it/feature-folder migration unless the user explicitly asks. Match Provider + current folders.

## Rules

1. Keep API DTOs aligned with `lib/models/*` and backend OpenAPI when endpoints exist.
2. Prefer unit tests for models (`test/models/`) over brittle full-app widget tests that need Firebase.
3. Offline-first mocks stay honest — do not pretend live PAGASA sync exists.
4. Run `flutter analyze` and `flutter test` before claiming mobile work done.
5. Assets placeholders under `assets/` are intentional; do not delete `.gitkeep` files casually.

## Test commands

```bash
cd mobile
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```
