---
id: "00013"
status: done
reads:
  - docs/architecture.md
  - lib/main.dart
  - lib/app.dart
  - lib/database/sqlite/app_database.dart
  - lib/database/shared_preferences/settings_store.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
  - lib/blocs/app_setting_bloc/app_setting_bloc.dart
---

# Match startup and provider style

## Outcome

The app starts like the unit converter. `main` initializes shared preferences and SQLite, then runs `App`. `AppDatabase` and `SharedPreferenceManager` throw if used before `initialize`. `App` builds `AppProviders`, and a `BlocSelector` applies appearance and locale. Settings go through `AppSettingRepository`. Repositories do not import `sqflite` or `shared_preferences`.

## Out of scope

Ads, Firebase, splash, portrait lock, and a bloc observer. Ledger blocs stay on `AppProviders` because the tabs share one ledger. The router is created for each `App` so tests can mount it more than once. Bloc event files stay separate libraries. The database file stays in the application documents directory. Stored preference keys stay `language`, `theme`, and `week_start`.

## Done when

- [x] `main` calls `initialize` on both stores, then `runApp(const App())`
- [x] Reading either store before `initialize` throws `CacheException`
- [x] Settings load and save through `AppSettingRepository`
- [x] Ledger repositories do not import `sqflite`
- [x] `flutter test` passes

## Result

`main` initializes `SharedPreferenceManager` and `AppDatabase`, then runs `App`. Both stores throw `CacheException` before `initialize`. `App` builds `AppProviders`, and a `BlocSelector` applies appearance and locale. `AppSettingBloc` loads through `AppSettingRepository`. Ledger repositories call `AppDatabase` and do not import `sqflite`. The setting model is `AppSettingModel`, with `appearance` stored under the existing `theme` key. Widget tests pass memory repositories into `App` because sqflite's lock timer does not finish under the widget tester clock. `flutter test` passed: 46 tests.
