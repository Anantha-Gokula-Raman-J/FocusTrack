# UI specification
Preserve Segoe UI, green/neutral Material 3 theme, responsive cards, consistent minimum 44px buttons. Custom interval field/Apply align at 48px; wrap narrow controls.
Workspace narrow mode uses LayoutBuilder width <960px, not global MediaQuery. Native dashboard minimum 760x600. Popup 460x380; tests also cover legacy 440x330 and 125% text.
Popup content and long checklist scroll; footer remains usable. Shared helpers: presentation/components.dart; theme: app/app_theme.dart.
UI_SCREENSHOTS=1 writes widget renders to work/screenshots. These are not live Windows captures. Never ship Windows font files.
