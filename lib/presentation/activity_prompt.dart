import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';

import 'components.dart';

class ActivityPrompt extends StatelessWidget {
  const ActivityPrompt({super.key, required this.model});
  final WorkspaceController model;
  @override
  Widget build(BuildContext context) => promptView(context);
  Widget promptView(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC9D9C3)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.done_all_rounded, color: green, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'FocusTrack',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Skip this check-in',
                onPressed: model.busy ? null : model.dismiss,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What’s keeping you busy?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'A quick note now. A clearer day later.',
                    style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: model.promptNote,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      hintText: 'Kindly log the current work',
                      counterText: '',
                    ),
                  ),
                  errorView(model),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Next: your checklist',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: model.busy ? null : model.dismiss,
                child: const Text('Skip'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: model.busy
                    ? null
                    : () => model.logNote(fromPrompt: true),
                child: Text(model.busy ? 'Saving...' : 'Log'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
