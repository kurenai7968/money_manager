---
id: "00011"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/record/record_page.dart
  - lib/pages/home/home_page.dart
---

# Finish recording a transaction

## Outcome

The record page shows which category is selected. The check key saves an expense, income, or transfer, and names what is missing when it cannot. A new expense or income starts on an existing account. The saved transaction appears on Home, and that account balance includes it. Editing and deleting use the same page.

## Out of scope

Category editing, analysis charts, and the home donut.

## Done when

- [x] The selected category is marked on the grid
- [x] Saving an expense, income, or transfer updates Home and the account balance
- [x] A missing category, amount, or transfer pair shows its own message
- [x] Edit loads the transaction, and delete removes it
- [x] `flutter test` passes

## Result

The selected category uses its own color, a ring, and a check. A new expense or income starts on the first account, and a new transfer starts with that account as From. The check key saves. It asks for an amount, a category, or two different accounts when one is missing. Home lists the transaction, and the account balance includes it. Edit opens the same page, and delete removes it. A long amount shrinks to fit, and the type switcher fits a narrow phone. `flutter test` passed.
