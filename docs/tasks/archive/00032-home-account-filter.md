---
id: "00032"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/home/home_page.dart
  - lib/pages/home/bloc/home_bloc.dart
  - lib/pages/home/bloc/home_event.dart
  - lib/pages/home/bloc/home_state.dart
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/record/widgets/record_account_sheet.dart
  - lib/widgets/ledger_sheet.dart
  - test/home/home_bloc_test.dart
---

# Home account filter

## Outcome

The home app bar has a leading control. It opens a sheet that selects one account or all accounts. All accounts is the default. Summary, calendar, and the transaction list follow that selection. A single account includes its expenses, incomes, and transfers that use it. Archived accounts stay out of the picker. When the selected account is gone, the selection returns to all accounts. The choice lasts for this home session.

## Out of scope

Persisting the choice in app settings. Analysis, the accounts tab, and the record page.

## Done when

- [x] The leading control shows All or the selected account name and opens the sheet
- [x] Summary, calendar day nets, and the transaction list match the selection
- [x] `flutter test` passes

## Result

The home app bar leading control shows All or the selected account name and opens a sheet. Summary, calendar day nets, and the transaction list follow that account. A single account includes its expenses, incomes, and transfers. An archived or missing account returns the selection to all. `flutter test` passed.
