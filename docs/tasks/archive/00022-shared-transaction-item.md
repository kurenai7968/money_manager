---
id: "00022"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/home/widgets/home_transaction_tile.dart
  - lib/pages/home/widgets/home_summary_view.dart
  - lib/pages/home/widgets/home_calendar_view.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/home/home_page.dart
  - lib/pages/accounts/widgets/account_detail_body.dart
  - lib/pages/accounts/account_detail_page.dart
---

# Shared transaction item

## Outcome

Home and account history show the same transaction row: category icon, category name, note, amount, and account.

## Out of scope

Record page, analysis totals, and the app color theme.

## Done when

- [x] Home summary, home calendar, and account history use one transaction row widget
- [x] The row shows the category icon, category name, note, amount, and account
- [x] `flutter test` passes

## Result

Home summary, the selected calendar day, and account history use `TransactionList` and `TransactionItem` in `lib/widgets/transaction_item.dart`. The row shows the category icon, category name, note, amount, and account. Expense and income amounts use the category color and a sign. Transfers show both account names in near-black. Opening rows are labeled with the opening balance and do not open the record page. A `#tag` in the note uses green. Home summary and account history group rows by day and show that day's expense. The calendar day list omits the day header because the day is already selected. `flutter test` passed.
