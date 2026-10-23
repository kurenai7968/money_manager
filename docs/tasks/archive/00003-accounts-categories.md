---
id: "00003"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Accounts and categories

## Outcome

The user can add, edit, reorder, and archive accounts, and can manage expense and income categories from Settings. Balances start from each account's opening balance. Default categories are present on a new database.

## Out of scope

Recording transactions, the home summary, transfer, and the rest of Settings.

## Done when

- [x] Accounts and categories persist and can be edited from the app
- [x] Bloc tests cover success, failure, and archive boundaries
- [x] `flutter test` passes

## Result

Accounts and categories are stored in SQLite. The user can add, edit, reorder, and archive an account, and can add, edit, delete, and reorder categories from Settings. A new database gets the default categories. `flutter test` passed.
