---
id: "00026"
status: done
reads:
  - docs/architecture.md
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/home/widgets/home_frame.dart
  - lib/pages/home/widgets/home_calendar_view.dart
  - lib/pages/analysis/widgets/analysis_body.dart
  - lib/pages/analysis/widgets/analysis_frame.dart
  - lib/pages/accounts/widgets/accounts_body.dart
  - lib/pages/accounts/widgets/account_detail_body.dart
  - lib/pages/accounts/widgets/account_form_body.dart
  - lib/pages/record/widgets/record_frame.dart
  - lib/pages/settings/widgets/settings_body.dart
  - lib/models/enums/week_start.dart
  - lib/models/app_setting_model.dart
  - lib/widgets/ledger_calendar.dart
  - lib/core/utils/ledger_balance.dart
---

# Screen blocs and weekdays

## Outcome

Widgets on Home, Analysis, Accounts, account detail, account form, and Record display bloc state and send events. Month totals, day nets, analysis rollups, asset and liability groups, net worth, account history, and save validation run in those blocs. `FirstDayOfWeek` lists Monday through Sunday, default Monday. Settings can choose any of those days, and both calendars start on that day.

## Out of scope

The category tab controller stays on the widget. Pure functions stay in `core/utils/`. The stored preference key stays `week_start`. Opening-balance behavior stays as documented.

## Done when

- [x] Home, Analysis, Accounts, account detail, account form, and Record widgets do not filter the ledger, total amounts, or build the model that will be saved
- [x] Settings offers Monday through Sunday
- [x] The home calendar and the record date picker start on the chosen day
- [x] `flutter test` passes

## Result

Home, Analysis, the accounts list, account detail, the account form, and Record now keep their screen rules in blocs. Widgets read that state, send events, and format the UI. Text fields and the category tab controller stay on the widgets. `FirstDayOfWeek` is Monday through Sunday, stored by weekday name under `week_start`, and both calendars start on the chosen day. `flutter test` passed.
