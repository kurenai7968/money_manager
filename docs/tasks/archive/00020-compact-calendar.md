---
id: "00020"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/home/widgets/home_calendar_view.dart
  - lib/pages/home/widgets/home_frame.dart
  - lib/widgets/ledger_calendar.dart
---

# Compact home calendar

## Outcome

The home calendar keeps one compact height. Selecting a day does not resize it. The current month starts with today selected.

## Out of scope

The record date picker, day net rules, and the transaction tile.

## Done when

- [x] The home calendar height stays the same with and without a selected day.
- [x] The current month selects today until another day is chosen.
- [x] `flutter test` passes

## Result

The home calendar uses a fixed height, and the day's transactions use the space below it. Changing the month or the selected day does not resize the calendar. The current month selects today. `flutter test` passed.
