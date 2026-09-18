# Iraq Ride App

Monorepo scaffold for the Iraq intercity car booking app described in the PRD.

## Structure

- `backend/` Node.js + Express API
- `mobile/` Flutter app
- `iraq-ride-app-PRD.md` product requirements document

## Next implementation steps

1. Finish the backend auth, trips, cities, and notifications modules.
2. Wire the Flutter app to the API and replace placeholder screens with real flows.
3. Add PostgreSQL migrations and FCM integration.

## Backend

```bash
cd backend
npm install
npm run dev
```

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```
