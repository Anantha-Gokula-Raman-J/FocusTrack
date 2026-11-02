# Verification and release

Use Flutter on PATH, FLUTTER_ROOT, or -FlutterSdk. The standard Windows package cache is %LOCALAPPDATA%/Pub/Cache. The verification script uses work/temp for TEMP/TMP.

Required for architecture changes:
- Static analysis of lib and test.
- Full Flutter test suite with --no-pub --concurrency=1.
- Windows Release build when native/startup/entrypoint integration changes.
- Inspect responsive screenshots for any changed visual structure.
- Verify compatibility imports and persisted JSON remain stable.

The environment can intermittently abort Dart/Flutter with invalid-handle exit -1073741816. An empty log is not a pass. Retry with diagnostics; scripts/analyze.ps1 uses the JIT analysis server when necessary. Native CMake/MSBuild can drive the generated Flutter build if the parent Flutter process fails.

Manual checks: tray startup, close/minimize hide, popup placement, clipboard paste into another app, startup after sign-in, clean Windows PC. Automated widget tests cannot establish these.
Release packaging: scripts/package-windows.ps1; use a fresh output directory. Validate SHA256SUMS after extracting the ZIP. Do not claim a rebuilt executable or clean-PC validation without evidence.

## Repeatable commands
- scripts/context.ps1 -Task reports (or another feature) prints required context.
- scripts/verify.ps1 runs boundaries, format check, analysis and all tests.
- scripts/verify.ps1 -UseJitAnalyzer uses the bounded JIT analyzer fallback.
- scripts/verify.ps1 -Build additionally builds the Windows release.
- Set UI_SCREENSHOTS=1 before verification to refresh widget screenshots.

verify.ps1 retries only the known -1073741816 toolchain crash, at most three times; other failures stop immediately. Analysis fails on errors/warnings and incomplete output. Never infer success solely from a log containing an old passing run.

Manual build fallback after parent Flutter crashes:
Set the environment as above; run CMake with -S windows -B build/windows/x64, then MSBuild build/windows/x64/INSTALL.vcxproj /p:Configuration=Release /p:Platform=x64. This still invokes Flutter assembly through the generated project. Require exit 0 and fresh release artifacts.

## Coverage map
| Invariant | Evidence |
| --- | --- |
| Midnight grouping/multiline data | widget_test.dart |
| Serialized writes, corrupt backup, migration | widget_test.dart |
| Custom/default interval persistence | widget_test.dart, interaction_test.dart |
| Log -> checklist; Skip; Done; tray-open command | interaction_test.dart |
| Responsive dashboard/popup at 125% | layout_test.dart |
| Bullet/text/JSON formats and empty exports | report_formatter_test.dart |
| Failed write retains note, rolls back deadline, retry works | workspace_controller_test.dart |
| Immutable typed task snapshots and persisted commands | workspace_controller_test.dart |
| Windows placement/sign-in/clipboard/clean PC | manual, not automated |

Use -Diagnostics on verify.ps1 for verbose Flutter test output; detailed logs help isolate host crashes.
