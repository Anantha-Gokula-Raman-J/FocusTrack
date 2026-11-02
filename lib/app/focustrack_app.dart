import 'package:flutter/material.dart';

import '../data/activity_store.dart';
import '../platform/windows_desktop.dart';
import '../presentation/workspace_shell.dart';
import 'app_theme.dart';

class FocusTrackApp extends StatelessWidget {
  const FocusTrackApp({super.key, required this.store, this.failure});
  final FocusTrackStore store;
  final String? failure;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FocusTrack',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: failure != null
        ? Scaffold(
            body: Center(
              child: SizedBox(
                width: 540,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_off_outlined, size: 48),
                    const SizedBox(height: 20),
                    Text(failure!),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => const WindowsDesktop().openFolder(
                        store.directory.path,
                      ),
                      child: const Text('Open data folder'),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Home(store: store),
  );
}
