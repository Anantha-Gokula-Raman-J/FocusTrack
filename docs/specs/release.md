# Build and distribution
scripts/verify.ps1 checks source; -Build also builds Release. Launch FocusTrack.cmd runs build/windows/x64/runner/Release/focustrack.exe; the obsolete Launch Daymark.cmd has been removed. Quit old tray instance before verifying updates.
scripts/package-windows.ps1 needs a release CRT directory and Flutter SDK. Choose fresh output directory. Bundle exe, flutter_windows.dll, full data, CRT DLLs, notices/instructions and hashes. Never ship personal JSON. Extract ZIP and validate every manifest hash.
Current identity: FocusTrack 1.2.2+5, unsigned Windows x64 portable. Structural refactor preserves version/schema. Future published version bumps must update pubspec, Preferences label, package name, docs and instructions together.
Do not package an old executable after failed build. Toolchain invalid-handle fallback is documented in verification.md.
Public release packages include the root MIT LICENSE alongside third-party notices. Source commits exclude all compiled output and private work files.
