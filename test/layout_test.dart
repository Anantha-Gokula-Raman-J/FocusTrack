import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focustrack/main.dart';
import 'package:focustrack/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final configFile = File('.dart_tool/package_config.json');
    final config = jsonDecode(await configFile.readAsString());
    final flutter = (config['packages'] as List).firstWhere(
      (p) => p['name'] == 'flutter',
    );
    final flutterPackage = Directory.fromUri(
      configFile.absolute.uri.resolve(flutter['rootUri'] as String),
    );
    final sdk = flutterPackage.uri.resolve('../../');
    final icons = File.fromUri(
      sdk.resolve(
        'bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ),
    );
    if (!await icons.exists() &&
        Platform.environment['UI_SCREENSHOTS'] == '1') {
      throw StateError('Material icon font is required for screenshots.');
    }
    if (await icons.exists()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          icons.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      await loader.load();
    }
    final font = File(r'C:\Windows\Fonts\segoeui.ttf');
    if (await font.exists()) {
      final loader = FontLoader('Segoe UI')
        ..addFont(
          font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      await loader.load();
    }
  });
  testWidgets('Responsive pages and popup remain aligned with larger text', (
    tester,
  ) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('focustrack-layout-'),
    ))!;
    final store = FocusTrackStore(directory);
    store.data['startupInitialized'] = true;
    store.todos.addAll([
      {'text': 'Review the next sprint plan with the team', 'done': false},
      {'text': 'Follow up on engineering blockers', 'done': true},
    ]);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      native,
      (call) async => call.method == 'startupEnabled' ? true : null,
    );
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: FocusTrackApp(store: store),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      if (Platform.environment['UI_SCREENSHOTS'] != '1') return;
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('work/screenshots').create(recursive: true);
        await File('work/screenshots/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.runAsync(() async {
      final now = DateTime.now();
      await store.log(
        'Planned priorities and reviewed the team backlog.',
        at: DateTime(now.year, now.month, now.day, 9),
      );
      await store.log(
        'Resolved a blocker and reviewed implementation options.',
        at: DateTime(now.year, now.month, now.day, 10),
      );
      await store.log(
        'Documented decisions and followed up on action items.',
        at: DateTime(now.year, now.month, now.day, 11),
      );
    });
    await tester.tap(find.text('Daily reports'));
    await tester.pumpAndSettle();
    await capture('reports');
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    await capture('overview');
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    await capture('preferences');
    for (final size in [const Size(800, 700), const Size(760, 600)]) {
      await tester.binding.setSurfaceSize(size);
      tester.platformDispatcher.textScaleFactorTestValue = 1.25;
      await tester.pumpAndSettle();
      await capture('preferences-narrow');
      await tester.tap(find.byTooltip('Overview'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Daily reports'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview prompt'));
    await tester.tap(find.text('Preview prompt'));
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(460, 380));
    tester.platformDispatcher.textScaleFactorTestValue = 1.25;
    await tester.pumpAndSettle();
    await capture('activity-popup');
    await tester.enterText(
      find.byType(TextField),
      'Reviewed priorities with the engineering team.',
    );
    await tester.runAsync(() => tester.tap(find.text('Log')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    await capture('checklist-popup');
    await tester.pumpWidget(const SizedBox());
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.binding.setSurfaceSize(null);
    await tester.runAsync(() => directory.delete(recursive: true));
  });
}
