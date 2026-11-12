---
id: "00056"
status: done
reads:
  - docs/architecture.md
  - lib/database/sqlite/tables/account_table.dart
  - lib/database/sqlite/tables/category_table.dart
  - lib/database/sqlite/tables/transaction_table.dart
  - lib/models/account_model.dart
  - lib/models/category_model.dart
  - lib/models/transaction_model.dart
  - lib/repositories/account_repository.dart
  - lib/services/account_book_service.dart
  - lib/pages/home/bloc/home_bloc.dart
---

# Align models with the new tables

## Outcome

Account, category, and transaction ids are integers assigned by SQLite. An account stores a required icon and `isActive` instead of `archived`, and has no opening balance. A category stores `type` (`expense` or `income`) and `isActive`, and does not store a color. A transaction stores `amount` as a decimal in major currency units. Each account balance is the sum of its transactions. Inactive accounts are omitted from net worth and from the record picker. The home bloc keeps `accountBookService` and `HomeState.initial()`.

## Out of scope

Changing the home month, summary, and calendar behavior beyond the new ids, amounts, and active flag.

## Done when

- [x] Models, entities, repositories, services, pages, and tests follow the approved architecture text
- [x] Table SQL uses `INTEGER PRIMARY KEY AUTOINCREMENT`
- [x] `flutter test` passes

## Result

Models, entities, repositories, services, pages, and tests use integer ids assigned by SQLite. Accounts store `icon` and `isActive` and have no opening balance. Categories store `type` and `isActive` and do not store a color. Transaction amounts are decimals in major units, and each balance is the signed sum of transactions. Inactive accounts are omitted from net worth and from the record picker. Saving an account does not create a transaction. The home bloc still takes `accountBookService` and starts from `HomeState.initial()`. Table SQL uses `INTEGER PRIMARY KEY AUTOINCREMENT`. The database version stays 1, with no migration. `flutter test` passed (112 tests).
