---
id: "00044"
status: done
reads:
  - docs/architecture.md
  - lib/pages/home/home_page.dart
  - lib/pages/home/bloc/home_bloc.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/analysis/analysis_page.dart
  - lib/pages/analysis/bloc/analysis_bloc.dart
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/accounts/account_detail_page.dart
  - lib/pages/accounts/account_form_page.dart
  - lib/pages/record/record_page.dart
  - lib/pages/record/bloc/record_bloc.dart
  - lib/pages/categories/categories_page.dart
  - lib/pages/settings/settings_page.dart
---

# Page uses only its own bloc

## Outcome

A page widget reads and dispatches only that page's bloc. A page bloc loads and saves through repositories. It does not subscribe to another bloc or add another bloc's events. `AppSettingBloc` stays in `lib/blocs/` and pages may still read it. Home, analysis, accounts, account detail, account form, and record each follow this. Categories already uses only `CategoriesBloc`. Settings keeps using `AppSettingBloc`.

## Out of scope

New screens, repository interfaces, and moving `AppSettingBloc` into a page.

## Done when

- [x] Each listed page provides one bloc, and its widgets do not read or dispatch `AccountsBloc`, `TransactionsBloc`, or `CategoriesBloc` unless that bloc is the page's own bloc
- [x] `HomeBloc`, `AnalysisBloc`, `AccountsBloc`, `AccountDetailBloc`, `AccountFormBloc`, and `RecordBloc` call repositories directly
- [x] `flutter test` passes

## Result

Each of those pages provides one bloc. The bloc reads and writes repositories, including default accounts, default categories, and opening-balance rows. Account list lines live on `AccountsBloc`. `TransactionsBloc` and `AccountsListBloc` are removed. A page reloads its own bloc when the route changes. Settings still uses `AppSettingBloc`. `flutter test` passed.
