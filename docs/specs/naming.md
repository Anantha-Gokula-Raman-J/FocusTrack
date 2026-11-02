# Naming specification
Brand: FocusTrack. Dart package: focustrack. Classes: FocusTrackApp and FocusTrackStore. CMake project/executable: focustrack. Channel: focustrack/windows on both sides. Current mutex: Local\FocusTrackActivityTracker.
The user requested removal of old naming, superseding previous internal-name retention decisions.
Only upgrade compatibility may retain the former name: legacy_migration.dart and its fixture (old data path), legacy_compatibility.h (old registry value/mutex), upgrade documentation and historical records.
Hold both mutexes to prevent concurrent older installations. Read/remove old startup registration. Never replace legacy data paths with current ones.
Acceptance: package/config/classes/channel/CMake/IDE use FocusTrack; migration tests and build pass. Refresh generated caches through Flutter; historical work/build artifacts are not authoritative source.
scripts/check-architecture.ps1 guards package/class/channel/CMake naming against regression; old data literals remain an explicit exception.
