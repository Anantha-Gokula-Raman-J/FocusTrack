import 'dart:convert';
import 'dart:io';

import '../domain/date_labels.dart';
import '../domain/activity_entry.dart';
import '../domain/todo_item.dart';
import '../domain/activity_repository.dart';
import '../domain/report_formatter.dart';

class FocusTrackStore implements ActivityRepository {
  FocusTrackStore(this.directory);
  final Directory directory;
  Map<String, dynamic> data = {
    'version': 1,
    'days': <String, dynamic>{},
    'todos': <dynamic>[],
    'intervalMinutes': 60,
    'nextPrompt': DateTime.now()
        .add(const Duration(hours: 1))
        .toIso8601String(),
  };
  String? recoveryMessage;
  Future<void> _pending = Future.value();
  Map<String, dynamic> get days => data['days'] as Map<String, dynamic>;
  List<dynamic> get todos => data['todos'] as List<dynamic>;
  List<dynamic> entries(String day) => (days[day] as List<dynamic>?) ?? [];
  DateTime get nextPrompt => DateTime.parse(data['nextPrompt'] as String);
  int get intervalMinutes => data['intervalMinutes'] as int? ?? 60;
  Duration get interval => Duration(minutes: intervalMinutes);
  String get path =>
      '${directory.path}${Platform.pathSeparator}focustrack.json';
  String get json => const JsonEncoder.withIndent('  ').convert(data);

  final _reports = const ReportFormatter();
  String get directoryPath => directory.path;
  Iterable<String> get activityDays => days.keys;
  List<ActivityEntry> activitiesForDay(String day) => List.unmodifiable(
    entries(day)
        .map((e) => ActivityEntry.fromJson(Map<String, dynamic>.from(e))),
  );
  List<TodoItem> get tasks => List.unmodifiable(
    todos.map((e) => TodoItem.fromJson(Map<String, dynamic>.from(e))),
  );
  bool get startupInitialized => data['startupInitialized'] == true;
  Future<void> markStartupInitialized() =>
      change(() => data['startupInitialized'] = true);
  Future<void> addTask(String text) {
    if (text.trim().isEmpty) throw ArgumentError('Task cannot be empty');
    return change(
      () => todos.add(TodoItem(text: text.trim(), done: false).toJson()),
    );
  }

  Future<void> setTaskDone(int index, bool done) =>
      change(() => todos[index]['done'] = done);
  Future<void> removeTask(int index) => change(() => todos.removeAt(index));

  Future<void> load() async {
    await directory.create(recursive: true);
    final file = File(path);
    if (!await file.exists()) return;
    try {
      data = _decode(await file.readAsString());
    } catch (_) {
      // Preserve damaged input before recovering; never silently overwrite it.
      await file.copy('$path.damaged-${DateTime.now().millisecondsSinceEpoch}');
      final backup = File('$path.bak');
      if (await backup.exists()) {
        data = _decode(await backup.readAsString());
        recoveryMessage = 'Recovered your previous backup. The damaged file was preserved in the data folder.';
      } else {
        throw const FormatException(
          'The data file is damaged. It has been preserved in the data folder.',
        );
      }
    }
  }

  Map<String, dynamic> _decode(String source) {
    final value = jsonDecode(source) as Map<String, dynamic>;
    if (value['version'] != 1 ||
        value['days'] is! Map<String, dynamic> ||
        value['todos'] is! List) {
      throw const FormatException('Unsupported data format');
    }
    DateTime.parse(value['nextPrompt'] as String);
    final minutes = value['intervalMinutes'] ?? 60;
    if (minutes is! int || minutes < 1 || minutes > 1440) {
      throw const FormatException('Invalid check-in interval');
    }
    value['intervalMinutes'] = minutes;
    for (final entries in (value['days'] as Map).values) {
      for (final entry in entries as List) {
        if (entry['text'] is! String)
          throw const FormatException('Invalid entry');
        DateTime.parse(entry['at'] as String);
      }
    }
    for (final todo in value['todos'] as List) {
      if (todo['text'] is! String || todo['done'] is! bool)
        throw const FormatException('Invalid task');
    }
    return value;
  }

  Future<void> change(void Function() update) {
    final operation = _pending.then((_) async {
      final previous = jsonEncode(data);
      try {
        update();
        final temporary = File('$path.tmp');
        await temporary.writeAsString(json, flush: true);
        final file = File(path);
        if (await file.exists()) await file.copy('$path.bak');
        await temporary.rename(path);
      } catch (_) {
        data = jsonDecode(previous) as Map<String, dynamic>;
        rethrow;
      }
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }

  Future<void> log(String text, {DateTime? at, bool reschedule = false}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty)
      throw ArgumentError('Write a short note before logging.');
    final time = at ?? DateTime.now();
    return change(() {
      final list = days.putIfAbsent(dayKey(time), () => <dynamic>[]) as List;
      list.add(ActivityEntry(at: time, text: trimmed).toJson());
      if (reschedule) data['nextPrompt'] = time.add(interval).toIso8601String();
    });
  }

  Future<void> scheduleNext() => change(
    () => data['nextPrompt'] = DateTime.now().add(interval).toIso8601String(),
  );
  Future<void> setInterval(int minutes) {
    if (minutes < 1 || minutes > 1440) {
      throw ArgumentError('Enter whole minutes from 1 to 1440.');
    }
    return change(() {
      data['intervalMinutes'] = minutes;
      data['nextPrompt'] = DateTime.now().add(interval).toIso8601String();
    });
  }

  String dailyJson(String day) => _reports.json(day, activitiesForDay(day));
  String dailyBullets(String day) => _reports.bullets(activitiesForDay(day));
  String dailyText(String day) => _reports.text(day, activitiesForDay(day));
}
