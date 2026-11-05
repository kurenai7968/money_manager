---
id: "00028"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/widgets/ledger_calendar.dart
  - lib/pages/home/widgets/home_calendar_view.dart
---

# Calendar day amount slot

## Outcome

Home calendar day numbers stay on one horizontal line. The grid stays `TableCalendar`. A day with an amount shows that amount under the number. A day with no amount keeps an empty line in that same place.

## Out of scope

Day net rules, the transaction list, and the record date picker, which has no amount line.

## Done when

- [x] A day with an amount and a day without one place their numbers at the same vertical position
- [x] A day without an amount keeps a blank line under the number
- [x] `flutter test` passes

## Result

The home calendar still uses `TableCalendar`. Each day keeps a line under the number. An amount fills that line, and a day with no amount leaves it blank, so the numbers stay on one line. The record date picker has no amount line. `flutter test` passed.
