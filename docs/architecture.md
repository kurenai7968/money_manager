---
synced_commit: bab577133619c34d9b18d9284e23757c5bad1612
---

# Architecture

Use a maintainable layered architecture. Keep code testable, and do not add abstraction until a task needs it.

The navigation shell, ledger, home, analysis, and settings are implemented. New feature code follows the sections below.

## Tech stack

- Framework: Flutter (stable). Language: Dart.
- State management: `flutter_bloc`
- Navigation: `go_router`
- Localization: `flutter_localizations` (ARB files)
- Database: SQLite via `sqflite`, and `shared_preferences`. Both are wrapped under `lib/database/`.
- Equality: `equatable`
- Serialization: `json_serializable`

## Layout

```
lib/
├── blocs/                         # Global blocs, outside any feature
│   └── app_setting_bloc/          # Language, theme, and similar preferences
│       ├── app_setting_bloc.dart
│       ├── app_setting_event.dart
│       └── app_setting_state.dart
├── main.dart                      # Entry point
├── app.dart                       # AppProviders, then BlocSelector applies the setting to MaterialApp.router
├── app_config.dart                # Banner ids, app setting keys, and similar constants
├── app_providers.dart             # BlocProviders and RepositoryProviders
├── l10n/                     # Localization (.arb files)
├── core/
│   ├── utils/                # Shared helpers, including JsonConverter
│   ├── errors/               # Custom exceptions and failures
│   ├── extensions/           # Context, String, and Date
│   └── mapping/              # toModel and toEntity. One file per pair.
│       └── [name]_mapping.dart
├── database/
│   ├── sqlite/               # sqflite connection
│   └── shared_preferences/   # wrapper around package:shared_preferences
├── entities/                 # Persistence types. json_serializable, fromJson, toJson, Equatable.
├── models/                   # UI and business data only. No entity mapping on the class.
├── repositories/             # One class per data source
├── pages/
│   ├── [feature_name]/
│   │   ├── bloc/             # Feature-specific bloc
│   │   ├── widgets/          # Widgets used only by this feature
│   │   └── [feature]_page.dart
│   └── pages.dart            # Exports every [feature]_page.dart under pages/
├── routes/                   # GoRouter configuration
├── themes/                   # Light and dark ThemeData, exposed as AppThemes.light and AppThemes.dark
└── widgets/                  # Widgets reused across features
```

## Data flow

A page dispatches a bloc event. The bloc calls a repository. The repository reads and writes SQLite through `database/sqlite`, and key-value settings through `database/shared_preferences`. It throws exceptions from `core/errors/`. The bloc catches those exceptions and emits an error status. The repository persists entities with `fromJson` and `toJson`, then converts them with the mapping extensions in `core/mapping/`. Callers receive models. UI models contain no JSON serialization. Other layers do not import `sqflite` or `shared_preferences`.

## Models

The class name ends in `Model`. Mapping lives in `core/mapping/[name]_mapping.dart`. That file imports both types. The model file and the entity file do not import each other. Only a repository imports the mapping file.

- `extension EntityNameMapping on EntityName` provides `ModelName toModel()`
- `extension ModelNameMapping on ModelName` provides `EntityName toEntity()`
- Entities and models both implement `copyWith`

Visual design is recorded in `DESIGN.md`.

### AccountModel

- `id`
- `name`
- `type`: `cash`, `bank`, `savings`, or `credit`
- `openingBalance`
- `sortOrder`
- `archived`

Cash, bank, and savings are assets. Credit is a liability, and its balance is the amount owed. Balance is the opening balance, plus income and transfers in, minus expenses and transfers out. Spending on a credit account increases the amount owed. A transfer into a credit account decreases it. Net worth is assets minus credit owed.

An account with transactions is not deleted. It can be archived only when its balance is zero. An archived account is omitted from the record picker.

### CategoryModel

