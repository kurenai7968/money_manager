---
id: "00050"
status: done
reads:
  - docs/architecture.md
  - lib/models/account_book_model.dart
  - lib/services/account_book_service.dart
  - lib/pages/accounts/bloc/accounts_bloc.dart
  - lib/pages/accounts/bloc/account_detail_bloc.dart
  - lib/pages/accounts/bloc/account_form_bloc.dart
  - lib/pages/home/bloc/home_bloc.dart
  - lib/pages/analysis/bloc/analysis_bloc.dart
  - lib/pages/record/bloc/record_bloc.dart
---

# One account book row per account

## Outcome

`AccountBookModel` is one account, its balance, and that account's transactions. `AccountBookService.loadAccounts` returns `List<AccountBookModel>`.

## Out of scope

`AccountRepository.balances` stays `AccountBalances`. Month totals, day nets, and analysis rollups stay in the page models. Screen state fields stay the same.

## Done when

- [x] `loadAccounts` returns `List<AccountBookModel>`
- [x] Each model has one account, its balance, and its transactions
- [x] Callers read that list
- [x] `flutter test` passes

## Result

`AccountBookService.loadAccounts` returns `List<AccountBookModel>`. Each row has one account, its balance in minor units, and the transactions whose `accountId`, `fromAccountId`, or `toAccountId` matches. A transfer is on both accounts. `accountBookNetWorth` sums the balances, subtracts credit, and skips archived accounts. `transactionsOnce` keeps one copy of each transaction for home, analysis, and record. Account detail reads that account's row. `flutter test` passed (118).
