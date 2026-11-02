import 'app/bootstrap.dart';

// Compatibility exports for existing consumers and tests.
export 'app/focustrack_app.dart';
export 'platform/windows_desktop.dart' show native;

Future<void> main() => bootstrap();
