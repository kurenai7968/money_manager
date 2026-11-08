---
id: "00042"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/category_table.dart
  - lib/database/sqlite/transaction_table.dart
  - lib/database/sqlite/app_database.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
---

# Move the remaining table files

## Outcome

`category_table.dart` and `transaction_table.dart` live in `lib/database/sqlite/tables/` with `account_table.dart`. Every import of those two files uses the new path. No other Dart file under `lib/database/sqlite/` defines a SQL table.

## Out of scope

Changing SQL, repository behavior, or the executor files in `lib/database/sqlite/`.

## Done when

- [x] `CategoryTable` and `TransactionTable` are imported from `database/sqlite/tables/`
- [x] `flutter test` passes

## Result

`category_table.dart` and `transaction_table.dart` now live in `lib/database/sqlite/tables/` with `account_table.dart`. `AppDatabase`, `CategoryRepositoryImpl`, and `TransactionRepositoryImpl` import those paths. Layout in `docs/architecture.md` lists all three table files. `flutter test` passed (119 tests). `synced_commit` is unchanged because the worktree is not clean.
