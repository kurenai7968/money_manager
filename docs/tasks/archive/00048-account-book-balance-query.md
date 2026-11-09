---
id: "00048"
status: done
reads:
  - docs/architecture.md
  - lib/services/ledger_service.dart
  - lib/core/utils/ledger_balance.dart
  - lib/repositories/account_repository.dart
---

# Account book balance query

## Outcome

`LedgerService` is renamed to `AccountBookService`. Account balance and net worth come from one SQL join of accounts and transactions. `lib/core/utils/ledger_balance.dart` is removed.

## Out of scope

Month totals, day nets, and analysis rollups stay in the page model functions. `AccountModel` fields stay the same.

## Done when

- [x] No `LedgerService` or `ledger_balance.dart` remains
- [x] Account balance and net worth come from the joined query
- [x] `flutter test` passes

## Result

`LedgerService` is now `AccountBookService` in `lib/services/account_book_service.dart`. `AccountRepository.balances()` joins accounts and transactions and returns each account balance and net worth. Opening rows are not applied twice. Credit balances stay amounts owed, and archived accounts stay out of net worth. `AccountsBloc`, account detail, and the account form read those figures. Month totals, day nets, and analysis rollups stay in the page models. `lib/core/utils/ledger_balance.dart` is removed. `flutter test` passed (118).
