---
id: "00007"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Settings and analysis

## Outcome

Settings stores language, appearance, currency, and the first day of the week. Analysis compares this month with the last one, shows six months, and totals by category and account.

## Out of scope

Nothing further in the planned ledger flow.

## Done when

- [x] Settings persist and analysis reads stored transactions
- [x] `flutter test` passes

## Result

Language, appearance, currency, and week start are stored and applied. Analysis compares the current month with the previous one and groups the selected kind by category and account. `flutter test` passed.
