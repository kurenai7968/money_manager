---
id: "00024"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/core/utils/ledger_balance.dart
  - lib/pages/record/widgets/record_frame.dart
  - lib/pages/record/widgets/record_body.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/home/widgets/home_calendar_view.dart
  - lib/pages/analysis/widgets/analysis_body.dart
  - lib/widgets/transaction_item.dart
---

# Speed up ledger screens

## Outcome

Typing an amount does not rebuild the category grid. Home, accounts, analysis, and transaction lists compute balances and month figures in one pass and reuse number and date formatters.

## Out of scope

Visual redesign, database schema, and when pages reload from the route.

## Done when

- [x] A keypad press updates the amount without rebuilding the category grid
- [x] Account balances, month figures, and analysis totals match the previous results
- [x] `flutter test` passes

## Result

Keypad edits update the amount through a listenable, so the category grid stays mounted. Account balances, calendar day nets, and analysis totals are each one pass over the transactions. Number and date formatters are reused. `flutter test` passed.
