# Contributing to FocusTrack
Thanks for helping make everyday work easier to remember.

## Before you start
Read AGENTS.md, docs/specs/README.md and the relevant feature spec. Use scripts/context.ps1 -Task <feature> for context. Update a spec first if behavior changes.

## Development
Install Flutter and the Visual Studio C++ toolchain described in README.md. Run flutter pub get, then scripts/verify.ps1. For platform changes also build Windows Release and exercise tray, popup, startup and quit behavior.
Keep changes within the owning layer. Use typed repository commands rather than changing JSON from widgets. Preserve existing users' data and migration support.

## Pull requests
Explain the problem, intended behavior, edge cases, tests run and remaining manual checks. Include screenshots for UI changes using fictional data.
Do not commit build artifacts, logs, credentials, activity JSON, backups or IDE settings.

## Issues
Include app/Windows versions, reproduction steps and expected/actual behavior. Remove personal information from screenshots and logs. For suggestions, explain the everyday task you want to improve.

By contributing, you agree that your contribution may be distributed under this project's MIT license.
