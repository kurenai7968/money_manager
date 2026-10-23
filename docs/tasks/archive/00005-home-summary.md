---
id: "00005"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Home summary and calendar

## Outcome

Home shows the month's income and expense, a donut with the balance in the center, and the month's transactions. Calendar shows the same month and the selected day's transactions.

## Out of scope

Analysis and the remaining settings.

## Done when

- [x] Summary and calendar read stored transactions for the selected month
- [x] `flutter test` passes

## Result

The home summary lists transactions for the month and puts 結餘 in the donut. The calendar uses that month and shows the selected day. `flutter test` passed.
