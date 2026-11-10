---
id: "00049"
status: done
reads:
  - docs/architecture.md
  - lib/services/account_book_service.dart
  - lib/models/account_model.dart
  - lib/repositories/account_repository.dart
---

# Account book load model

## Outcome

`AccountBookService.loadAccounts` returns a shared model of accounts, balances, net worth, and transactions. Other service methods that return the same kind of record return a model too.

## Out of scope

`AccountRepository.balances` stays `AccountBalances`. Month totals, day nets, and analysis rollups stay in the page models.

## Done when

- [x] `loadAccounts` returns the shared model
- [x] Callers read that model
- [x] `flutter test` passes

## Result

`AccountBookService.loadAccounts` returns `AccountBookModel` with accounts, balances in minor units by account id, net worth, and transactions. It is the only record return on that service. Home, analysis, accounts, account detail, account form, and record blocs read the same fields from the model. `flutter test` passed (118).
