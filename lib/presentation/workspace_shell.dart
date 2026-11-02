import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../application/workspace_controller.dart';

import '../domain/activity_repository.dart';
import 'overview_view.dart';
import 'reports_view.dart';
import 'preferences_view.dart';
import 'activity_prompt.dart';
import 'task_review.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.store});
  final ActivityRepository store;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final WorkspaceController model;
  @override
  void initState() {
    super.initState();
    model = WorkspaceController(
      widget.store,
      onMessage: (text) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
        );
      },
      beforePrompt: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      },
    );
    model.addListener(refresh);
    model.initialize();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    model.removeListener(refresh);
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (model.prompt)
      return model.reviewingTasks
          ? TaskReview(model: model)
          : ActivityPrompt(model: model);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 960;
          return Row(
            children: [
              sidebar(context, narrow),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 19,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE9ECE6)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              [
                                'Workspace / Overview',
                                'Workspace / Daily reports',
                                'Workspace / Preferences',
                              ][model.page],
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: green,
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Offline & private',
                            style: TextStyle(color: green, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(narrow ? 20 : 30),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: model.page == 0
                                ? OverviewView(model: model, narrow: narrow)
                                : model.page == 1
                                ? ReportsView(model: model)
                                : PreferencesView(model: model),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget sidebar(BuildContext context, bool narrow) => Container(
    width: narrow ? 80 : 220,
    color: const Color(0xFF193E31),
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: narrow ? 0 : 9),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9EDB7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.done_all_rounded,
                  color: Color(0xFF193E31),
                  size: 24,
                ),
              ),
              if (!narrow) ...[
                const SizedBox(width: 12),
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'FocusTrack',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 42),
        for (final item in [
          (Icons.space_dashboard_outlined, 'Overview'),
          (Icons.article_outlined, 'Daily reports'),
          (Icons.tune_rounded, 'Preferences'),
        ].indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tooltip(
              message: item.$2.$2,
              child: Material(
                color: model.page == item.$1
                    ? const Color(0xFF315443)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => model.update(() {
                    model.page = item.$1;
                    model.error = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.$2.$1,
                          size: 20,
                          color: model.page == item.$1
                              ? const Color(0xFFD9EDB7)
                              : Colors.white60,
                        ),
                        if (!narrow) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.$2.$2,
                              style: TextStyle(
                                color: model.page == item.$1
                                    ? Colors.white
                                    : Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        if (!narrow && MediaQuery.sizeOf(context).height >= 680)
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF254A3B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFFD9EDB7),
                  size: 25,
                ),
                SizedBox(height: 12),
                Text(
                  'Small notes.\nA clearer day.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your work deserves\nto be remembered.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (!narrow)
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'FOCUSTRACK  /  PERSONAL',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    ),
  );
}
