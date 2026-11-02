# Specs-first context index
Before application code or edits, read in order:
1. product.md
2. architecture.md (task/source/test map)
3. edge-cases.md
4. verification.md
5. features.md and relevant feature specs:
   - prompts.md: capture, reminders, checklist/tasks
   - settings.md: interval/startup
   - reports.md: daily view/search/copy
   - storage.md: schema/backups/migration
   - windows.md: native protocol/tray
   - ui.md: layout/responsive constraints
   - release.md: build/launcher/distribution

Run scripts/context.ps1 -Task <prompts|settings|reports|storage|windows|ui|release|architecture>
to print required context and feature spec. Architecture work reads all features.
Then inspect mapped source/tests only. Update specs before behavior changes; record validation in docs/validation.md.
AGENTS.md is the entry point for cooperating agents; documentation cannot force arbitrary external tools to comply.
For naming/package/native identity changes, read naming.md before source. This supersedes earlier internal-name retention decisions.
For public repository preparation, read publication.md before changes.
