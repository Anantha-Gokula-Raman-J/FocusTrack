# Product context

FocusTrack is a fully offline Windows Flutter activity journal for team leads and managers. Short periodic notes help reconstruct a full workday while managing engineers.

Baseline release: 1.2.2+5. Former user-facing name: Daymark. Current package/channel/class names use FocusTrack. Upgrade compatibility is isolated; see naming.md.

User journeys:
- Start quietly in the tray; explicitly open the dashboard from its icon/menu.
- Show a compact bottom-right activity prompt above the taskbar, without a taskbar button.
- Log a nonempty note, then review and complete to-dos in the same popup.
- Skip or close the activity prompt without logging; Done closes the checklist.
- Configure 10, 30, 45 or 60 minute reminders, or whole custom minutes 1–1440; default 60.
- View daily reports; copy timestamped text, raw JSON or bullet points without timestamps.
- Keep todos without deadlines, with checked text struck through.
- Closing/minimizing the dashboard keeps the app alive. Explicit tray Quit exits.

Personal data: %APPDATA%/FocusTrack/focustrack.json. Legacy %APPDATA%/Daymark/daymark.json is copied on first migration without deleting originals or replacing current data. No telemetry or account/network requirement.

Distribution: Windows x64 portable folder containing executable, Flutter data/DLLs and application-local Microsoft CRT. Existing launcher points at the local Release build. A successful source check alone does not update a shipped executable.
