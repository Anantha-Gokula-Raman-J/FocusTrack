import 'dart:convert';

import 'activity_entry.dart';
import 'date_labels.dart';

class ReportFormatter {
  const ReportFormatter();
  String json(String day, List<ActivityEntry> entries) =>
      const JsonEncoder.withIndent('  ').convert({
        'date': day,
        'activities': entries.map((e) => e.toJson()).toList(),
      });
  String bullets(List<ActivityEntry> entries) => entries
      .map((e) => '• ${e.text.replaceAll(RegExp(r'\r?\n'), '\n  ')}')
      .join('\n');
  String text(String day, List<ActivityEntry> entries) =>
      '$day\n${entries.map((e) => '${timeLabel(e.at.toIso8601String())}  ${e.text}').join('\n')}';
}
