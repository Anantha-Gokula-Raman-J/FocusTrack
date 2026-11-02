#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include "legacy_compatibility.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  HANDLE singleton = CreateMutex(nullptr, TRUE, L"Local\\FocusTrackActivityTracker");
  const bool current_exists = GetLastError() == ERROR_ALREADY_EXISTS;
  // Hold the legacy gate too, preventing older installations running concurrently.
  HANDLE legacy_singleton = CreateMutex(nullptr, TRUE, legacy_compatibility::kMutex);
  const bool legacy_exists = GetLastError() == ERROR_ALREADY_EXISTS;
  if (current_exists || legacy_exists) {
    // Startup remains silent. A manual second launch explains how to upgrade
    // instead of appearing to launch an older instance without feedback.
    if (!wcsstr(command_line, L"--startup")) {
      MessageBox(nullptr,
          L"FocusTrack or an older version is already running.\n\n"
          L"Open it from the tray icon. To load an update, choose Quit from that "
          L"icon's menu, then launch FocusTrack again.",
          L"FocusTrack is already running", MB_OK | MB_ICONINFORMATION);
    }
    if (singleton) CloseHandle(singleton);
    if (legacy_singleton) CloseHandle(legacy_singleton);
    return 0;
  }
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"FocusTrack", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (singleton) CloseHandle(singleton);
  if (legacy_singleton) CloseHandle(legacy_singleton);
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
