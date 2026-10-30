---
id: "00021"
status: done
reads:
  - docs/architecture.md
  - lib/pages/accounts/bloc/accounts_bloc.dart
  - lib/pages/accounts/widgets/account_form_body.dart
  - lib/core/utils/ledger_balance.dart
  - lib/models/transaction_model.dart
  - lib/models/ledger_kinds.dart
  - lib/repositories/transaction_repository.dart
---

# Opening balance transaction

## Outcome

Saving an account with an opening balance greater than zero also stores one opening transaction for that amount on that account. The account balance counts that amount once, so the account total matches the net of its transactions. An opening balance of zero stores no transaction. Monthly income and expense ignore the opening transaction.

## Out of scope

- Editing an opening transaction on the record page
- Changing expense, income, or transfer behavior

## Done when

- [x] Saving an account with a positive opening balance stores one opening transaction with the same amount and account
- [x] Saving an opening balance of zero removes that transaction
- [x] Account balance counts the opening amount once
- [x] Monthly income and expense ignore the opening transaction
- [x] `flutter test` passes

## Result

Saving an account with an opening balance greater than zero stores one opening transaction for that amount on that account. Saving a zero balance removes it. Loading accounts backfills a missing opening transaction. Balance still starts from the opening balance and does not apply that transaction again. Monthly income and expense ignore it, and the record page cannot create or edit it. `flutter test` passed.
