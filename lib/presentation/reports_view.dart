import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';
import '../domain/date_labels.dart';
import 'components.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key, required this.model});
  final WorkspaceController model;
  @override
  Widget build(BuildContext context) => reports(context);
  Widget reports(BuildContext context) {
    final entries = model.store
        .activitiesForDay(model.selected)
        .where((e) => e.text.toLowerCase().contains(model.filter.toLowerCase()))
        .toList();
    final dates = model.store.activityDays.toList()
      ..sort((a, b) => b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(
          'THE FULL PICTURE',
          'Your work, in one place.',
          'Choose a day. Copy your progress. Close the loop.',
        ),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  datePicker(context, model),
                  FilledButton.icon(
                    onPressed:
                        model.store.activitiesForDay(model.selected).isEmpty
                        ? null
                        : () =>
                              model.copy(model.store.dailyText(model.selected)),
                    icon: const Icon(Icons.content_copy, size: 16),
                    label: const Text('Copy day’s work'),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        model.store.activitiesForDay(model.selected).isEmpty
                        ? null
                        : () => model.copy(
                            model.store.dailyBullets(model.selected),
                          ),
                    icon: const Icon(Icons.format_list_bulleted, size: 18),
                    label: const Text('Copy as bullet points'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        model.copy(model.store.dailyJson(model.selected)),
                    icon: const Icon(Icons.data_object, size: 17),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        model.desktop.openFolder(model.store.directoryPath),
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('Data folder'),
                  ),
                ],
              ),
              if (dates.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: dates
                      .take(14)
                      .map(
                        (day) => ChoiceChip(
                          label: Text(
                            dateLabel(day),
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: day == model.selected,
                          onSelected: (_) =>
                              model.update(() => model.selected = day),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 22),
              TextField(
                onChanged: (value) => model.update(() => model.filter = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search this day’s activities',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${dateLabel(model.selected)}  ·  ${model.store.activitiesForDay(model.selected).length} activities',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Divider(height: 30),
              if (entries.isEmpty)
                empty(
                  Icons.article_outlined,
                  'No activities to show',
                  'Choose another day or add a new activity.',
                ),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 65,
                        child: Text(
                          timeLabel(e.at.toIso8601String()),
                          style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          e.text,
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'View raw JSON',
                  style: TextStyle(fontSize: 13),
                ),
                leading: const Icon(Icons.data_object, size: 19),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    color: paper,
                    child: SelectableText(
                      model.store.dailyJson(model.selected),
                      style: const TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
