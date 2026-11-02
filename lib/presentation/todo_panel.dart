import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';

import 'components.dart';

class TodoPanel extends StatelessWidget {
  const TodoPanel({super.key, required this.model});
  final WorkspaceController model;
  @override
  Widget build(BuildContext context) => todoPanel(context);
  Widget todoPanel(BuildContext context) => panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('On your list', Icons.checklist_rounded),
        const SizedBox(height: 7),
        const Text(
          'No deadlines. Just a little direction.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: model.task,
          maxLength: 300,
          onSubmitted: (_) => model.addTask(),
          decoration: InputDecoration(
            hintText: 'Add a task...',
            counterText: '',
            suffixIcon: IconButton(
              tooltip: 'Add task',
              onPressed: model.busy ? null : model.addTask,
              icon: const Icon(Icons.add_circle_outline, color: green),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (model.store.tasks.isEmpty)
          empty(
            Icons.task_alt,
            'Room for your next step',
            'Add the things you want to keep in sight.',
          ),
        ...model.store.tasks.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  height: 35,
                  child: Checkbox(
                    value: entry.value.done,
                    onChanged: model.busy
                        ? null
                        : (value) =>
                              model.setTaskDone(entry.key, value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      entry.value.text,
                      style: TextStyle(
                        height: 1.5,
                        color: entry.value.done ? muted : ink,
                        fontSize: 13,
                        decoration: entry.value.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove task',
                  iconSize: 16,
                  color: muted,
                  onPressed: model.busy
                      ? null
                      : () => deleteTask(context, entry.key),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ),
        if (model.store.tasks.isNotEmpty) ...[
          const Divider(height: 30),
          Text(
            '${model.store.tasks.where((e) => e.done == false).length} tasks remaining',
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ],
    ),
  );

  Future<void> deleteTask(BuildContext context, int index) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this task?'),
        content: Text(model.store.tasks[index].text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (approved == true) await model.removeTask(index);
  }
}
