---
id: "00010"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/app_database.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
---

# Table classes

## Outcome

The database is created from the current schema only. Each table has a class that defines its name and fields, and the repositories use those definitions.

## Out of scope

Account, category, and transaction behavior.

## Done when

- [x] `onCreate` builds the current accounts, categories, and transactions tables
- [x] `onUpgrade` is gone
- [x] Each table's name and fields live on one class
- [x] `flutter test` passes

## Result

`AppDatabase` opens at version 1 and creates accounts, categories, and transactions in `onCreate`. `AccountTable`, `CategoryTable`, and `TransactionTable` define each table name and its fields. Repositories query through those definitions. `flutter test` passed.
