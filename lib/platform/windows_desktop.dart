import 'package:flutter/services.dart';

const native = MethodChannel('focustrack/windows');

enum DesktopEvent { skip, logNow, open, quit }

/// Typed boundary for the existing Windows runner protocol.
class WindowsDesktop {
  const WindowsDesktop();
  Future<void> openFolder(String path) => native.invokeMethod('folder', path);
  Future<void> openDashboard() => native.invokeMethod('open');
  Future<void> showPrompt() => native.invokeMethod('prompt');
  Future<void> dismiss() => native.invokeMethod('dismiss');
  Future<void> quit() => native.invokeMethod('quit');
  Future<bool> startupEnabled() async =>
      await native.invokeMethod<bool>('startupEnabled') ?? false;
  Future<void> setStartup(bool enabled) =>
      native.invokeMethod('startup', enabled);
  void listen(Future<void> Function(DesktopEvent)? handler) {
    native.setMethodCallHandler(
      handler == null
          ? null
          : (call) async {
              for (final event in DesktopEvent.values) {
                if (event.name == call.method) {
                  await handler(event);
                  return;
                }
              }
            },
    );
  }
}
