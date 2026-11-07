---
id: "00038"
status: done
reads:
  - docs/architecture.md
  - lib/core/errors/app_exception.dart
  - lib/app_config.dart
  - lib/database/sqlite/app_database.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
  - lib/repositories/app_setting_repository.dart
---

# Shared guard and app config

## Outcome

Repository calls share one public `guard` that rethrows `AppException` and wraps every other error as `CacheException` with the original error kept as `cause`. The SQLite file name and schema version live on `AppConfig` with the app setting key.

## Out of scope

SQL column names, route paths, theme tokens, and user-facing copy stay where they are.

## Done when

- [x] Account, category, transaction, and app setting repositories call the shared `guard`
- [x] `AppDatabase` reads the file name and version from `AppConfig`
- [x] `flutter test` passes

## Result

`guard` in `lib/core/errors/app_exception.dart` rethrows `AppException` and wraps other errors as `CacheException`, keeping the original error on `cause` and the original stack trace. All four repositories call it. `AppConfig` now holds `databaseName` and `databaseVersion` next to `appSettingKey`, and `AppDatabase` uses both. Route paths, SQL column names, and theme tokens already have their own homes, so they were left there. `flutter test` passed.
