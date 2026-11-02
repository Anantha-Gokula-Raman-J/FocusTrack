import 'dart:io';

import 'package:flutter/material.dart';

import '../data/activity_store.dart';
import '../data/legacy_migration.dart';
import 'focustrack_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final root = Directory(
    Platform.environment['APPDATA'] ?? Directory.current.path,
  );
  final directory = Directory('${root.path}\\FocusTrack');
  final store = FocusTrackStore(directory);
  String? failure;
  try {
    await migrateLegacyData(root);
    await store.load();
  } catch (e) {
    failure = 'Unable to load your data. $e';
  }
  runApp(FocusTrackApp(store: store, failure: failure));
}
