class TodoItem {
  const TodoItem({required this.text, required this.done});
  final String text;
  final bool done;
  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      TodoItem(text: json['text'] as String, done: json['done'] as bool);
  Map<String, dynamic> toJson() => {'text': text, 'done': done};
}
