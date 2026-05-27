# Crab Mobile

Flutter client for the Crab super app: ride booking, food ordering, wallet,
chat, notifications, ratings, and profile flows.

## Run

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

## Build Android

```powershell
flutter build apk --debug -PGOOGLE_MAPS_API_KEY=your_google_maps_key
```

For local Android emulator development, `10.0.2.2` points at the host machine.
The debug build allows cleartext HTTP so it can talk to the local backend
gateway during development.

## Verify

```powershell
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
```
