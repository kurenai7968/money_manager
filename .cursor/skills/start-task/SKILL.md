---
name: start-task
description: >-
  Reads docs/architecture.md and the matching task file before code changes,
  syncs docs with manual edits, asks before architecture changes, runs flutter test,
  and archives finished tasks. Use when the user asks to implement, fix, add,
  change, refactor, or start a task (做、改、修、加、任務) in this repository.
---

# Before starting

1. Find the task. Open the file when the user names an id. When no task file matches, take one more than the highest five-digit id in `docs/tasks/` and `docs/tasks/archive/` (`00001` when none exist). Create `docs/tasks/NNNNN-short-name.md` from [TEMPLATE.md](../../../docs/tasks/TEMPLATE.md) with `status: in-progress`, an English Outcome from the request, and `reads` that include `docs/architecture.md`. Add the id and title under In progress in `docs/tasks/README.md`. Write `docs/` and task files in English.
2. Read `synced_commit` at the top of `docs/architecture.md`. When the field is missing, set it to the current `HEAD` and compare only uncommitted changes this time.
3. Compare the code:

```bash
git rev-parse HEAD
git status --porcelain
git diff <synced_commit> -- lib test pubspec.yaml analysis_options.yaml android ios
```

4. Skip behavior, layout, and data flow that the docs already describe. For anything missing:
   - Any architecture section other than `synced_commit`: ask before editing `docs/architecture.md`. Write the doc in English.
   - A change inside an `in-progress` task's Outcome: update that task file directly.
   - A conflict with an open task's Outcome or with the architecture: stop and wait.
5. Read the architecture, this task file, and every path in its `reads:` list. Do not read `docs/tasks/archive/` unless the user names a task there.
6. When the user names an archived task to continue, move that file back to `docs/tasks/`, set `status` to `in-progress`, update `README`, then resume at step 2.
7. Reply with the id, Outcome, and files to change, then edit code. Ask before writing code that changes Tech stack, Layout, Data flow, Models, Widgets, BLoC, or Invariants.

Ask in this form and wait for approval before editing the doc or writing that code:

```text
Architecture change:
- File: docs/architecture.md
- Section: Data flow
- New text: ...
Approve this change?
```

# After finishing

1. Run `flutter test`. Finish only after it passes. Fix failures and rerun. Do not set `status` to `done` while tests fail.
2. Write the actual result in Result, including that tests passed, and set `status` to `done`.
3. Move the file to `docs/tasks/archive/` without renaming it.
4. In `docs/tasks/README.md`, remove the row from In progress and add the id and title under Archive.
5. When the result differs from `docs/architecture.md`, ask before editing the architecture. Update `synced_commit`, the task file, and `README` directly.
6. When `git status --porcelain` prints nothing, set `synced_commit` to the current `HEAD`. Leave it unchanged while uncommitted changes remain.
