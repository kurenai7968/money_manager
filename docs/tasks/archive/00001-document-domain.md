---
id: "00001"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Document the ledger domain

## Outcome

`docs/architecture.md` records the account, category, and transaction models, the balance rules, and the screen structure agreed for the ledger.

## Out of scope

App code, theme, routes, and packages.

## Done when

- [x] Architecture describes the three records, settings, month balance, and screens
- [x] `flutter test` passes

## Result

`docs/architecture.md` now records `AccountModel`, `CategoryModel`, `TransactionModel`, settings, the month balance, and the screen structure. Visual layout stays in `DESIGN.md`. `flutter test` passed.
