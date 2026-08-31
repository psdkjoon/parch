import 'dart:io';

String askString(String question, {String? fallback}) {
  while (true) {
    final suffix = fallback != null ? ' [$fallback]' : '';
    stdout.write('$question$suffix: ');
    final line = stdin.readLineSync();
    final value = (line ?? '').trim();
    if (value.isNotEmpty) return value;
    if (fallback != null) return fallback;
    stdout.writeln('  (required, please enter a value)');
  }
}

String? askOptionalString(String question, {String? fallback}) {
  final suffix = fallback != null ? ' [$fallback]' : ' [skip]';
  stdout.write('$question$suffix: ');
  final line = stdin.readLineSync();
  final value = (line ?? '').trim();
  if (value.isEmpty) return fallback;
  return value;
}

bool askBool(String question, {bool fallback = true}) {
  final hint = fallback ? 'Y/n' : 'y/N';
  while (true) {
    stdout.write('$question [$hint]: ');
    final line = (stdin.readLineSync() ?? '').trim().toLowerCase();
    if (line.isEmpty) return fallback;
    if (line == 'y' || line == 'yes') return true;
    if (line == 'n' || line == 'no') return false;
    stdout.writeln('  (please answer y or n)');
  }
}

String askChoice(String question, List<String> options, {int fallback = 0}) {
  stdout.writeln(question);
  for (var i = 0; i < options.length; i++) {
    stdout.writeln('  ${i + 1}) ${options[i]}');
  }
  while (true) {
    stdout.write('Choice [${fallback + 1}]: ');
    final line = (stdin.readLineSync() ?? '').trim();
    if (line.isEmpty) return options[fallback];
    final n = int.tryParse(line);
    if (n != null && n >= 1 && n <= options.length) return options[n - 1];
    stdout.writeln('  (enter a number between 1 and ${options.length})');
  }
}

List<String> askList(String question, List<String> defaults) {
  stdout.writeln('$question');
  stdout.writeln('  Default: ${defaults.join(', ')}');
  stdout.write(
    '  Press enter to keep it, or edit with +pkg to add / -pkg to remove '
    '(comma-separated, e.g. "-thefuck,+fzf"): ',
  );
  final line = (stdin.readLineSync() ?? '').trim();
  if (line.isEmpty) return List.of(defaults);
  final result = List<String>.of(defaults);
  for (final rawToken in line.split(',')) {
    final token = rawToken.trim();
    if (token.isEmpty) continue;
    if (token.startsWith('-')) {
      final pkg = token.substring(1).trim();
      result.remove(pkg);
    } else if (token.startsWith('+')) {
      final pkg = token.substring(1).trim();
      if (pkg.isNotEmpty && !result.contains(pkg)) result.add(pkg);
    } else if (!result.contains(token)) {
      result.add(token);
    }
  }
  return result;
}

void section(String title) {
  stdout.writeln('\n=== $title ===');
}
