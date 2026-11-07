---
id: "00037"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/account_table.dart
  - lib/database/sqlite/category_table.dart
  - lib/database/sqlite/transaction_table.dart
  - lib/database/sqlite/table_field.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
---

# SQL column constants

## Outcome

Each SQLite table stores column names as string constants, such as `static const id = 'id'`. Column types are written in `createSql`. Queries use those strings directly.

## Out of scope

Schema changes, query behavior, and `docs/architecture.md`.

## Done when

- [x] Account, category, and transaction tables use string column constants and inline types in `createSql`
- [x] `TableField` is unused
- [x] `flutter test` passes

## Result

`AccountTable`, `CategoryTable`, and `TransactionTable` store each column name as a string constant. `createSql` writes the SQL type next to that name. Repositories query with those strings. `TableField` is removed. `flutter test` passed.
