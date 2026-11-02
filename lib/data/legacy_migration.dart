import 'dart:io';

// Copy legacy data without modifying the original Daymark folder. Copy the
// primary file last so an interrupted migration is safe to retry.
Future<void> migrateLegacyData(Directory root) async {
  final legacy = Directory('${root.path}${Platform.pathSeparator}Daymark');
  final destination = Directory(
    '${root.path}${Platform.pathSeparator}FocusTrack',
  );
  final primary = File(
    '${destination.path}${Platform.pathSeparator}focustrack.json',
  );
  final oldPrimary = File(
    '${legacy.path}${Platform.pathSeparator}daymark.json',
  );
  if (await primary.exists() || !await oldPrimary.exists()) return;
  await destination.create(recursive: true);
  final backup = File('${oldPrimary.path}.bak');
  if (await backup.exists()) await backup.copy('${primary.path}.bak');
  final temporary = await oldPrimary.copy('${primary.path}.migrating');
  await temporary.rename(primary.path);
}
