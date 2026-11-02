# Validation record — architecture/harness refactor, 2026-11-02

Changes:
- main.dart reduced from approximately 1,600 lines to a 7-line bootstrap/compatibility entrypoint.
- Separate app composition/theme, feature views, ChangeNotifier workflow controller, typed repository contract/entities, pure report formatter, JSON adapter/migration and Windows adapter.
- Added specs-first AGENTS.md, task context loader, source/spec/test maps, edge-case contracts, architecture guards and verification scripts.
- Preserved version 1.2.1+4, JSON v1, legacy identifiers and existing app behavior.

Evidence:
- Architecture boundary script passed.
- JIT static analyzer completed without errors/warnings.
- Formatter reports 27 Dart files already formatted.
- 15 tests passed, including new report format and failed-save rollback/retry coverage. Successful verbose Flutter test run exited 0 (work/architecture-test-verbose.log).
- Refreshed widget renders reviewed: Preferences and activity popup. Responsive layout test passed.
- Normal Flutter Windows Release build succeeded, exit 0, zero native warnings/errors (work/architecture-build-verbose.log). Launcher target rebuilt.

Environment limitation:
Some host Dart/Flutter invocations intermittently exit -1073741816 (invalid handle), even after printing results. The combined verify command was exercised but stopped at this host failure during formatting; individual analysis, test and build commands were validated separately. The harness fails closed and retries that code at most three times; diagnostics and JIT analysis are available. A printed pass from a crashed process alone was not accepted as complete evidence.

Not performed:
Live Windows tray/sign-in/clipboard/monitor matrix, reboot or clean-PC testing. No new distribution ZIP is published by this structural refactor; existing dist packages remain earlier artifacts. The project-local Release executable is rebuilt.

## Latest rebuild and launcher cleanup — 2026-11-02
Removed obsolete Launch Daymark.cmd and build/windows/x64/runner/Release/daymark.exe. Launch FocusTrack.cmd remains the project launcher.
Rebuilt latest source using normal Flutter Release build: exit 0, zero warnings/errors (work/latest-build-out.log).
Refreshed dist/FocusTrack-1.2.1-Windows-x64 and its ZIP. Extracted archive and verified all 25 manifest files.
Earlier distribution versions remain historical artifacts; the previous 1.2.1 folder was moved under ignored work/release-* for recovery.
Application source was unchanged during this cleanup; the preceding 15-test and clean-analysis evidence still applies. No live app launch or clean-PC test was performed in this rebuild.

## Complete current-identity rename — 2026-11-02
Version 1.2.2+5: package focustrack; FocusTrackApp/FocusTrackStore; focustrack/windows channel on both sides; CMake/IDE names updated. Current mutex uses FocusTrack and retains an isolated legacy gate to prevent concurrent older versions.
Remaining former-name literals are confined to migration inputs, legacy registry/mutex compatibility, migration tests and historical/upgrade documentation.
Offline pub get exited 0; package configuration confirms focustrack. Architecture/naming checks and static analysis passed. All 15 tests passed with exit 0 (work/rename-test.log).
Initial Flutter build hit the host invalid-handle failure. Generated Windows INSTALL project then built successfully through MSBuild with exit 0 (work/rename-native-build.log).
Packaged 1.2.2 and verified all 25 extracted manifest files. Live mixed-version launching/startup registration and clean-PC behavior remain manual checks.

## Public repository preparation — 2026-11-02
MIT selected by the owner. Added README with fictional-data screenshots, build/use/privacy instructions and CONTRIBUTING.md. Expanded ignores for personal data, credentials and generated binaries. Development scripts now discover Flutter from PATH/FLUTTER_ROOT or an explicit parameter; screenshot font discovery uses package configuration.
15 tests passed after the documentation/screenshot-fixture update; static analysis clean. Screenshot-specific icon path issue found during visual review and corrected before publication.
No application runtime changes in this preparation. The existing 1.2.2 Release binary is reused with updated license/notices packaging.
