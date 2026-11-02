import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';
import '../domain/date_labels.dart';
import 'components.dart';
import 'todo_panel.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key, required this.model, required this.narrow});
  final WorkspaceController model;
  final bool narrow;
  @override
  Widget build(BuildContext context) => dashboard(context);
  Widget dashboard(BuildContext context) {
    final today = dayKey(DateTime.now());
    final count = model.store.activitiesForDay(today).length;
    final done = model.store.tasks.where((t) => t.done == true).length;
    final timeline = Column(
      children: [
        composer(context),
        const SizedBox(height: 20),
        activityList(context),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(
          'MAKE SPACE FOR WHAT MATTERS',
          'Your day, remembered.',
          'A little reflection now. A complete picture later.',
          action: OutlinedButton.icon(
            onPressed: () => model.update(() {
              model.page = 1;
              model.selected = today;
            }),
            icon: const Icon(Icons.copy_all_outlined, size: 17),
            label: const Text('Review your day'),
          ),
        ),
        LayoutBuilder(
          builder: (context, c) => Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              stat(
                context,
                'ACTIVITIES TODAY',
                '$count',
                'Moments captured',
                Icons.notes_rounded,
                c.maxWidth,
              ),
              stat(
                context,
                'TASKS COMPLETED',
                '$done / ${model.store.tasks.length}',
                'One thing at a time',
                Icons.check_circle_outline,
                c.maxWidth,
              ),
              stat(
                context,
                'NEXT CHECK-IN',
                model.countdown,
                'A gentle nudge every ${model.store.intervalMinutes} min',
                Icons.schedule_rounded,
                c.maxWidth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        if (narrow) ...[
          timeline,
          const SizedBox(height: 20),
          TodoPanel(model: model),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: timeline),
              const SizedBox(width: 22),
              Expanded(flex: 5, child: TodoPanel(model: model)),
            ],
          ),
        const SizedBox(height: 24),
        const Text(
          'Made for busy minds. Saved only on this computer.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }

  Widget stat(
    BuildContext context,
    String label,
    String value,
    String caption,
    IconData icon,
    double width,
  ) => SizedBox(
    width: width < 540 ? width : (width - 28) / 3,
    child: panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: green, size: 18),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
          Text(caption, style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    ),
  );

  Widget composer(BuildContext context) => panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('What are you working on?', Icons.edit_note_rounded),
        const SizedBox(height: 6),
        const Text(
          'Capture a decision, a conversation, or a small win.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: model.note,
          minLines: 3,
          maxLines: 6,
          maxLength: 4000,
          decoration: const InputDecoration(
            hintText: 'Kindly log the current work',
            hintStyle: TextStyle(color: muted, fontSize: 13),
          ),
        ),
        errorView(model),
        Row(
          children: [
            const Icon(Icons.save_outlined, color: muted, size: 14),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Saved locally as JSON',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
            FilledButton.icon(
              onPressed: model.busy ? null : () => model.logNote(),
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Log activity'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget activityList(BuildContext context) {
    final entries = model.store
        .activitiesForDay(model.selected)
        .reversed
        .toList();
    return panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 18,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Activity journal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              datePicker(context, model),
            ],
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            empty(
              Icons.auto_awesome_outlined,
              'A fresh page for your day',
              'Log your first activity. Every small step counts.',
            )
          else
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 19),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 13),
                    SizedBox(
                      width: 45,
                      child: Text(
                        timeLabel(e.at.toIso8601String()),
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SelectableText(
                        e.text,
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
