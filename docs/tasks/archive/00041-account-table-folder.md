---
id: "00041"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/account_table.dart
  - lib/database/sqlite/app_database.dart
  - lib/repositories/account_repository.dart
  - test/database/app_database_test.dart
---

# Move account table into sqlite/tables

## Outcome

`account_table.dart` lives in `lib/database/sqlite/tables/`. Imports that referenced `lib/database/sqlite/account_table.dart` point at the new path. `CategoryTable` and `TransactionTable` stay in `lib/database/sqlite/`.

## Out of scope

Moving other table files, changing SQL, or changing repository behavior.

## Done when

- [x] `AccountTable` is imported from `database/sqlite/tables/account_table.dart`
- [x] `flutter test` passes

## Result

`AccountTable` now lives in `lib/database/sqlite/tables/account_table.dart`. `AppDatabase`, `AccountRepositoryImpl`, and `app_database_test.dart` import that path. `CategoryTable` and `TransactionTable` remain in `lib/database/sqlite/`. Layout in `docs/architecture.md` lists `sqlite/tables/account_table.dart`. `flutter test` passed (119 tests). `synced_commit` is unchanged because the worktree is not clean.
