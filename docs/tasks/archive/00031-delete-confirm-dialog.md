---
id: "00031"
status: done
reads:
  - docs/architecture.md
  - lib/pages/record/widgets/record_app_bar.dart
  - lib/pages/accounts/widgets/account_form_body.dart
  - lib/pages/categories/widgets/category_form_body.dart
  - lib/pages/record/widgets/record_note_dialog.dart
  - lib/l10n/app_en.arb
  - lib/l10n/app_zh.arb
  - lib/l10n/app_zh_CN.arb
---

# Confirm before delete

## Outcome

Deleting a transaction, an account, or a category asks for confirmation. Cancel leaves the item in place. Confirm runs the existing delete or archive action.

## Out of scope

Delete and archive rules, bloc events, and screens other than these three actions.

## Done when

- [x] Transaction, account, and category delete each show a confirm dialog
- [x] Cancel does not delete
- [x] Confirm deletes or archives as before
- [x] `flutter test` passes

## Result

Delete on a transaction, an account, and a category opens a confirm dialog. Cancel closes it and leaves the item in place. Confirm deletes the transaction or category, and archives the account, using the existing actions. `flutter test` passed.
