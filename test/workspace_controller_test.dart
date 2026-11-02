import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:focustrack/application/workspace_controller.dart';
import 'package:focustrack/data/activity_store.dart';
import 'package:focustrack/domain/date_labels.dart';
import 'package:focustrack/platform/windows_desktop.dart';

class TestDesktop extends WindowsDesktop {
  @override
  void listen(Future<void> Function(DesktopEvent)? handler) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Failed activity write retains input and rolls back note and deadline',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'focustrack-failure-',
      );
      final store = FocusTrackStore(directory);
      await store.load();
      final deadline = store.nextPrompt;
      final controller = WorkspaceController(
        store,
        onMessage: (_) {},
        beforePrompt: () {},
        desktop: TestDesktop(),
      );
      try {
        // A directory at the temporary-file path deterministically rejects a write.
        await Directory('${store.path}.tmp').create();
        controller.promptNote.text = 'Preserve my note';
        await controller.logNote(fromPrompt: true);
        expect(controller.promptNote.text, 'Preserve my note');
        expect(controller.reviewingTasks, false);
        expect(controller.error, contains('Could not save'));
        expect(store.activitiesForDay(dayKey(DateTime.now())), isEmpty);
        expect(store.nextPrompt, deadline);
        expect(controller.busy, false);
        await Directory('${store.path}.tmp').delete();
        await controller.logNote(fromPrompt: true);
        expect(controller.promptNote.text, isEmpty);
        expect(controller.reviewingTasks, true);
        expect(
          store.activitiesForDay(dayKey(DateTime.now())).single.text,
          'Preserve my note',
        );
      } finally {
        controller.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
  test(
    'Typed task snapshots cannot mutate storage and commands persist',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'focustrack-tasks-',
      );
      final store = FocusTrackStore(directory);
      try {
        await store.load();
        await store.addTask('Review');
        final snapshot = store.tasks;
        expect(() => snapshot.clear(), throwsUnsupportedError);
        await store.setTaskDone(0, true);
        expect(snapshot.single.done, false);
        final loaded = FocusTrackStore(directory);
        await loaded.load();
        expect(loaded.tasks.single.done, true);
        await loaded.removeTask(0);
        expect(loaded.tasks, isEmpty);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
