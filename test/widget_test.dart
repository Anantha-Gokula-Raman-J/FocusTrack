import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:focustrack/store.dart';

void main() {
  late Directory directory;
  late FocusTrackStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('focustrack-test-');
    store = FocusTrackStore(directory);
    await store.load();
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  test(
    'Groups local dates across midnight and preserves multiline Unicode',
    () async {
      await store.log(
        'Review engineer work\nPlan next sprint ✓',
        at: DateTime(2026, 11, 1, 23, 59),
      );
      await store.log('Morning sync', at: DateTime(2026, 11, 2, 0, 1));
      final reloaded = FocusTrackStore(directory);
      await reloaded.load();
      expect(reloaded.entries('2026-11-01').single['text'], contains('✓'));
      expect(reloaded.entries('2026-11-02').length, 1);
      expect(reloaded.dailyText('2026-11-01'), contains('23:59'));
    },
  );
  test('Skip advances next prompt without creating an activity', () async {
    await store.scheduleNext();
    expect(store.days, isEmpty);
    expect(
      store.nextPrompt.difference(DateTime.now()).inMinutes,
      inInclusiveRange(59, 60),
    );
  });
  test('Task completion survives restart', () async {
    await store.change(
      () => store.todos.add({'text': 'Review PR', 'done': false}),
    );
    await store.change(() => store.todos[0]['done'] = true);
    final reloaded = FocusTrackStore(directory);
    await reloaded.load();
    expect(reloaded.todos.single['done'], true);
  });
  test('Concurrent requests are serialized without losing entries', () async {
    await Future.wait(
      List.generate(20, (i) => store.log('Task $i', at: DateTime(2026, 11, 1))),
    );
    final reloaded = FocusTrackStore(directory);
    await reloaded.load();
    expect(reloaded.entries('2026-11-01').length, 20);
  });
  test('Damaged JSON restores backup and preserves damaged original', () async {
    await store.log('First');
    await store.log('Second');
    await File(store.path).writeAsString('broken');
    final reloaded = FocusTrackStore(directory);
    await reloaded.load();
    expect(reloaded.entries(dayKey(DateTime.now())).length, 1);
    expect(reloaded.recoveryMessage, isNotNull);
    expect(
      directory.listSync().any((file) => file.path.contains('.damaged-')),
      true,
    );
  });
  test('Empty notes rejected', () {
    expect(() => store.log('  '), throwsArgumentError);
  });
  test('FocusTrack migration preserves original notes and never overwrites new data', () async {
    final legacy = Directory(
      '${directory.path}${Platform.pathSeparator}Daymark',
    );
    await legacy.create();
    final original = File(
      '${legacy.path}${Platform.pathSeparator}daymark.json',
    );
    await original.writeAsString(store.json);
    await File('${original.path}.bak').writeAsString(store.json);
    await migrateLegacyData(directory);
    final current = FocusTrackStore(
      Directory('${directory.path}${Platform.pathSeparator}FocusTrack'),
    );
    await current.load();
    await current.log('New FocusTrack note');
    await migrateLegacyData(directory);
    final reloaded = FocusTrackStore(current.directory);
    await reloaded.load();
    expect(
      reloaded.entries(dayKey(DateTime.now())).single['text'],
      'New FocusTrack note',
    );
    expect(await original.readAsString(), store.json);
    expect(await File('${current.path}.bak').exists(), true);
  });
  test('Intervals persist, reschedule and support older data', () async {
    expect(store.intervalMinutes, 60);
    for (final minutes in [10, 30, 45, 60, 17]) {
      await store.setInterval(minutes);
      await store.scheduleNext();
      expect(
        store.nextPrompt.difference(DateTime.now()).inSeconds,
        inInclusiveRange(minutes * 60 - 2, minutes * 60),
      );
      final reloaded = FocusTrackStore(directory);
      await reloaded.load();
      expect(reloaded.intervalMinutes, minutes);
    }
    await store.change(() => store.data.remove('intervalMinutes'));
    final legacy = FocusTrackStore(directory);
    await legacy.load();
    expect(legacy.intervalMinutes, 60);
    expect(() => store.setInterval(0), throwsArgumentError);
    expect(() => store.setInterval(1441), throwsArgumentError);
  });
}
