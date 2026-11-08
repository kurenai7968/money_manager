---
id: "00043"
status: done
reads:
  - docs/architecture.md
---

# Trim the architecture

## Outcome

`docs/architecture.md` states each rule once. Repeated domain rules, status notes, and duplicate widget or bloc sentences are removed. Unique behavior stays in the section that owns it.

## Out of scope

Application code, `DESIGN.md`, and facts that exist only in the code.

## Done when

- [x] Repeated rules are gone from `docs/architecture.md`
- [x] `flutter test` passes

## Result

Each rule now lives in one section. Opening-balance behavior stays under `TransactionModel`. Screen calculations stay under BLoC. Coding constraints stay under Invariants. Repeated status notes and the same domain rules in Data flow and Invariants are gone. `flutter test` passed: 119 tests.
