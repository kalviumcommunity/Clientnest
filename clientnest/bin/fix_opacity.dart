import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return;

  final regex = RegExp(r'\.withOpacity\(([^)]+)\)');
  int count = 0;

  for (var entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains('.withOpacity(')) {
        final newContent = content.replaceAllMapped(regex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });
        entity.writeAsStringSync(newContent);
        count++;
      }
    }
  }
  print('Fixed withOpacity in $count files.');
}
