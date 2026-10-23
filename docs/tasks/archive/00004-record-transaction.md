---
id: "00004"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Record a transaction

## Outcome

The record page saves an expense, income, or transfer with the keypad, category grid, and account sheet. Editing and deleting use the same page. Account balances include those transactions.

## Out of scope

The home summary, calendar amounts, analysis, and the rest of Settings.

## Done when

- [x] A saved transaction changes the account balance
- [x] Expression and bloc tests cover success, invalid results, and delete
- [x] `flutter test` passes

## Result

The record page saves expenses, income, and transfers with the keypad, category grid, and account sheet. Editing and deleting use the same page. Account balances include those transactions. `flutter test` passed.
