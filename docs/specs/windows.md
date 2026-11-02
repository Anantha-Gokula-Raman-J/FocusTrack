# Windows integration specification
Adapter: lib/platform/windows_desktop.dart; stable channel focustrack/windows.
Outbound: folder(path), open, prompt, dismiss, quit, startup(bool), startupEnabled -> bool.
Inbound typed events: skip, logNow, open, quit. Unknown events ignored.

Runner owns tray icon/menu, hidden startup, close/minimize-to-tray, explicit quit, bottom-right tool window/work-area placement, full dashboard on explicit open, startup registry and legacy cleanup.
Current mutex: Local\FocusTrackActivityTracker; hold the legacy compatibility mutex too (see naming.md). Duplicate interactive launch informs; --startup stays silent.
Keep Dart/native command names compatible; update both together when needed.

Mocked tests prove calls/order only, not placement, taskbar, DPI, registry/sign-in or foreground behavior. Manual monitor/clean-PC matrix is not automated.
