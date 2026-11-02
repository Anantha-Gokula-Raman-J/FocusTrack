class ActivityEntry {
  const ActivityEntry({required this.at, required this.text});
  final DateTime at;
  final String text;
  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    at: DateTime.parse(json['at'] as String),
    text: json['text'] as String,
  );
  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'text': text};
}
