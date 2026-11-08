---
synced_commit: bab577133619c34d9b18d9284e23757c5bad1612
---

# Architecture

Use a maintainable layered architecture. Keep code testable, and do not add abstraction until a task needs it.

## Tech stack

- Framework: Flutter (stable). Language: Dart.
- UI: `material_ui`, imported as `package:material_ui/material_ui.dart`.
- Calendar: `table_calendar`. The home month grid and the record date picker both use `TableCalendar`. Do not build a day grid and do not call `showDatePicker`.
- State management: `flutter_bloc`
- Navigation: `go_router`
- Localization: ARB files generate `AppLocalizations`. `MaterialApp` registers `AppLocalizations.localizationsDelegates` and `GlobalMaterialLocalizations.delegates` from `material_ui`.
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
├── app.dart                       # AppProviders, then BlocBuilder applies theme mode and locale to MaterialApp.router
├── app_config.dart                # Banner ids, app setting keys, and similar constants
├── app_providers.dart             # RepositoryProviders and AppSettingBloc
├── l10n/                     # Localization (.arb files)
├── core/
│   ├── utils/                # Shared helpers, including JsonConverter
│   ├── errors/               # Custom exceptions and failures
│   ├── extensions/           # Context, String, and Date
│   └── mapping/              # toModel and toEntity. One file per pair.
│       └── [name]_mapping.dart
├── database/
│   ├── sqlite/               # sqflite connection
│   │   └── tables/           # SQL table definitions
│   │       └── [name]_table.dart
│   └── shared_preferences/   # wrapper around package:shared_preferences
├── entities/                 # Persistence types. json_serializable, fromJson, toJson, Equatable.
├── models/                   # UI and business data only. No entity mapping on the class.
├── repositories/             # One interface and one [Name]RepositoryImpl per data source
├── pages/
│   ├── [feature_name]/
│   │   ├── bloc/             # Feature-specific bloc
│   │   ├── widgets/          # App bar, body, and other widgets for this feature
│   │   └── [feature]_page.dart  # BlocProvider and Scaffold only
│   └── pages.dart            # Exports every [feature]_page.dart under pages/
├── routes/                   # GoRouter configuration
├── themes/                   # Light and dark ThemeData, exposed as AppThemes.light and AppThemes.dark
└── widgets/                  # Widgets reused across features
```

## Data flow

`App` is a `StatelessWidget`. `AppProviders` constructs `AccountRepositoryImpl`, `CategoryRepositoryImpl`, `TransactionRepositoryImpl`, and `AppSettingRepositoryImpl`, then provides those repositories and `AppSettingBloc`. It does not take repository arguments. Each implementation is named `[Name]RepositoryImpl` and takes named constructor arguments (`database` for SQLite, `store` for settings). `MaterialApp` reads language and `appThemeMode` from `AppSettingBloc` through a `BlocBuilder` whose `buildWhen` watches `appThemeMode` and `locale`, so that bloc stays above the router. A page creates the other blocs it uses and dispatches their start events. When an ancestor already provides one of those blocs, the page uses that instance. A page that stays mounted reloads those blocs when the route changes, so a save on another route shows up after returning.

A page dispatches a bloc event. The bloc calls a repository. The repository reads and writes SQLite through `database/sqlite`, and key-value settings through `database/shared_preferences`. It throws exceptions from `core/errors/`. The bloc catches those exceptions and emits an error status. The repository persists entities with `fromJson` and `toJson`, then converts them with the mapping extensions in `core/mapping/`. Callers receive models. Other layers do not import `sqflite` or `shared_preferences`.

## Models

The class name ends in `Model`. Mapping lives in `core/mapping/[name]_mapping.dart`. That file imports both types. The model file and the entity file do not import each other. Only a repository imports the mapping file. UI models contain no JSON serialization.

- `extension EntityNameMapping on EntityName` provides `ModelName toModel()`
- `extension ModelNameMapping on ModelName` provides `EntityName toEntity()`
- Entities and models both implement `copyWith`

### AccountModel

- `id`
- `name`, optional
- `languageEn`, optional
- `languageZh`, optional. Traditional Chinese for `zh` and `zh_TW`
- `languageZhCn`, optional. Simplified Chinese
- `type`: `cash`, `bank`, `savings`, or `credit`
- `openingBalance`
- `sortOrder`
- `archived`

`name`, `languageEn`, `languageZh`, and `languageZhCn` have no default. An empty account list gets one cash account with opening balance 0. That account stores Cash, 現金, and 现金 in those language fields and has no `name`. An account the user creates stores `name` and leaves the language fields empty. The visible name follows the active language the same way a category does.

Cash, bank, and savings are assets. Credit is a liability, and its balance is the amount owed. Balance is the opening balance, plus income and transfers in, minus expenses and transfers out. Spending on a credit account increases the amount owed. A transfer into a credit account decreases it. Net worth is assets minus credit owed. Opening balance may be negative.

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
- `amount`, greater than zero. Amounts are numbers.
- `date`
- `note`, optional
- `accountId` for an expense or income
- `categoryId` for an expense or income
- `fromAccountId` and `toAccountId` for a transfer

`amount` is the left-to-right result of the keypad expression. The expression itself is not stored. The two accounts on a transfer must be different.

An expense decreases its account. An income increases its account. A transfer moves the same amount between its two accounts, so net worth stays the same. Paying a credit card is a transfer from the funding account to the card. Changing type clears a category that belongs to the other kind.

An account's opening balance is one income or expense on that account. A positive balance stores an income of that amount. A negative balance stores an expense of the absolute amount. A zero balance deletes that transaction. The user edits that transaction on the record page. Saving it writes the signed amount back to the account opening balance: income is positive, expense is negative. Deleting it, changing it into a transfer, or moving it to another account sets the original opening balance to zero. An account that already has a non-zero opening balance and no matching transaction gets one when accounts load. A stored opening row is read as income. Balance still starts from `openingBalance` and does not apply this transaction again. Monthly balance includes it as income or expense. For a credit account, `openingBalance` remains the amount owed.

### Settings

`AppSettingModel` stores `languageCode`, `countryCode`, `appThemeMode`, and `firstDayOfWeek`. `appThemeMode` is `AppThemeMode`: `system`, `light`, or `dark`. The JSON field name stays `appearance`. The first day of the week is `FirstDayOfWeek`, Monday through Sunday. The default is Monday. The stored value is the weekday name.

### Month

The home summary and calendar share one month. That month has one balance: income minus expense. Transfers are excluded.

## Screens

The tab bar is Home, Analysis, Accounts, and Settings, with the record button in the center. Every tab uses that bar. The record page hides it. App bar titles are centered.

- Home is one page. The title is the month. A leading control selects one account or all accounts. One action switches summary and calendar. Summary, calendar, and the transaction list follow that selection. All accounts is the default. A single account includes its expenses, incomes, and transfers that use it. Archived accounts stay out of the picker. When the selected account is gone, the selection returns to all accounts. The choice lasts for this home session.
- Summary shows income and expense, then a donut with the month balance in the center. Under the donut is a transaction list.
- Calendar uses the same month. A selected day shows that day's transactions.
- The record page title is the date and opens the date picker. A segment switches expense, income, and transfer. Expense and income use a category grid and one account, chosen from a bottom sheet. Transfer uses from and to, and has no account button. The check key commits. Edit uses the same page, and delete is the app bar action. Keypad layout is specified in `DESIGN.md`.
- Accounts shows assets, liabilities, and net worth. An account opens its detail: balance, movement for the month, history, and transfer.
- Analysis compares the selected month with the previous month, shows the last six months, then totals by category and by account.
- Settings edits language, theme mode, the first weekday, and categories.

## Widgets

`[feature]_page.dart` only creates the page blocs and a scaffold. The app bar and the body are widgets in `pages/[feature_name]/widgets/`:

```dart
BlocProvider(
  create: (context) => XxxBloc(context.read())..add(const XxxStarted()),
  child: const Scaffold(appBar: XxxAppBar(), body: XxxBody()),
)
```

A page that needs more than one bloc nests those providers the same way. `SettingsPage` does not create `AppSettingBloc`. The bloc for that screen holds the decisions shared by the app bar and the body: selected month, selected day, summary or calendar, the home account (one account or all), analysis kind, and the record draft. Widgets read that state and send events. They format text, paint, and lay out children. A widget keeps a controller only for a text field or a tab bar.

Split the rest of a screen into small widgets by responsibility, section, or interaction. Keep widgets used by one feature in `pages/[feature_name]/widgets/`. Move a widget to `lib/widgets/` only when more than one feature uses it and it has no feature-specific presentation logic.

An account's opening balance appears in the account history and the home list as an income or an expense. Tapping it opens the record page.

## BLoC

A widget dispatches one event for the field the user changed. `AppSettingBloc` handles `AppSettingLanguageChanged`, `AppSettingThemeModeChanged`, and `AppSettingFirstDayOfWeekChanged`. Each handler copies the current `AppSettingModel` and saves that copy. The widget does not send a replacement model.

A screen bloc may subscribe to another bloc and emit the figures and lists that screen shows. That includes which transactions fall in the month, month totals, day nets, analysis rollups, asset and liability groups, net worth, account history, and whether a record or form can be saved. The bloc calls the pure functions in `core/utils/`. Widgets display the emitted state and do not derive those figures.

Follow the [bloc library naming conventions](https://bloclibrary.dev/naming-conventions/).

- Events: `[Subject][Noun][Verb]` in past tense, such as `CounterIncrementPressed`
- One state class, `[Subject]State`, with a `[Subject]Status` enum (`initial`, `loading`, `success`, `failure`)
- Handlers are `_on[EventName]`, registered as `on<CounterIncrementPressed>(_onCounterIncrementPressed)`
- Every bloc has unit tests with `bloc_test`, covering success, failure, and boundary cases

## Invariants

- Use `final` fields and `const` constructors.
- Declare fields before the constructor.
- Do not hardcode user-facing strings. Use `context.l10n.key` through a `ContextExtension`.
- Define `GoRouter` routes with an enum such as `AppRoutes`. Do not hardcode path strings.
