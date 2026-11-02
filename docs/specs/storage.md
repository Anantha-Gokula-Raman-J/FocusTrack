# Persistence specification
Location: %APPDATA%/FocusTrack/focustrack.json; working-directory fallback when APPDATA absent.
Version 1:
- days: yyyy-MM-dd -> [{at: local ISO timestamp, text: string}]
- todos: [{text: string, done: boolean}]
- intervalMinutes: integer 1–1440; absent legacy value -> 60
- nextPrompt: ISO timestamp
- startupInitialized: optional boolean

ActivityEntry/TodoItem are immutable snapshots. ActivityRepository exposes typed reads/commands. Legacy mutable maps are for compatibility/fixtures only.

Serialized writes snapshot in-memory JSON, apply mutation, write .tmp with flush, back up existing primary to .bak, then rename temp. Failure restores snapshot and rethrows; queue continues. Prompt logging and reschedule are one atomic repository command.

Load validates version/container/date/text/task/interval values. Preserve bad primary as .damaged-<milliseconds>, then recover valid backup with message. No valid backup -> visible failure, never discard data.

Migration copies Daymark primary only if FocusTrack primary absent. Copy backup first, then primary via .migrating. Never delete/overwrite originals.

Limits: local unencrypted JSON, not a cross-process database; native single-instance enforcement matters. Backup retains only previous primary. Power-loss durability needs separate validation. Fatal load-page visibility under hidden startup remains a manual check.
