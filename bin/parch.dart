import 'dart:io';

import 'package:parch/config.dart';
import 'package:parch/phases.dart';

const defaultConfigFile = 'parch_config.json';

void printUsage() {
  stderr.writeln('Usage: parch <configure|live|chroot|post> [--config=path]');
  stderr.writeln('');
  stderr.writeln('  configure  Ask all questions and save parch_config.json');
  stderr.writeln('  live       Run from the Arch ISO, before arch-chroot');
  stderr.writeln('  chroot     Run inside `arch-chroot /mnt`');
  stderr.writeln('  post       Run after first reboot, as your new user');
  stderr.writeln('');
  stderr.writeln('If no config file exists yet, "live"/"chroot"/"post" will');
  stderr
      .writeln('run the interactive questionnaire first and save it for you.');
}

String configPathFromArgs(List<String> args) {
  for (final a in args) {
    if (a.startsWith('--config=')) return a.substring('--config='.length);
  }
  return defaultConfigFile;
}

Future<AppConfig> loadOrConfigure(String path) async {
  if (await File(path).exists()) {
    stdout.writeln('Loaded config from $path');
    return AppConfig.load(path);
  }
  stdout.writeln("No config found at $path - let's set one up.\n");
  final config = await AppConfig.interactive();
  await config.save(path);
  stdout.writeln('\nSaved $path');
  return config;
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    printUsage();
    exit(1);
  }

  final phase = args.first;
  final configPath = configPathFromArgs(args);

  try {
    switch (phase) {
      case 'configure':
        final config = await AppConfig.interactive();
        await config.save(configPath);
        stdout.writeln('\nSaved $configPath');
        break;
      case 'live':
        final config = await loadOrConfigure(configPath);
        await phaseLive(config, configPath);
        break;
      case 'chroot':
        final config = await loadOrConfigure(configPath);
        await phaseChroot(config, configPath);
        break;
      case 'post':
        final config = await loadOrConfigure(configPath);
        await phasePostReboot(config, configPath);
        break;
      default:
        printUsage();
        exit(1);
    }
  } on CommandFailed catch (e) {
    stderr.writeln('\n!! Aborting: $e');
    exit(e.code == 0 ? 1 : e.code);
  } on ConfigLoadError catch (e) {
    stderr.writeln('!! $e');
    exit(1);
  }
}
