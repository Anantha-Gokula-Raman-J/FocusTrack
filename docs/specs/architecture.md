# Architecture and source map

Read product.md first, then select the relevant feature spec before mapped code.

| Task | Spec | Primary source | Regression evidence |
| --- | --- | --- | --- |
| Boot/data-load failure | storage.md | lib/app/bootstrap.dart, focustrack_app.dart | widget_test.dart; manual corrupt startup |
| Theme/spacing | ui.md | lib/app/app_theme.dart, lib/presentation/components.dart | layout_test.dart |
| Reminder/popup transition | prompts.md | lib/application/workspace_controller.dart, lib/presentation/activity_prompt.dart, task_review.dart | interaction_test.dart, workspace_controller_test.dart |
| To-do list | prompts.md | lib/presentation/todo_panel.dart, application/workspace_controller.dart | interaction_test.dart, workspace_controller_test.dart |
| Intervals/preferences | settings.md | lib/presentation/preferences_view.dart, application/workspace_controller.dart | interaction_test.dart, widget_test.dart |
| Reports/copy | reports.md | lib/presentation/reports_view.dart, lib/domain/report_formatter.dart | report_formatter_test.dart |
| JSON/backup/migration | storage.md | lib/data/activity_store.dart, legacy_migration.dart | widget_test.dart, workspace_controller_test.dart |
| Tray/startup/window/quit | windows.md | lib/platform/windows_desktop.dart, windows/runner/flutter_window.cpp, main.cpp | mocked interactions + manual Windows |
| Packaging | release.md | scripts/package-windows.ps1, packaging/, windows/runner/Runner.rc | verify.ps1 -Build; extracted hashes |

## Layer boundaries
- main.dart: entrypoint plus compatibility exports only.
- app: bootstrap, theme, error page and workspace composition.
- presentation: StatelessWidget feature classes and shared display helpers. Workspace shell owns controller lifecycle and snackbar callbacks. No raw JSON mutation or method-channel strings.
- application/WorkspaceController: ChangeNotifier owning transient UI state, input controllers, timer, busy guard, activity/task/settings commands, clipboard and popup transitions. Accepts ActivityRepository and WindowsDesktop; never retains a BuildContext.
- domain: immutable ActivityEntry/TodoItem, ActivityRepository contract, date labels and ReportFormatter. No Flutter, filesystem or native dependencies.
- data/FocusTrackStore: implements ActivityRepository using version-1 JSON, serialized writes and rollback. Mutable maps remain for compatibility/legacy fixtures; new application code must use the typed interface.
- platform/WindowsDesktop: typed commands/events translated to the stable focustrack/windows channel.
- windows/runner: Win32 behavior; Dart does not reposition windows.

Dependencies: presentation -> application -> domain contract; application -> platform adapter; data -> domain; app composes the layers. Feature widgets receive the same controller from the shell, which rebuilds on notifications. One controller/timer per shell; dispose inputs/timer/channel handler.

Compatibility: lib/store.dart re-exports relocated repository/migration/date key; lib/main.dart re-exports FocusTrackApp/native for existing callers. Package focustrack, FocusTrack classes, focustrack/windows channel and current mutex use the current name. Only isolated upgrade identifiers retain old names; see naming.md.

Prefer classes with real responsibilities. Keep formatting pure, disk operations in repository and workflows in controller. Update this map when files move. Do not use part files/state mixins to spread one hidden global class across files.
