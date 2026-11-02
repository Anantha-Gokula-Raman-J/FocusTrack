# Prompt and task specification
- Dashboard/tray -> activity: timer deadline, tray Log now, or Preview. Guard prompt/busy; clear snackbars; render popup before native prompt request after endOfFrame.
- Activity -> checklist: validate trimmed note; atomically persist note and next deadline; only after success clear input and review tasks.
- Activity -> tray: Skip/native close persists next deadline without activity; clear draft after successful scheduling.
- Checklist -> tray: Done/native close does not log again or reschedule.
- Popup -> dashboard: explicit open first dismisses popup; failed dismissal/busy blocks transition.
- Dashboard manual log saves without resetting reminder.
- Timer checks every 10 seconds; overdue deadline triggers once while prompt/busy prevent duplicates.
- Midnight advances selected day only if it was the previous current day.

Tasks have text/done only. Add trims text. Empty input is ignored by UI/rejected by repository. Completion persists immediately and strikes through text. Dashboard deletion requires confirmation; popup only completes tasks. Disable mutations during saves. Commands use list indices: concurrent reordering would require stable IDs and a migration plan.

Failure: rollback, retain note, display error, never enter checklist after failed log; busy clears. Disposal cancels timer and native listener.

Tests: interaction_test.dart covers dashboard and popup journeys; workspace_controller_test.dart forces write failure/retry; layout_test.dart checks narrow/increased-text popup. Native placement requires manual Windows testing.