- `id`
- `name`, optional
- `languageEn`, optional
- `languageZh`, optional. Traditional Chinese for `zh` and `zh_TW`
- `languageZhCn`, optional. Simplified Chinese
- `icon`
- `color`, one of the seven fixed colors in `DESIGN.md`
- `kind`: `expense` or `income`
- `sortOrder`
- `archived`

`name`, `languageEn`, `languageZh`, and `languageZhCn` have no default. An initial category stores the three language names and leaves `name` empty. A category the user creates stores `name` and leaves the language fields empty. The visible name is `languageZh` for Traditional Chinese, `languageZhCn` for Simplified Chinese, `languageEn` for English, and `name` when that language field is empty.

Expense and income keep separate lists. A transfer has no category. A category that has transactions is archived, not deleted. A category with no transactions can be deleted. Creating and editing categories happens in Settings. The record page only selects one.

### TransactionModel

- `id`
- `type`: `expense`, `income`, or `transfer`
- `amount`, greater than zero
- `date`
- `note`, optional
- `accountId` for an expense or income
- `categoryId` for an expense or income
- `fromAccountId` and `toAccountId` for a transfer

`amount` is the left-to-right result of the keypad expression. The expression itself is not stored. The two accounts on a transfer must be different.

An expense decreases its account. An income increases its account. A transfer moves the same amount between its two accounts, so net worth stays the same. Paying a credit card is a transfer from the funding account to the card. Changing type clears a category that belongs to the other kind.

### Settings

`AppSettingBloc` stores language, appearance (`light`, `dark`, or `system`), one currency, and the first weekday. Amounts are stored as numbers. The currency symbol comes from the currency setting.

### Month

The home summary and calendar share one month. That month has one balance: income minus expense. Transfers are excluded.

## Screens

The tab bar is Home, Analysis, Accounts, and Settings, with the record button in the center. Every tab uses that bar. The record page hides it. App bar titles are centered.

- Home is one page. The title is the month. One action switches summary and calendar.
- Summary shows income and expense, then a donut with the month balance in the center. Under the donut is a transaction list.
- Calendar uses the same month. A selected day shows that day's transactions.
- The record page title is the date and opens the date picker. A segment switches expense, income, and transfer. Expense and income use a category grid and one account, chosen from a bottom sheet. Transfer uses from and to, and has no account button. The check key commits. Edit uses the same page, and delete is the app bar action. Keypad layout is specified in `DESIGN.md`.
- Accounts shows assets, liabilities, and net worth. An account opens its detail: balance, movement for the month, history, and transfer.
- Analysis compares the selected month with the previous month, shows the last six months, then totals by category and by account.
- Settings edits language, appearance, currency, the first weekday, and categories.

## Widgets

Split a page into small widgets by responsibility, section, or interaction. Keep widgets used by one feature in `pages/[feature_name]/widgets/`. Move a widget to `lib/widgets/` only when more than one feature uses it and it has no feature-specific presentation logic.

## BLoC

Follow the [bloc library naming conventions](https://bloclibrary.dev/naming-conventions/).

- Events: `[Subject][Noun][Verb]` in past tense, such as `CounterIncrementPressed`
- One state class, `[Subject]State`, with a `[Subject]Status` enum (`initial`, `loading`, `success`, `failure`)
- Handlers are `_on[EventName]`, registered as `on<CounterIncrementPressed>(_onCounterIncrementPressed)`
- Every bloc has unit tests with `bloc_test`, covering success, failure, and boundary cases

## Invariants

- Use `final` fields and `const` constructors.
- Do not hardcode user-facing strings. Use `context.l10n.key` through a `ContextExtension`.
- Define `GoRouter` routes with an enum such as `AppRoutes`. Do not hardcode path strings.
- Repositories throw custom exceptions from `core/errors/`. Blocs catch them and emit an error state.
- A stored transaction amount is greater than zero.
- Monthly balance is income minus expense. Transfers stay out of it.
- A transfer keeps net worth unchanged and uses two different accounts.
- An account is archived only at a zero balance. A category with transactions is archived, not deleted.
