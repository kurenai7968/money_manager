---
id: "00051"
status: done
reads:
  - docs/architecture.md
  - lib/models/account_book_kinds.dart
  - lib/themes/account_book_palette.dart
  - lib/widgets/account_book_calendar.dart
  - lib/widgets/account_book_sheet.dart
  - lib/widgets/account_book_reorder.dart
  - lib/pages/home/models/home_figures.dart
  - lib/l10n/app_en.arb
---

# Rename Ledger names to AccountBook

## Outcome

Names in `lib/` and `test/` that contain Ledger become AccountBook. The English settings section label becomes Account book. Chinese labels stay 帳本 and 账本.

## Out of scope

`DayLedger` stays. The Models section names that type. Archived task files stay as written.

## Done when

- [x] No Ledger identifier remains in `lib/` or `test/` except `DayLedger`
- [x] The English settings section label is Account book
- [x] `flutter test` passes

## Result

`ledger_kinds.dart` is `account_book_kinds.dart`. `LedgerPalette` is `AccountBookPalette`. `LedgerCalendar` is `AccountBookCalendar`. `showLedgerSheet` is `showAccountBookSheet`. `ledgerReorderProxy` is `accountBookReorderProxy`. The English settings section is Account book. Chinese stays 帳本 and 账本. `DayLedger` is unchanged. `flutter test` passed (118).
