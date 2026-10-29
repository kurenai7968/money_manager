---
id: "00019"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/home/widgets/home_calendar_view.dart
  - lib/pages/record/widgets/record_frame.dart
  - lib/models/app_setting_model.dart
  - pubspec.yaml
---

# Calendar package

## Outcome

The home month calendar and the record date picker use the `table_calendar` package. The home day grid is not hand-built. The record page does not open Material `showDatePicker`.

## Out of scope

Month balance rules, the selected day's transaction list, and how the first weekday is stored.

## Done when

- [x] Home shows a `TableCalendar` for the focused month, with each day's net and the selected day's transactions.
- [x] Choosing the record date opens `TableCalendar`, not `showDatePicker`.
- [x] `flutter test` passes

## Result

Home and the record date dialog both use `TableCalendar` through `LedgerCalendar`. Home still shows each day's net and the selected day's transactions. The record page opens that calendar in a dialog instead of `showDatePicker`. `flutter test` passed.
