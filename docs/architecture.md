---
synced_commit: 2cbf8238ee3122105448040f1c5729f743ad957a
---

# Architecture

Use a maintainable layered architecture. Keep code testable, and do not add abstraction until a task needs it.

The checked-in app is still the Flutter template: `lib/main.dart` with the counter `MyHomePage`, and `test/widget_test.dart`. The sections below are the target. New code follows them. Add packages and folders only when a task needs them.

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
