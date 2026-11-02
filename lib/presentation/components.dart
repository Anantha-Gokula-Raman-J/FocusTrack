import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';
import '../domain/date_labels.dart';

Widget title(
  String eyebrow,
  String heading,
  String subtitle, {
  Widget? action,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 28),
  child: LayoutBuilder(
    builder: (context, constraints) {
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 9),
          Text(heading, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.6),
          ),
        ],
      );
      if (action == null) return copy;
      if (constraints.maxWidth < 760)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [copy, const SizedBox(height: 16), action],
        );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: copy),
          const SizedBox(width: 24),
          action,
        ],
      );
    },
  ),
);

Widget panel(Widget child, {Color color = Colors.white}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: color,
    border: Border.all(color: const Color(0xFFE4E8E0)),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Material(color: Colors.transparent, child: child),
);

Widget sectionTitle(String text, IconData icon) => Row(
  children: [
    Icon(icon, size: 19, color: green),
    const SizedBox(width: 9),
    Expanded(
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  ],
);

Widget errorView(WorkspaceController model) => model.error == null
    ? const SizedBox.shrink()
    : Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          model.error!,
          style: const TextStyle(color: Color(0xFFAB3C30), fontSize: 12),
        ),
      );

Widget datePicker(BuildContext context, WorkspaceController model) =>
    OutlinedButton.icon(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(model.selected),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) model.update(() => model.selected = dayKey(date));
      },
      icon: const Icon(Icons.calendar_today_outlined, size: 14),
      label: Text(
        model.selected == dayKey(DateTime.now())
            ? 'Today'
            : dateLabel(model.selected),
      ),
    );

Widget empty(IconData icon, String text, String detail) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 24),
  child: Center(
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFF9BAB91), size: 32),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  ),
);
