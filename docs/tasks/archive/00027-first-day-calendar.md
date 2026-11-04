---
id: "00027"
status: done
reads:
  - docs/architecture.md
  - lib/models/enums/first_day_of_week.dart
  - lib/widgets/ledger_calendar.dart
---

# First day to calendar weekday

## Outcome

`FirstDayOfWeek` converts itself to `StartingDayOfWeek`. The home calendar and the record date picker use that conversion.

## Out of scope

The stored weekday name, the default Monday, and the settings choices stay as they are.

## Done when

- [x] Both calendars start the week through `FirstDayOfWeek.toStartingDayOfWeek`
- [x] `flutter test` passes

## Result

`FirstDayOfWeek.toStartingDayOfWeek` maps each weekday onto `StartingDayOfWeek`. `LedgerCalendar` uses that method, so the home calendar and the record date picker both start on the chosen day. `flutter test` passed.
