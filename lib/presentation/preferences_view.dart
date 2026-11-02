import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';
import '../domain/date_labels.dart';
import 'components.dart';

import 'package:flutter/services.dart';

class PreferencesView extends StatelessWidget {
  const PreferencesView({super.key, required this.model});
  final WorkspaceController model;
  @override
  Widget build(BuildContext context) => settings(context);
  Widget preferenceHeader(
    BuildContext context,
    IconData icon,
    String heading,
    String description, {
    Widget? action,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final text = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: green, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      if (action == null) return text;
      if (constraints.maxWidth < 600)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [text, const SizedBox(height: 16), action],
        );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: text),
          const SizedBox(width: 20),
          action,
        ],
      );
    },
  );

  Widget settings(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title(
        'MAKE IT YOURS',
        'Quietly in your corner.',
        'Set your rhythm. Keep the rest simple.',
      ),
      panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preferenceHeader(
              context,
              Icons.schedule_rounded,
              'Check-in rhythm',
              'Currently every ${model.store.intervalMinutes} minutes. Next check-in at ${timeLabel(model.store.nextPrompt.toIso8601String())}.',
              action: OutlinedButton.icon(
                onPressed: model.busy ? null : model.showPrompt,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview prompt'),
              ),
            ),
            const Divider(height: 36),
            intervalSettings(context),
          ],
        ),
      ),
      const SizedBox(height: 20),
      panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preferenceHeader(
              context,
              Icons.power_settings_new_rounded,
              'Start with Windows',
              'Run quietly in the tray when you sign in.',
              action: Semantics(
                label: 'Start with Windows',
                child: Switch(
                  value: model.startup,
                  onChanged: model.busy ? null : model.setStartup,
                ),
              ),
            ),
            const Divider(height: 36),
            preferenceHeader(
              context,
              Icons.desktop_windows_outlined,
              'Always within reach',
              'Closing FocusTrack hides it in the tray. Your scheduled popup still appears. Select the tray icon to open the dashboard; use its menu to quit.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preferenceHeader(
              context,
              Icons.folder_outlined,
              'Your local data',
              'Activity notes and tasks stay on this computer. A previous-save backup is kept with your JSON file.',
              action: OutlinedButton.icon(
                onPressed: () =>
                    model.desktop.openFolder(model.store.directoryPath),
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Open data folder'),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: paper,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                model.store.path,
                style: const TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 12,
                  color: muted,
                  height: 1.6,
                ),
              ),
            ),
            errorView(model),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'FocusTrack 1.2.2  •  Windows  •  Offline',
        style: TextStyle(color: muted, fontSize: 12),
      ),
    ],
  );

  Widget intervalSettings(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'CHECK-IN INTERVAL',
        style: TextStyle(
          color: muted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.3,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final minutes in [10, 30, 45, 60])
            ChoiceChip(
              label: Text(minutes == 60 ? '1 hour (default)' : '$minutes mins'),
              selected: model.store.intervalMinutes == minutes,
              onSelected: model.busy
                  ? null
                  : (_) => model.updateInterval(minutes),
            ),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'Custom interval (minutes)',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, constraints) {
          final field = SizedBox(
            width: constraints.maxWidth < 410 ? constraints.maxWidth : 240,
            height: 48,
            child: TextField(
              key: const ValueKey('custom-interval'),
              controller: model.customInterval,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'e.g. 20',
                suffixText: 'min',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          );
          final apply = SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: model.busy ? null : model.applyCustomInterval,
              child: const Text('Apply interval'),
            ),
          );
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [field, apply],
          );
        },
      ),
      const SizedBox(height: 8),
      Text(
        model.intervalError ?? 'Whole minutes, 1–1440.',
        style: TextStyle(
          color: model.intervalError == null ? muted : const Color(0xFFAB3C30),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Presets save immediately. For a custom value, select Apply interval. The next check-in starts from when you apply the change.',
        style: TextStyle(color: muted, fontSize: 12, height: 1.6),
      ),
    ],
  );
}
