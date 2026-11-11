---
id: "00053"
status: done
reads:
  - docs/architecture.md
  - lib/repositories/account_repository.dart
  - lib/pages/home/widgets/home_account_sheet.dart
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/services/account_book_service.dart
  - test/support/memory_account_repository.dart
---

# Move balance models

## Outcome

`AccountBalances` lives in `lib/models/`. `HomeAccountPick` lives in `pages/home/models/`. Callers import those types from the models folders. Repository and widget files no longer declare them.

## Out of scope

Renaming either type, adding `Equatable` or `copyWith`, and moving private widget helpers, bloc state, or entities.

## Done when

- [x] `AccountBalances` is defined in `lib/models/account_balances.dart`
- [x] `HomeAccountPick` is defined in `pages/home/models/home_account_pick.dart`
- [x] `flutter test` passes

## Result

`AccountBalances` now lives in `lib/models/account_balances.dart`. `HomeAccountPick` now lives in `pages/home/models/home_account_pick.dart`. Repository, home widgets, and the account test fakes import those files. No other public data class was sitting outside a models folder. `flutter test` passed (118).
