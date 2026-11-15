---
id: "00058"
status: done
reads:
  - docs/architecture.md
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/accounts/widgets/accounts_app_bar.dart
  - lib/pages/accounts/bloc/accounts_bloc.dart
  - lib/pages/accounts/bloc/accounts_event.dart
  - test/widget_test.dart
---

# Reload accounts after add

## Outcome

After the new-account page closes, the accounts page loads again and shows the saved account.

## Out of scope

Editing an account, account detail, categories, and the record page.

## Done when

- [x] Saving a new account and returning shows it on the accounts page
- [x] `flutter test` passes

## Result

Saving a new account and returning dispatches `AccountsInitialized` again, and the accounts page shows the saved account. `flutter test` passed (113). `synced_commit` is unchanged because the worktree is not clean.
