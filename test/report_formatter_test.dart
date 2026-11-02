import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:focustrack/domain/activity_entry.dart';
import 'package:focustrack/domain/report_formatter.dart';

void main() {
  const reports = ReportFormatter();
  final entries = [
    ActivityEntry(
      at: DateTime(2026, 11, 2, 9, 5),
      text: 'Review ✓\r\nNext step',
    ),
    ActivityEntry(at: DateTime(2026, 11, 2, 10, 30), text: 'Team sync'),
  ];
  test(
    'Bullet export preserves order, Unicode and indented multiline notes',
    () {
      expect(reports.bullets(entries), '• Review ✓\n  Next step\n• Team sync');
      expect(reports.bullets([]), '');
    },
  );
  test('Timestamped and JSON reports retain daily export contract', () {
    expect(
      reports.text('2026-11-02', entries),
      '2026-11-02\n09:05  Review ✓\r\nNext step\n10:30  Team sync',
    );
    final json = jsonDecode(reports.json('2026-11-02', entries));
    expect(json['date'], '2026-11-02');
    expect(json['activities'][0]['text'], entries.first.text);
    expect(json['activities'][1]['at'], '2026-11-02T10:30:00.000');
    expect(jsonDecode(reports.json('2026-11-03', []))['activities'], isEmpty);
  });
}
