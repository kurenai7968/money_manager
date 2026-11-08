---
id: "00040"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/app_database.dart
  - lib/database/sqlite/sql_executor.dart
  - lib/database/sqlite/sqlite_executor.dart
  - lib/database/sqlite/sql_transaction.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
---

# Split the SQLite database files

## Outcome

`AppDatabase` is the only class in `app_database.dart`. `SqlExecutor` lives in its own library. The shared command implementation and `_SqlTransaction` live in their own files of the same library, so the transaction type stays private and existing `app_database.dart` imports keep working.

## Out of scope

SQL behavior, repository call sites, and schema setup stay as they are.

## Done when

- [x] `app_database.dart` declares only `AppDatabase`
- [x] `SqlExecutor` is a separate library
- [x] `flutter test` passes

## Result

`app_database.dart` now declares only `AppDatabase` and exports `SqlExecutor`. The interface is `lib/database/sqlite/sql_executor.dart`. `_SqlExecutorMethods` is in `sqlite_executor.dart`, and `_SqlTransaction` is in `sql_transaction.dart`. Those two files are parts of the `app_database.dart` library, so the transaction type stays private and existing imports of `app_database.dart` still see `AppDatabase` and `SqlExecutor`. SQL behavior is unchanged. `flutter test` passed: 119 tests.
