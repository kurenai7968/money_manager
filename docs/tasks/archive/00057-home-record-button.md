---
id: "00057"
status: done
reads:
  - docs/architecture.md
  - lib/widgets/app_shell.dart
  - lib/widgets/app_tab_bar.dart
  - lib/routes/app_router.dart
  - lib/pages/home/home_page.dart
  - lib/pages/home/bloc/home_bloc.dart
  - lib/pages/home/bloc/home_event.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/widgets/transaction_item.dart
  - lib/pages/accounts/widgets/account_detail_body.dart
  - lib/pages/accounts/bloc/account_detail_bloc.dart
  - lib/pages/record/record_page.dart
  - test/widget_test.dart
  - test/record/record_page_test.dart
---

# Home record button

## Outcome

The record button sits at the bottom right of Home. The tab bar is only Home, Analysis, Accounts, and Settings. Opening the record page from Home or account detail and returning reloads that page and keeps its current selection.

## Out of scope

Analysis, Accounts, Settings, and category screens. They do not open the record page.

## Done when

- [x] Home shows the record button at the bottom right, and the tab bar has no center record button
- [x] Returning from the record page reloads Home or account detail and keeps the current selection
- [x] `flutter test` passes

## Result

Home shows the record button at the bottom right, above the tab bar. The tab bar is Home, Analysis, Accounts, and Settings. Returning from the record page dispatches `HomeInitialized` or `AccountDetailInitialized` again, so that page reloads and keeps its current selection. `flutter test` passed (113). `synced_commit` is unchanged because the worktree is not clean.
