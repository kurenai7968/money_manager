---
id: "00014"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/record/record_page.dart
  - lib/core/utils/amount_expression.dart
  - test/record/record_page_test.dart
  - test/amount_expression_test.dart
---

# Transaction page keypad and category

## Outcome

The record page opens with the first category of the current kind already selected. While a keypad operator is pending, the commit key becomes equals and evaluates the expression. The transaction is saved only after that result is shown. Category columns keep one short, even horizontal gap. The commit key is a vertical rectangle.

## Out of scope

New transaction types, stored expressions, and category editing.

## Done when

- [x] A new expense or income starts on the first category, including after a type switch
- [x] A pending operator replaces the check with equals, and save is available only after evaluation
- [x] Category columns use one short horizontal gap
- [x] The commit key is taller than it is wide
- [x] `flutter test` passes

## Result

The record page selects the first expense or income category on open and after a type change. Editing keeps the saved category. While a keypad operator is pending, the commit key shows Equals and evaluates the expression. Save is available only after that result is shown. Division by zero leaves the key as Equals. Category cells are at most 72 wide, share an 8px gap, and stay centered, so the horizontal gaps match. The commit key is 96 tall and at most 72 wide. `flutter test` passed.
