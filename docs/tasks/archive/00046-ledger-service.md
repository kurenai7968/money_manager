---
id: "00046"
status: done
reads:
  - docs/architecture.md
  - lib/repositories/ledger_repository.dart
  - lib/app_providers.dart
---

# Ledger service

## Outcome

`LedgerRepository` becomes `LedgerService` under `lib/services/`. Page blocs call that service for cross-table ledger operations. Table repositories stay in `lib/repositories/`.

## Out of scope

Changing how accounts, categories, and opening balances are loaded or saved.

## Done when

- [x] `lib/services/` holds `LedgerService` and `LedgerServiceImpl`
- [x] No `LedgerRepository` remains
- [x] `flutter test` passes

## Result

`lib/services/ledger_service.dart` holds `LedgerService` and `LedgerServiceImpl`. `AppProviders` provides `LedgerServiceImpl` with the three table repositories. Page blocs call `LedgerService` for load, opening sync, save, and delete. Table repositories stay in `lib/repositories/`. `flutter test` passed (116).
