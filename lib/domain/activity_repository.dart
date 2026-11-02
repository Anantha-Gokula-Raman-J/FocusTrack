import 'activity_entry.dart';
import 'todo_item.dart';

/// Application-facing contract. Mutable JSON stays inside the data adapter.
abstract class ActivityRepository {
  List<ActivityEntry> activitiesForDay(String day);
  List<TodoItem> get tasks;
  Iterable<String> get activityDays;
  DateTime get nextPrompt;
  int get intervalMinutes;
  Duration get interval;
  bool get startupInitialized;
  String? get recoveryMessage;
  String get path;
  String get directoryPath;
  Future<void> markStartupInitialized();
  Future<void> log(String text, {DateTime? at, bool reschedule = false});
  Future<void> addTask(String text);
  Future<void> setTaskDone(int index, bool done);
  Future<void> removeTask(int index);
  Future<void> scheduleNext();
  Future<void> setInterval(int minutes);
  String dailyText(String day);
  String dailyBullets(String day);
  String dailyJson(String day);
}
