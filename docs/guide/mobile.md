# Mobile quickstart

Flutter app under `mobile/` (`pubspec.yaml`: package `klima`, Flutter `3.35.6`, Dart SDK `^3.5.0`).

## Install and run

```bash
cd mobile
flutter pub get
flutter run
```

List devices / pick one:

```bash
flutter devices
flutter run -d <device-id>
```

## API base URL

Default (Android emulator → host loopback) from `lib/constants/app_constants.dart`:

```text
http://10.0.2.2:8000
```

Override at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

Start the backend first ([Backend quickstart](/guide/backend)). Mobile paths match root API routes such as `/hazard/latest` and `/reports` (also mirrored under `/api/v1/...`).

## What works locally

Hazard feed, report/help/safe flows, map, go-bag, community UI, and offline **mocks** are in the Flutter tree. Full offline sync and production auth are not claimed here — see repo `STATUS.md`.

## Related

- [API overview](/api/overview)
- [Backend quickstart](/guide/backend)
