---
name: account-book
description: >
  Working contract for the money_manager account book. Use for any change in
  this repository: features, fixes, UI, blocs, data, routing, or tests.
  Overrides generic Flutter architecture skills, Material 3 palettes, and the
  hex-color ban. Visuals come from DESIGN.md.
---

# Account book

Read this file and `DESIGN.md` before changing `lib/` or `test/`. This file is the working contract. `DESIGN.md` decides colors, type, motion, sheets, keypad, and navigation.

Do not introduce `ChangeNotifier`, a `lib/data/` tree, or a second theme. Do not reseed a `ColorScheme` or add ocean/coffee palettes. Use the colors `DESIGN.md` names.

Motion is press feedback and the platform transition. Do not add entrance choreography or `Hero`.

After changing `lib/` or `test/`, run `flutter test` and finish only after it passes. When the app is running, check runtime errors and hot reload before finishing.

## Stack

- UI: `package:material_ui/material_ui.dart`.
- Calendar: `table_calendar`. The home month grid and the record date picker both use `TableCalendar`. Do not build a day grid. Do not call `showDatePicker`.
- State: `flutter_bloc` and `equatable`.
- Navigation: `go_router`. Paths come from the `AppRoutes` enum. Do not hardcode path strings.
- Localization: ARB files generate `AppLocalizations`. User-facing strings go through `context.l10n`.
- Database: `sqflite` and `shared_preferences`, both wrapped under `lib/database/`. Other layers do not import those packages.
- Serialization: `json_serializable` on entities only. Models have no JSON. Mapping lives in `lib/core/mapping/[name]_mapping.dart`. The model file and the entity file do not import each other. Only a repository imports the mapping file.

## Layout

```
lib/
├── blocs/                         # App-wide blocs only
├── main.dart
├── app.dart
├── app_config.dart
├── app_providers.dart
├── l10n/
├── core/
│   ├── utils/
│   ├── errors/
│   ├── extensions/
│   └── mapping/
├── database/
│   ├── sqlite/tables/
│   └── shared_preferences/
├── entities/
├── models/
├── repositories/
├── services/
├── pages/[feature]/
│   ├── models/
│   ├── bloc/
│   ├── widgets/
│   └── [feature]_page.dart
├── routes/
├── themes/
└── widgets/                       # Used by more than one feature
```

`[feature]_page.dart` creates that page's one bloc and a scaffold. It does not nest another feature bloc. `lib/pages/pages.dart` exports every page.

## Services and providers

`AppProviders` constructs `AccountRepositoryImpl`, `CategoryRepositoryImpl`, `TransactionRepositoryImpl`, `AppSettingRepositoryImpl`, and `AccountBookServiceImpl`. It provides those repositories, the service, and `AppSettingBloc`. It does not take repository arguments. Repository implementations take named constructor arguments (`database` for SQLite, `store` for settings).

`AccountBookServiceImpl` takes the account, category, and transaction repositories as named arguments. A page bloc calls it to load accounts with balances, load categories with defaults, and save or delete a transaction. A single-table write goes to that table's repository.

`AppSettingBloc` is the only bloc provided above the router. A page creates its own bloc and dispatches that bloc's start event. Widgets on the page read and dispatch only that bloc. They may also read `AppSettingBloc` for language, theme, the first weekday, or the income and expense color pair. `SettingsPage` does not create `AppSettingBloc`.

When the user returns from the record route, the page that opened it dispatches its start event again. Home and account detail do this. When the user returns from the new-account route, the accounts page dispatches its start event again.

## AccountBook

- Cash, bank, and savings are assets. Credit is a liability, and its balance is the amount owed.
- Balance is income and transfers in, minus expenses and transfers out. Spending on a credit account increases the amount owed. A transfer into a credit account decreases it.
- Net worth is the sum of those balances, with credit subtracted and inactive accounts omitted.
- A transfer is listed on both of its accounts. A screen that shows every transaction uses each transaction once.
- A transfer has no category. Its two accounts must be different. Paying a credit card is a transfer from the funding account to the card.
- There is no opening-balance transaction.
- The home summary and calendar share one month. That month has one balance: income minus expense. Transfers are excluded.
- `amount` is a decimal greater than zero, in major currency units. The keypad expression is not stored.
- Inserts omit `id`. SQLite assigns the integer primary key. Updates and deletes use that id.
- An account with transactions is not deleted. It can be marked inactive only when its balance is zero. An inactive account is omitted from the record picker.
- A category that has transactions is marked inactive, not deleted. A category with no transactions can be deleted.

## BLoC

- One state class. Status is `initial`, `loading`, `success`, `failure`. Do not use `ready`.
- Events are `[Subject][Noun][Verb]` in past tense. Handlers are `_on[EventName]`.
- A widget dispatches one event for the field the user changed. It does not send a replacement model.
- The bloc emits the figures and lists the screen shows. Widgets do not derive balances, month totals, day nets, analysis rollups, or net worth.
- Declare fields before the constructor. Use `final` fields and `const` constructors.
- Every bloc has `bloc_test` coverage for success, failure, and boundary cases. Tests use the memory repositories in `test/support/`. Do not add `mockito` or `mocktail`.
