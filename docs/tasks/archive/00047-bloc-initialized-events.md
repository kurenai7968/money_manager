---
id: "00047"
status: done
reads:
  - docs/architecture.md
---

# Rename bloc started events

## Outcome

Every page-bloc event named `XxxStarted` is renamed to `XxxInitialized`. Dispatch sites, handlers, and tests use the new name.

## Out of scope

Behavior, state fields, and other event names stay the same.

## Done when

- [x] No `XxxStarted` bloc event remains
- [x] `flutter test` passes

## Result

Page-bloc events `AccountsStarted`, `AccountFormStarted`, `AccountDetailStarted`, `HomeStarted`, `RecordStarted`, `AnalysisStarted`, and `CategoriesStarted` are now `AccountsInitialized`, `AccountFormInitialized`, `AccountDetailInitialized`, `HomeInitialized`, `RecordInitialized`, `AnalysisInitialized`, and `CategoriesInitialized`. Dispatch sites, handlers, and tests use those names. The Widgets example in `docs/architecture.md` dispatches `XxxInitialized`. `flutter test` passed.
