---
id: "00039"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/app_database.dart
  - lib/database/sqlite/account_table.dart
  - lib/database/sqlite/category_table.dart
  - lib/database/sqlite/transaction_table.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
  - lib/app_config.dart
  - test/database/store_init_test.dart
  - test/support/test_stores.dart
---

# Complete the SQLite executor

## Outcome

`SqlExecutor` is the shared read and write surface for `AppDatabase` and a transaction. A transaction can query, insert, update, delete, count, and run raw SQL. Insert, update, and delete report how many rows changed. Insert still replaces an existing primary key. A thrown transaction action rolls the writes back.

## Out of scope

Schema migrations, foreign keys, and repository behavior stay as they are.

## Done when

- [x] `AppDatabase` and `_SqlTransaction` implement the same `SqlExecutor` operations
- [x] A failed transaction leaves the database unchanged
- [x] `flutter test` passes

## Result

`SqlExecutor` now covers execute, raw SQL, query, insert, update, delete, and count. `AppDatabase` and `_SqlTransaction` share that implementation, so a transaction can read and write the same way as the database. `query` accepts columns, filters, grouping, order, limit, and offset. Insert still replaces an existing primary key. Insert, update, and delete return the number of affected rows. `transaction` returns the callback result, and a thrown callback rolls the writes back. Account, category, and transaction deletes and account archive await those row counts. `flutter test` passed: 119 tests.
