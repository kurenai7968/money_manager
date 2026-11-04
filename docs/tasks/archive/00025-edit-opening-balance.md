---
id: "00025"
status: done
reads:
  - docs/architecture.md
  - lib/pages/accounts/bloc/accounts_bloc.dart
  - lib/pages/accounts/widgets/account_form_body.dart
  - lib/pages/transactions/bloc/transactions_bloc.dart
  - lib/pages/record/widgets/record_frame.dart
  - lib/pages/record/widgets/record_app_bar.dart
  - lib/widgets/transaction_item.dart
  - lib/core/utils/ledger_balance.dart
  - lib/models/transaction_model.dart
  - lib/models/ledger_kinds.dart
  - lib/routes/app_router.dart
---

# Edit opening balance

## Outcome

An opening balance can be edited on the record page as a normal transaction. A positive amount is income. A negative amount is expense. The account balance still counts that amount once.

## Out of scope

- Changing transfer behavior
- Changing how an income or expense that is not an opening balance is recorded

## Done when

- [x] Tapping an opening balance opens the record page
- [x] A positive opening balance is income and a negative opening balance is expense
- [x] Editing or deleting that transaction updates the account opening balance
- [x] The account balance counts the amount once
- [x] `flutter test` passes

## Result

An opening balance is an income when the amount is positive and an expense when it is negative. Tapping that row opens the record page. Saving it writes the signed amount back to the account. Deleting it, changing it into a transfer, or moving it to another account sets the original opening balance to zero. The account balance counts the amount once, and the month includes it. A stored opening row is read as income. `flutter test` passed.
