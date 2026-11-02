import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';

import 'components.dart';

class TaskReview extends StatelessWidget {
  const TaskReview({super.key, required this.model});
  final WorkspaceController model;
  @override
  Widget build(BuildContext context) => taskReviewView(context);
  Widget taskReviewView(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC9D9C3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: green, size: 21),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Activity saved',
                  style: TextStyle(color: green, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Close checklist',
                onPressed: model.busy ? null : model.dismiss,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          const Text(
            'Anything checked off?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          const Text(
            'Mark completed tasks. Changes save right away.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: model.store.tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks on your list yet.',
                      style: TextStyle(color: muted),
                    ),
                  )
                : ListView.builder(
                    itemCount: model.store.tasks.length,
                    itemBuilder: (context, index) {
                      final todo = model.store.tasks[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        value: todo.done,
                        onChanged: model.busy
                            ? null
                            : (value) =>
                                  model.setTaskDone(index, value ?? false),
                        title: Text(
                          todo.text,
                          style: TextStyle(
                            color: todo.done ? muted : ink,
                            decoration: todo.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (model.error != null)
            Flexible(child: SingleChildScrollView(child: errorView(model))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${model.store.tasks.where((t) => !t.done).length} tasks remaining',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              FilledButton(
                onPressed: model.busy ? null : model.dismiss,
                child: Text(model.busy ? 'Saving...' : 'Done'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
