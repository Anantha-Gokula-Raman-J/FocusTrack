# Edge cases and invariants

- Empty/whitespace activity: reject; preserve current input on save failure.
- Multiline notes: preserve stored content; indent continuation lines in bullet exports.
- Empty selected day: no phantom activities; text/bullet copy disabled.
- Search filter: affects display only, not full-day exports.
- Midnight: group activities by local date of their timestamp.
- Invalid interval, fractions, zero, negative or >1440: reject without mutation.
- Legacy data without interval: load 60 minutes.
- Restart/overdue prompt: use persisted deadline; avoid duplicate concurrent prompts.
- Close vs Quit: close hides, explicit tray Quit terminates.
- Repeated launch: single instance; startup launch remains silent.
- Disk failure: do not claim success or discard saved data; serialize writes.
- Corruption: preserve damaged primary, recover backup when available.
- Migration: never overwrite an existing FocusTrack primary.
- Narrow dashboard (760px) / increased text size: wrap controls; no clipping.
- Popup checklist may be long: scroll content and keep footer usable.
- Multi-monitor/DPI/taskbar positioning: native work-area placement; verify manually.
- Portable release: package complete data/DLLs, never include personal JSON.
