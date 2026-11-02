import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/activity_repository.dart';
import '../domain/date_labels.dart';
import '../platform/windows_desktop.dart';

/// Owns workflow state and input controllers; never owns a BuildContext.
class WorkspaceController extends ChangeNotifier {
  WorkspaceController(
    this.store, {
    required this.onMessage,
    required this.beforePrompt,
    this.desktop = const WindowsDesktop(),
  });
  final void Function(String) onMessage;
  final VoidCallback beforePrompt;
  final WindowsDesktop desktop;
  bool _disposed = false;
  bool get mounted => !_disposed;
  void update(VoidCallback change) {
    if (_disposed) return;
    change();
    notifyListeners();
  }

  String get countdown {
    final minutes = store.nextPrompt.difference(DateTime.now()).inMinutes;
    return minutes < 1 ? 'Due now' : 'In ${minutes + 1} min';
  }

  final ActivityRepository store;
  final note = TextEditingController();
  final promptNote = TextEditingController();
  final task = TextEditingController();
  final customInterval = TextEditingController();
  Timer? timer;
  bool prompt = false, busy = false, startup = false;
  bool reviewingTasks = false;
  String? intervalError;
  String? error;
  String selected = dayKey(DateTime.now());
  int page = 0;
  String filter = '';
  DateTime lastDay = DateTime.now();

  void initialize() {
    customInterval.text = store.intervalMinutes.toString();
    desktop.listen((event) async {
      if (event == DesktopEvent.skip) await dismiss();
      if (event == DesktopEvent.logNow) await showPrompt();
      if (event == DesktopEvent.open) {
        if (prompt) await dismiss();
        if (prompt || busy || !mounted) return;
        update(() => page = 0);
        await WidgetsBinding.instance.endOfFrame;
        await desktop.openDashboard();
      }
      if (event == DesktopEvent.quit && !busy) await desktop.quit();
    });
    initializeStartup();
    timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) return;
      if (dayKey(lastDay) != dayKey(DateTime.now())) {
        if (selected == dayKey(lastDay)) selected = dayKey(DateTime.now());
        lastDay = DateTime.now();
      }
      update(() {});
      if (!prompt && !busy && !DateTime.now().isBefore(store.nextPrompt))
        await showPrompt();
    });
    if (store.recoveryMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => message(store.recoveryMessage!),
      );
    }
  }

  Future<void> initializeStartup() async {
    try {
      var enabled = await desktop.startupEnabled();
      if (enabled) await desktop.setStartup(true);
      if (!store.startupInitialized) {
        await desktop.setStartup(true);
        enabled = true;
        await store.markStartupInitialized();
      }
      if (mounted) update(() => startup = enabled);
    } catch (e) {
      if (mounted) message('Startup could not be enabled: $e');
    }
  }

  void dispose() {
    customInterval.dispose();
    timer?.cancel();
    note.dispose();
    promptNote.dispose();
    task.dispose();
    desktop.listen(null);
    _disposed = true;
    super.dispose();
  }

  void message(String text) {
    if (mounted) onMessage(text);
  }

  Future<bool> save(Future<void> Function() operation) async {
    if (busy) return false;
    update(() {
      busy = true;
      error = null;
    });
    try {
      await operation();
      if (mounted) update(() {});
      return true;
    } catch (e) {
      if (mounted)
        update(() => error = 'Could not save. Your input is still here. $e');
      return false;
    } finally {
      if (mounted) update(() => busy = false);
    }
  }

  Future<void> showPrompt() async {
    if (prompt || busy) return;
    beforePrompt();
    update(() {
      prompt = true;
      reviewingTasks = false;
      error = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    await desktop.showPrompt();
  }

  Future<void> dismiss() async {
    if (busy) return;
    if (!reviewingTasks && !await save(store.scheduleNext)) return;
    promptNote.clear();
    await desktop.dismiss();
    if (mounted)
      update(() {
        prompt = false;
        reviewingTasks = false;
      });
  }

  Future<void> logNote({bool fromPrompt = false}) async {
    final controller = fromPrompt ? promptNote : note;
    if (controller.text.trim().isEmpty) {
      update(() => error = 'Add a few words about your current work.');
      return;
    }
    final at = DateTime.now();
    final text = controller.text.trim();
    final success = await save(
      () => store.log(text, at: at, reschedule: fromPrompt),
    );
    if (!success) return;
    controller.clear();
    update(() {
      selected = dayKey(at);
      if (fromPrompt) reviewingTasks = true;
    });
    if (mounted && !fromPrompt) message('Activity saved to your day.');
  }

  Future<void> addTask() async {
    if (task.text.trim().isEmpty) return;
    final text = task.text.trim();
    if (await save(() => store.addTask(text))) task.clear();
  }

  Future<void> setTaskDone(int index, bool done) async {
    await save(() => store.setTaskDone(index, done));
  }

  Future<void> removeTask(int index) async {
    await save(() => store.removeTask(index));
  }

  Future<void> setStartup(bool value) async {
    if (await save(() => desktop.setStartup(value))) {
      update(() => startup = value);
    }
  }

  void applyCustomInterval() {
    final minutes = int.tryParse(customInterval.text);
    if (minutes == null || minutes < 1 || minutes > 1440) {
      update(() => intervalError = 'Enter a value from 1 to 1440.');
      return;
    }
    updateInterval(minutes);
  }

  Future<void> copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) message('Copied to clipboard.');
  }

  Future<void> updateInterval(int minutes) async {
    if (await save(() => store.setInterval(minutes))) {
      customInterval.text = minutes.toString();
      update(() => intervalError = null);
      message('Check-ins updated. The next one is in $minutes minutes.');
    }
  }
}
