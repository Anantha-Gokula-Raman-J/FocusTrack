# Settings specification
Presets: 10, 30, 45, 60 default minutes. Custom field is digits-only; controller parses integer 1–1440. Repository independently enforces bounds. Presets persist immediately; custom value persists on Apply.

Success stores interval and nextPrompt together, updates input, clears validation error and confirms. Invalid input preserves stored values; IO failure retains input.

Startup: first successful initialization enables per-user startup and persists startupInitialized. Existing enabled registration is refreshed to current executable. Native adapter handles old Daymark registry value. Switch updates after native success. Startup lives in registry, not JSON schedule.

Tests: widget_test.dart covers persisted/default intervals; interaction_test.dart covers invalid/preset/custom values. Sign-in remains a manual Windows check.
