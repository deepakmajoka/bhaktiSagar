# Project work rules

## Approval before edits

- Before editing any project file, explain the proposed change, name the files that would change, and why the change is needed.
- Wait for the user's explicit confirmation before making those edits. A request to inspect or discuss code is not permission to edit it.
- After confirmation, make only the approved, targeted changes. Do not rewrite existing code wholesale.
- Before each separate task or newly discovered scope, explain the proposed edits and get confirmation again.

## Task tracking

- Keep the checklist below current as work progresses. Mark a task complete only after its requested change is finished; record verification accurately and do not claim checks that were not run.
- Add newly agreed tasks to the checklist before starting them. Keep unfinished tasks unchecked.

## Current audit checklist

- [x] Read-only first pass over the Flutter app and record existing features and likely issues.
- [ ] Fix the stale widget-test import/template (`test/widget_test.dart`).
- [ ] Add or configure the bell audio asset and make playback feedback accurate.
- [ ] Replace or clearly label placeholder Panchang dates and calculations.
- [ ] Persist favorites across app restarts.
- [ ] Preserve the search keyword when changing the category filter.
- [ ] Design and implement AI aarti voice, bhajan playback, and bell-use choices.
- [x] Add Gemini AI spoken-reading controls for aarti text. Implementation added; runtime validation not run.
- [ ] Design and implement prompt-based devotional image generation and editable text overlay.

The unchecked items above are audit findings or future ideas, not approved edits. Get the user's confirmation before starting any of them.
