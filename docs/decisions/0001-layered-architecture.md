# 0001 — Layered Flutter architecture with explicit adapters
Status: accepted, 2026-11-02.

Problem: one main.dart combined boot, state, timer, native calls, formatting and every screen, requiring broad rereads for small changes.

Decision: use a small composition root; ChangeNotifier workspace controller; immutable domain values and repository contract; JSON and Windows adapters; independent feature widgets. Keep pure report formatting in domain. Existing Flutter SDK APIs suffice; no new runtime dependencies.

Compatibility: retain JSON v1, legacy migration, internal package/channel/mutex and public compatibility exports. Existing app appearance and user journeys stay stable.

Tradeoffs: controller still coordinates several related workflows and owns Flutter input controllers; it is a presentation-facing application model, not a framework-free domain object. Mutable JSON APIs remain on concrete FocusTrackStore for compatibility; new feature code only sees ActivityRepository. Index-based task identity is adequate without reordering/concurrent task editing.

When to revisit: add stable task IDs before reorder/sync; split controller further when a genuinely independent workflow appears; do not introduce generic abstractions for their own sake.
Update: the explicit naming request supersedes internal identifier retention. Package/classes/channel now use FocusTrack; only data/startup/dual-mutex upgrade compatibility keeps legacy literals. See specs/naming.md.
