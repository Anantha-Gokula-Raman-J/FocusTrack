#include "legacy_compatibility.h"
#include "flutter_window.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>
#include <optional>
#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {
constexpr UINT kTrayMessage = WM_APP + 1;
constexpr wchar_t kRunKey[] = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;
NOTIFYICONDATA nid = {};
WINDOWPLACEMENT previous = {sizeof(WINDOWPLACEMENT)};
bool prompting = false;
void Emit(const char* event) {
  if (channel) channel->InvokeMethod(event, nullptr);
}
void HideDashboard(HWND hwnd) {
  if (!prompting) GetWindowPlacement(hwnd, &previous);
  ShowWindow(hwnd, SW_HIDE);
}
void RestoreDashboardHidden(HWND hwnd) {
  ShowWindow(hwnd, SW_HIDE);
  prompting = false;
  SetWindowLongPtr(hwnd, GWL_STYLE, WS_OVERLAPPEDWINDOW);
  SetWindowLongPtr(hwnd, GWL_EXSTYLE,
      (GetWindowLongPtr(hwnd, GWL_EXSTYLE) & ~WS_EX_TOOLWINDOW) | WS_EX_APPWINDOW);
  SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_NOACTIVATE);
  WINDOWPLACEMENT hidden = previous;
  hidden.showCmd = SW_HIDE;
  SetWindowPlacement(hwnd, &hidden);
}
void MainWindow(HWND hwnd) {
  if (prompting) RestoreDashboardHidden(hwnd);
  ShowWindow(hwnd, previous.showCmd == SW_SHOWMAXIMIZED ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL);
  SetForegroundWindow(hwnd);
}
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project) : project_(project) {}
FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) return false;
  RECT frame = GetClientArea();
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(frame.right-frame.left, frame.bottom-frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) return false;
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  HWND hwnd = GetHandle();
  GetWindowPlacement(hwnd, &previous);
  nid.cbSize = sizeof(nid);
  nid.hWnd = hwnd;
  nid.uID = 1;
  nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  nid.uCallbackMessage = kTrayMessage;
  nid.hIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  wcscpy_s(nid.szTip, L"FocusTrack - your day, remembered");
  Shell_NotifyIcon(NIM_ADD, &nid);
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(flutter_controller_->engine()->messenger(), "focustrack/windows", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([hwnd](const auto& call, auto result) {
    const auto& method = call.method_name();
    if (method == "prompt") {
      if (!prompting) {
        GetWindowPlacement(hwnd, &previous);
        ShowWindow(hwnd, SW_HIDE);
        prompting = true;
        MONITORINFO monitor = {sizeof(MONITORINFO)};
        GetMonitorInfo(MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST), &monitor);
        const int width = MulDiv(460, GetDpiForWindow(hwnd), 96);
        const int height = MulDiv(380, GetDpiForWindow(hwnd), 96);
        SetWindowLongPtr(hwnd, GWL_STYLE, WS_POPUP);
        SetWindowLongPtr(hwnd, GWL_EXSTYLE,
            (GetWindowLongPtr(hwnd, GWL_EXSTYLE) & ~WS_EX_APPWINDOW) | WS_EX_TOOLWINDOW);
        SetWindowPos(hwnd, HWND_TOPMOST, monitor.rcWork.right-width-16, monitor.rcWork.bottom-height-16, width, height, SWP_FRAMECHANGED | SWP_SHOWWINDOW | SWP_NOACTIVATE);
      }
    } else if (method == "dismiss") {
      RestoreDashboardHidden(hwnd);
    } else if (method == "open") {
      MainWindow(hwnd);
    } else if (method == "quit") {
      DestroyWindow(hwnd);
    } else if (method == "startupEnabled") {
      HKEY key;
      bool enabled = false;
      if (RegOpenKeyEx(HKEY_CURRENT_USER, kRunKey, 0, KEY_READ, &key) == ERROR_SUCCESS) {
        enabled = RegQueryValueEx(key, L"FocusTrack", nullptr, nullptr, nullptr, nullptr) == ERROR_SUCCESS || RegQueryValueEx(key, legacy_compatibility::kStartupValue, nullptr, nullptr, nullptr, nullptr) == ERROR_SUCCESS;
        RegCloseKey(key);
      }
      result->Success(flutter::EncodableValue(enabled));
      return;
    } else if (method == "startup") {
      const bool enabled = call.arguments() && std::get<bool>(*call.arguments());
      HKEY key;
      LONG status = RegCreateKeyEx(HKEY_CURRENT_USER, kRunKey, 0, nullptr, 0, KEY_SET_VALUE, nullptr, &key, nullptr);
      if (status == ERROR_SUCCESS) {
        if (enabled) {
          wchar_t exe[32768];
          GetModuleFileName(nullptr, exe, 32768);
          const std::wstring command = L"\"" + std::wstring(exe) + L"\" --startup";
          status = RegSetValueEx(key, L"FocusTrack", 0, REG_SZ, reinterpret_cast<const BYTE*>(command.c_str()), static_cast<DWORD>((command.size()+1)*sizeof(wchar_t)));
        } else {
          status = RegDeleteValue(key, L"FocusTrack");
          if (status == ERROR_FILE_NOT_FOUND) status = ERROR_SUCCESS;
        }
        if (status == ERROR_SUCCESS) RegDeleteValue(key, legacy_compatibility::kStartupValue);
        RegCloseKey(key);
      }
      if (status != ERROR_SUCCESS) { result->Error("startup", "Windows could not update the startup setting."); return; }
    } else if (method == "folder") {
      const auto path = std::get<std::string>(*call.arguments());
      const int length = MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, nullptr, 0);
      std::wstring wide(length, L'\0');
      MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, wide.data(), length);
      ShellExecute(hwnd, L"open", wide.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
    } else { result->NotImplemented(); return; }
    result->Success();
  });
  // Launch silently. Only an explicit tray action opens the dashboard.
  flutter_controller_->ForceRedraw();
  return true;
}
void FlutterWindow::OnDestroy() {
  Shell_NotifyIcon(NIM_DELETE, &nid);
  channel.reset();
  flutter_controller_ = nullptr;
  Win32Window::OnDestroy();
}
LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) noexcept {
  static UINT taskbarCreated = RegisterWindowMessage(L"TaskbarCreated");
  if (message == taskbarCreated) { Shell_NotifyIcon(NIM_ADD, &nid); return 0; }
  if (message == WM_GETMINMAXINFO && !prompting) {
    auto* limits = reinterpret_cast<MINMAXINFO*>(lparam);
    limits->ptMinTrackSize.x = MulDiv(760, GetDpiForWindow(hwnd), 96);
    limits->ptMinTrackSize.y = MulDiv(600, GetDpiForWindow(hwnd), 96);
    return 0;
  }
  if (message == WM_CLOSE) {
    if (prompting) Emit("skip"); else HideDashboard(hwnd);
    return 0;
  }
  if (message == WM_SYSCOMMAND && (wparam & 0xFFF0) == SC_MINIMIZE) {
    if (prompting) Emit("skip"); else HideDashboard(hwnd);
    return 0;
  }
  if (message == kTrayMessage) {
    if (lparam == WM_LBUTTONUP) { Emit("open"); }
    if (lparam == WM_RBUTTONUP) {
      HMENU menu = CreatePopupMenu();
      AppendMenu(menu, MF_STRING, 1, L"Open FocusTrack");
      AppendMenu(menu, MF_STRING, 2, L"Log now");
      AppendMenu(menu, MF_SEPARATOR, 0, nullptr);
      AppendMenu(menu, MF_STRING, 3, L"Quit FocusTrack");
      POINT point; GetCursorPos(&point); SetForegroundWindow(hwnd);
      const UINT selected = TrackPopupMenu(menu, TPM_RETURNCMD | TPM_NONOTIFY, point.x, point.y, 0, hwnd, nullptr);
      DestroyMenu(menu);
      PostMessage(hwnd, WM_NULL, 0, 0);
      if (selected == 1) { Emit("open"); }
      if (selected == 2) Emit("logNow");
      if (selected == 3) Emit("quit");
    }
    return 0;
  }
  if (flutter_controller_) {
    auto result = flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
    if (result) return *result;
  }
  if (message == WM_FONTCHANGE && flutter_controller_) flutter_controller_->engine()->ReloadSystemFonts();
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
