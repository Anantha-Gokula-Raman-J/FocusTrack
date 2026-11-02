# Feature contracts

## Prompt and tasks
Log requires trimmed nonempty text and saves before entering checklist mode. Checkbox updates persist immediately. Skip/close on the activity form records no activity. Checklist Done/close does not log again or reset the already scheduled reminder. Scheduling uses the saved interval and persisted nextPrompt.

## Settings
Custom interval accepts integers 1–1440. Invalid input must not mutate stored configuration. Applying restarts the countdown from now. Default/legacy missing interval is 60. Startup preference controls per-user Windows startup registration.

## Reports
Date selection scopes every copy operation to that whole day, regardless of the display search filter. Timestamped copy retains date/time. Bullet copy produces one bullet per activity, without timestamps; multiline continuations are indented. Text and bullet buttons are disabled for empty days. JSON copy remains available.

## Data and compatibility
JSON schema remains version 1. Writes are serialized, use a temporary file and preserve a backup. Failed changes restore in-memory state. Corrupt primary is preserved before backup recovery. Unrecoverable data is surfaced, not silently replaced. Migration is copy-only and idempotent.
