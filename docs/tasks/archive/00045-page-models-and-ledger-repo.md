---
id: "00045"
status: done
reads:
  - docs/architecture.md
  - lib/core/utils/queued_bloc.dart
  - lib/core/utils/ledger_commands.dart
  - lib/core/utils/ledger_balance.dart
  - lib/core/utils/analysis_rollup.dart
  - lib/core/utils/amount_expression.dart
  - lib/app_providers.dart
---

# Page models and ledger repository

## Outcome

`QueuedBloc` is gone. Types used by one page live in `pages/[feature]/models/`. Loading accounts and categories, and saving or deleting a transaction with its opening balance, go through a ledger repository instead of `core/utils`.

## Out of scope

Changing screen behavior, and renaming the shared account, category, transaction, and setting models.

## Done when

- [x] No page bloc uses `QueuedBloc`
- [x] Home, analysis, record, and accounts keep their own types under `pages/[feature]/models/`
- [x] `loadAccounts`, `loadCategories`, and the opening-balance transaction writes are repository methods
- [x] `flutter test` passes

## Result

`QueuedBloc` and `ledger_commands.dart` are removed. Home, analysis, record, and accounts blocs load and save through `LedgerRepository`. `AccountsBloc` and `AccountFormBloc` still use the table repositories for a single-table write. Page types live under `pages/home/models/`, `pages/analysis/models/`, `pages/record/models/`, and `pages/accounts/models/`. Shared balance functions stay in `core/utils/ledger_balance.dart`. Tests that fire a second event wait for the load to finish. `flutter test` passed (116).
