import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:focustrack/main.dart';
import 'package:focustrack/store.dart';

void main() {
  testWidgets(
    'Dashboard logs work, persists checked tasks and shows daily JSON',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      final dir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('focustrack-ui-'),
      ))!;
      final store = FocusTrackStore(dir);
      store.data['startupInitialized'] = true;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        native,
        (call) async => call.method == 'startupEnabled' ? true : null,
      );
      await tester.pumpWidget(FocusTrackApp(store: store));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'Reviewed sprint scope',
      );
      await tester.runAsync(() => tester.tap(find.text('Log activity')));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      expect(
        store.entries(dayKey(DateTime.now())).single['text'],
        'Reviewed sprint scope',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'Follow up with engineers',
      );
      await tester.runAsync(() => tester.tap(find.byTooltip('Add task')));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() => tester.tap(find.byType(Checkbox)));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      expect(store.todos.single['done'], true);
      expect(
        tester
            .widget<Text>(find.text('Follow up with engineers'))
            .style
            ?.decoration,
        TextDecoration.lineThrough,
      );
      await tester.tap(find.text('Daily reports'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View raw JSON'));
      await tester.pumpAndSettle();
      expect(find.textContaining('"activities"'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => dir.delete(recursive: true));
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('Compact popup validates empty input and skips without logging', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    final dir = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('focustrack-prompt-'),
    ))!;
    final store = FocusTrackStore(dir);
    store.data['startupInitialized'] = true;
    final calls = <String>[];
    store.todos.add({'text': 'Follow up on blocker', 'done': false});
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(native, (
      call,
    ) async {
      calls.add(call.method);
      return call.method == 'startupEnabled' ? true : null;
    });
    await tester.pumpWidget(FocusTrackApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => tester.tap(find.text('30 mins')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(store.intervalMinutes, 30);
    await tester.enterText(find.byKey(const ValueKey('custom-interval')), '0');
    await tester.tap(find.text('Apply interval'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a value from 1 to 1440.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('custom-interval')), '17');
    await tester.runAsync(() => tester.tap(find.text('Apply interval')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(store.intervalMinutes, 17);
    await tester.tap(find.text('Preview prompt'));
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(440, 330));
    await tester.pumpAndSettle();
    expect(calls, contains('prompt'));
    expect(find.text('Kindly log the current work'), findsOneWidget);
    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();
    expect(
      find.text('Add a few words about your current work.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Skip'));
    await tester.runAsync(() => tester.tap(find.text('Skip')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpAndSettle();
    expect(store.days, isEmpty);
    expect(calls, contains('dismiss'));
    expect(calls, isNot(contains('open')));
    // A tray click is the only event that requests the full native dashboard.
    tester.binding.channelBuffers.push(
      'focustrack/windows',
      const StandardMethodCodec().encodeMethodCall(const MethodCall('open')),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(calls.last, 'open');
    tester.binding.channelBuffers.push(
      'focustrack/windows',
      const StandardMethodCodec().encodeMethodCall(const MethodCall('logNow')),
      (_) {},
    );
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(440, 330));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Resolved an engineering blocker',
    );
    await tester.runAsync(() => tester.tap(find.text('Log')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('Activity saved'), findsOneWidget);
    expect(calls.last, 'prompt');
    expect(
      store.entries(dayKey(DateTime.now())).single['text'],
      'Resolved an engineering blocker',
    );
    final nextPrompt = store.nextPrompt;
    expect(
      nextPrompt.difference(DateTime.now()).inMinutes,
      inInclusiveRange(16, 17),
    );
    await tester.runAsync(() => tester.tap(find.byType(Checkbox)));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(store.todos.single['done'], true);
    expect(
      tester.widget<Text>(find.text('Follow up on blocker')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Done'));
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpAndSettle();
    expect(store.nextPrompt, nextPrompt);
    expect(calls.last, 'dismiss');
    expect(calls.where((call) => call == 'open').length, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => dir.delete(recursive: true));
    await tester.binding.setSurfaceSize(null);
  });
}
