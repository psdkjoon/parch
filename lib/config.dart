import 'dart:convert';
import 'dart:io';

import 'prompt.dart';

const configSchemaVersion = 1;

class ConfigLoadError implements Exception {
  final String message;
  ConfigLoadError(this.message);
  @override
  String toString() => message;
}

String _reqString(Map<String, dynamic> j, String key, {String? fallback}) {
  final v = j[key];
  if (v == null) {
    if (fallback != null) return fallback;
    throw ConfigLoadError(
      'Config is missing required field "$key". If this is an old '
      'parch_config.json, delete it and run "parch configure" again.',
    );
  }
  if (v is! String) {
    throw ConfigLoadError('Config field "$key" should be text, got: $v');
  }
  return v;
}

bool _reqBool(Map<String, dynamic> j, String key, {bool? fallback}) {
  final v = j[key];
  if (v == null) {
    if (fallback != null) return fallback;
    throw ConfigLoadError(
      'Config is missing required field "$key". If this is an old '
      'parch_config.json, delete it and run "parch configure" again.',
    );
  }
  if (v is! bool) {
    throw ConfigLoadError('Config field "$key" should be true/false, got: $v');
  }
  return v;
}

List<String> _reqListString(
  Map<String, dynamic> j,
  String key, {
  List<String>? fallback,
}) {
  final v = j[key];
  if (v == null) {
    if (fallback != null) return fallback;
    throw ConfigLoadError(
      'Config is missing required field "$key". If this is an old '
      'parch_config.json, delete it and run "parch configure" again.',
    );
  }
  if (v is! List) {
    throw ConfigLoadError('Config field "$key" should be a list, got: $v');
  }
  try {
    return List<String>.from(v);
  } catch (_) {
    throw ConfigLoadError(
      'Config field "$key" should be a list of text values.',
    );
  }
}

Map<String, String> _reqMapString(
  Map<String, dynamic> j,
  String key, {
  Map<String, String>? fallback,
}) {
  final v = j[key];
  if (v == null) {
    if (fallback != null) return fallback;
    throw ConfigLoadError(
      'Config is missing required field "$key". If this is an old '
      'parch_config.json, delete it and run "parch configure" again.',
    );
  }
  if (v is! Map) {
    throw ConfigLoadError('Config field "$key" should be a map, got: $v');
  }
  try {
    return Map<String, String>.from(v);
  } catch (_) {
    throw ConfigLoadError('Config field "$key" should map text to text.');
  }
}

class AppConfig {
  // Identity
  String hostname;
  String username;
  String timezone;
  String locale;
  String keymap;
  String consoleFont;

  // Disk / encryption
  bool encryptionEnabled;
  bool useUsbKeyfile;
  String rootDisk;
  String efiSize;
  String bootPart;
  String rootPart;
  String mapperName;
  String usbDisk;
  String usbPart;
  String keyfileName;

  // Login / session
  String loginMethod;
  String session;
  bool autostartOnTty;

  // Sudo
  bool nopasswdSudo;

  // Packages
  List<String> basePackages;
  List<String> officialPackages;
  List<String> aurPackages;
  Map<String, String> packageHooks;

  // Git
  String gitName;
  String gitEmail;

  // Dotfiles / extras
  bool installDotfiles;
  String dotfilesRepoUrl;
  String dotfilesPath;
  bool installCustomTools;
  Map<String, Map<String, String>> customTools;
  bool installFlutter;
  String flutterUrl;
  String flutterTemplateRepo;
  List<String> androidComponents;

  AppConfig({
    required this.hostname,
    required this.username,
    required this.timezone,
    required this.locale,
    required this.keymap,
    required this.consoleFont,
    required this.encryptionEnabled,
    required this.useUsbKeyfile,
    required this.rootDisk,
    required this.efiSize,
    required this.bootPart,
    required this.rootPart,
    required this.mapperName,
    required this.usbDisk,
    required this.usbPart,
    required this.keyfileName,
    required this.loginMethod,
    required this.session,
    required this.autostartOnTty,
    required this.nopasswdSudo,
    required this.basePackages,
    required this.officialPackages,
    required this.aurPackages,
    required this.packageHooks,
    required this.gitName,
    required this.gitEmail,
    required this.installDotfiles,
    required this.dotfilesRepoUrl,
    required this.dotfilesPath,
    required this.installCustomTools,
    required this.customTools,
    required this.installFlutter,
    required this.flutterUrl,
    required this.flutterTemplateRepo,
    required this.androidComponents,
  });

  Map<String, dynamic> toJson() => {
        'configVersion': configSchemaVersion,
        'hostname': hostname,
        'username': username,
        'timezone': timezone,
        'locale': locale,
        'keymap': keymap,
        'consoleFont': consoleFont,
        'encryptionEnabled': encryptionEnabled,
        'useUsbKeyfile': useUsbKeyfile,
        'rootDisk': rootDisk,
        'efiSize': efiSize,
        'bootPart': bootPart,
        'rootPart': rootPart,
        'mapperName': mapperName,
        'usbDisk': usbDisk,
        'usbPart': usbPart,
        'keyfileName': keyfileName,
        'loginMethod': loginMethod,
        'session': session,
        'autostartOnTty': autostartOnTty,
        'nopasswdSudo': nopasswdSudo,
        'basePackages': basePackages,
        'officialPackages': officialPackages,
        'aurPackages': aurPackages,
        'packageHooks': packageHooks,
        'gitName': gitName,
        'gitEmail': gitEmail,
        'installDotfiles': installDotfiles,
        'dotfilesRepoUrl': dotfilesRepoUrl,
        'dotfilesPath': dotfilesPath,
        'installCustomTools': installCustomTools,
        'customTools': customTools,
        'installFlutter': installFlutter,
        'flutterUrl': flutterUrl,
        'flutterTemplateRepo': flutterTemplateRepo,
        'androidComponents': androidComponents,
      };

  static AppConfig fromJson(Map<String, dynamic> j) {
    final fileVersion = j['configVersion'];
    if (fileVersion is! int || fileVersion < configSchemaVersion) {
      stdout.writeln(
        '(note: loading a config from an older/unversioned parch - '
        'missing fields will fall back to defaults where possible)',
      );
    }
    return AppConfig(
      hostname: _reqString(j, 'hostname'),
      username: _reqString(j, 'username'),
      timezone: _reqString(j, 'timezone'),
      locale: _reqString(j, 'locale'),
      keymap: _reqString(j, 'keymap'),
      consoleFont: _reqString(j, 'consoleFont'),
      encryptionEnabled: _reqBool(j, 'encryptionEnabled'),
      useUsbKeyfile: _reqBool(j, 'useUsbKeyfile', fallback: false),
      rootDisk: _reqString(j, 'rootDisk'),
      efiSize: _reqString(j, 'efiSize', fallback: '1GiB'),
      bootPart: _reqString(j, 'bootPart'),
      rootPart: _reqString(j, 'rootPart'),
      mapperName: _reqString(j, 'mapperName', fallback: 'cryptroot'),
      usbDisk: _reqString(j, 'usbDisk', fallback: ''),
      usbPart: _reqString(j, 'usbPart', fallback: ''),
      keyfileName: _reqString(j, 'keyfileName', fallback: 'luks.key'),
      loginMethod: _reqString(j, 'loginMethod'),
      session: _reqString(j, 'session'),
      autostartOnTty: _reqBool(j, 'autostartOnTty', fallback: false),
      nopasswdSudo: _reqBool(j, 'nopasswdSudo', fallback: false),
      basePackages: _reqListString(j, 'basePackages'),
      officialPackages: _reqListString(j, 'officialPackages'),
      aurPackages: _reqListString(j, 'aurPackages', fallback: []),
      packageHooks: _reqMapString(j, 'packageHooks', fallback: {}),
      gitName: _reqString(j, 'gitName', fallback: ''),
      gitEmail: _reqString(j, 'gitEmail', fallback: ''),
      installDotfiles: _reqBool(j, 'installDotfiles', fallback: false),
      dotfilesRepoUrl: _reqString(
        j,
        'dotfilesRepoUrl',
        fallback: j['repoUrl'] is String ? j['repoUrl'] as String : '',
      ),
      dotfilesPath: _reqString(j, 'dotfilesPath', fallback: 'dotfiles'),
      installCustomTools: _reqBool(j, 'installCustomTools', fallback: false),
      customTools: (() {
        final raw = j['customTools'];
        if (raw == null) return <String, Map<String, String>>{};
        if (raw is! Map) {
          throw ConfigLoadError('Config field "customTools" should be a map.');
        }
        try {
          return raw.map(
            (k, v) => MapEntry(k as String, Map<String, String>.from(v as Map)),
          );
        } catch (_) {
          throw ConfigLoadError(
            'Config field "customTools" should map tool name to a '
            '{repo, asset} map.',
          );
        }
      })(),
      installFlutter: _reqBool(j, 'installFlutter', fallback: false),
      flutterUrl: _reqString(j, 'flutterUrl', fallback: ''),
      flutterTemplateRepo: _reqString(j, 'flutterTemplateRepo', fallback: ''),
      androidComponents: _reqListString(j, 'androidComponents', fallback: []),
    );
  }

  static Future<AppConfig> load(String path) async {
    final content = await File(path).readAsString();
    try {
      return AppConfig.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } on ConfigLoadError {
      rethrow;
    } catch (e) {
      throw ConfigLoadError('Could not parse $path as JSON: $e');
    }
  }

  Future<void> save(String path) async {
    await File(
      path,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(toJson()));
  }

  static Future<AppConfig> interactive() async {
    section('Identity');
    final hostname = askString('Hostname for this machine');
    final username = askString('Username', fallback: 'psdk');
    final timezone = askString(
      'Timezone (e.g. Asia/Tehran)',
      fallback: 'Asia/Tehran',
    );
    final locale = askString('Locale', fallback: 'en_US.UTF-8');
    final keymap = askString('Console keymap', fallback: 'us');
    final consoleFont = askString('Console font', fallback: 'ter-132b');

    section('Disk');
    final rootDisk = await pickDisk();
    final efiSize = askString(
      'EFI partition size (rest of the disk becomes root)',
      fallback: '1GiB',
    );
    final suffix = partitionSuffix(rootDisk);
    final bootPart = '$rootDisk${suffix}1';
    final rootPart = '$rootDisk${suffix}2';
    stdout.writeln(
      '  -> Will auto-partition $rootDisk: $bootPart (EFI, $efiSize) + '
      '$rootPart (root, rest of disk). The whole disk will be wiped.',
    );

    section('Encryption');
    final encryptionEnabled = askBool(
      'Enable full-disk encryption (LUKS2)?',
      fallback: true,
    );
    var useUsbKeyfile = false;
    var usbDisk = '';
    var usbPart = '';
    var keyfileName = 'luks.key';
    var mapperName = 'cryptroot';
    if (encryptionEnabled) {
      mapperName = askString(
        'Name for the unlocked mapper device',
        fallback: 'cryptroot',
      );
      useUsbKeyfile = askBool(
        'Also unlock via a keyfile stored on a USB stick?',
        fallback: false,
      );
      if (useUsbKeyfile) {
        usbDisk = askString('USB disk (e.g. /dev/sdc)', fallback: '/dev/sdc');
        usbPart = askString('USB partition', fallback: '${usbDisk}1');
        keyfileName = askString('Keyfile name', fallback: 'luks.key');
      }
    }

    section('Login & session');
    final loginMethod = askChoice(
      'How do you want to log in?',
      [
        'tty',
        'greetd',
      ],
      fallback: 1,
    );
    final session = askChoice(
      loginMethod == 'greetd'
          ? 'What should greetd launch after login?'
          : 'What should start your graphical session?',
      ['hyprland', 'cage-kitty'],
      fallback: 0,
    );
    var autostartOnTty = false;
    if (loginMethod == 'tty') {
      autostartOnTty = askBool(
        'Auto-start that session on tty1 login (via shell profile)?',
        fallback: true,
      );
    }

    section('Sudo');
    final nopasswdSudo = askBool(
      'Allow passwordless sudo (NOPASSWD) for $username?',
      fallback: false,
    );

    section('Packages');
    final basePackages = askList('Base packages (pacstrap, live install)', [
      'base',
      'linux',
      'linux-firmware',
      'networkmanager',
      'cryptsetup',
      'intel-ucode',
      'neovim',
      'sudo',
    ]);
    final officialPackages =
        askList('Official repo packages (installed after reboot)', [
      'git',
      'github-cli',
      'wget',
      'curl',
      'yazi',
      'btop',
      'ripgrep',
      'fd',
      'zsh',
      'lazygit',
      'lsd',
      'zoxide',
      'aria2',
      'cloc',
      'kitty',
      'ffmpeg',
      'imagemagick',
      'bat',
      'cava',
      'swaync',
      'dust',
      'firefox',
      'p7zip',
      'jdk-openjdk',
      'fzf',
      'yt-dlp',
      'fcitx5',
      'fcitx5-qt',
      'fcitx5-gtk',
      'gnome-keyring',
      'qt5ct',
      'qt6ct',
      'playerctl',
      'bluez',
      'bluez-utils',
      'pipewire',
      'pipewire-pulse',
      'wireplumber',
      'nerd-fonts',
      'mpd',
      'mpc',
      'rmpc',
    ]);
    final aurPackages = askList('AUR packages (installed via yay)', [
      'oh-my-posh',
      'hyprlauncher',
      'gping',
      'mpd-mpris',
    ]);

    section('Package hooks');
    final selectedPackages = {
      ...basePackages,
      ...officialPackages,
      ...aurPackages,
    };
    var packageHooks = <String, String>{};
    while (askBool(
      packageHooks.isEmpty
          ? 'Add a package hook?'
          : 'Add another package hook?',
      fallback: false,
    )) {
      final pkg = askString('Package name (as it appears in a list above)');
      if (!selectedPackages.contains(pkg)) {
        stdout.writeln('  (note: "$pkg" isn\'t in your package lists yet)');
      }
      final cmd = askString('Shell command to run once $pkg is installed');
      packageHooks[pkg] = cmd;
    }

    section('Git identity');
    final gitName = askString('Git user.name', fallback: 'psdkjoon');
    final gitEmail = askString(
      'Git user.email',
      fallback: 'psdkjoon@gmail.com',
    );

    section('Dotfiles');
    final installDotfiles = askBool(
      'Install the bundled dotfiles (hyprland/waybar/kitty/'
      'nvim/zsh/...)?',
      fallback: true,
    );
    var dotfilesRepoUrl = 'https://github.com/psdkjoon/parch';
    var dotfilesPath = 'dotfiles';
    if (installDotfiles) {
      dotfilesRepoUrl = askString(
        'Dotfiles repo URL',
        fallback: dotfilesRepoUrl,
      );
      dotfilesPath = askString(
        'Path to the dotfiles inside that repo',
        fallback: dotfilesPath,
      );
    }

    section('Custom tools');
    var customTools = <String, Map<String, String>>{};
    final useDefaults = askBool(
      'Install the default tools (pdm, asd)?',
      fallback: true,
    );
    if (useDefaults) {
      customTools['pdm'] = {
        'repo': 'psdkjoon/pdm',
        'asset': 'pdm-installer-linux-x64',
      };
      customTools['asd'] = {'repo': 'psdkjoon/asd', 'asset': 'installer-linux'};
    }
    final installCustomTools = askBool(
      'Install custom tools from GitHub releases?',
      fallback: true,
    );
    if (installCustomTools) {
      if (!officialPackages.contains('aria2')) {
        officialPackages.add('aria2');
        stdout.writeln(
          '  (added "aria2" to official packages - needed to download '
          'custom tool releases)',
        );
      }
      while (askBool(
        customTools.isEmpty ? 'Add a custom tool?' : 'Add another custom tool?',
        fallback: false,
      )) {
        final name = askString('Tool name');
        final repo = askString('GitHub repo (owner/repo)');
        final asset = askString(
          "Release asset filename, exact match (parch fetches the repo's "
          'actual latest release, not a "latest" tag)',
        );
        customTools[name] = {'repo': repo, 'asset': asset};
      }
    }

    section('Flutter');
    final installFlutter = askBool(
      'Set up Flutter + your custom template?',
      fallback: true,
    );
    var flutterUrl = '';
    var flutterTemplateRepo = '';
    var androidComponents = <String>[];
    if (installFlutter) {
      final addedForFlutter = <String>[];
      if (!officialPackages.contains('wget')) {
        officialPackages.add('wget');
        addedForFlutter.add('wget');
      }
      if (!officialPackages.contains('p7zip')) {
        officialPackages.add('p7zip');
        addedForFlutter.add('p7zip');
      }
      if (addedForFlutter.isNotEmpty) {
        stdout.writeln(
          '  (added ${addedForFlutter.join(', ')} to official packages - '
          'needed to download/extract Flutter)',
        );
      }
      final latest = await flutterVersion();
      final version = askString('Flutter version', fallback: latest);
      flutterUrl = 'https://pub.myket.ir/flutter_infra_release/releases/stable/'
          'linux/flutter_linux_$version-stable.tar.xz';
      flutterTemplateRepo = askString(
        'Flutter template repo URL',
        fallback: 'https://github.com/psdkjoon/flutter-tmpl',
      );
      if (customTools.containsKey('asd')) {
        androidComponents = askList('Android SDK components (via `asd`)', [
          'cmdline-tools',
          'platform-tools',
          'ndk',
          'platforms',
          'build-tools',
        ]);
      }
    }

    return AppConfig(
      hostname: hostname,
      username: username,
      timezone: timezone,
      locale: locale,
      keymap: keymap,
      consoleFont: consoleFont,
      encryptionEnabled: encryptionEnabled,
      useUsbKeyfile: useUsbKeyfile,
      rootDisk: rootDisk,
      efiSize: efiSize,
      bootPart: bootPart,
      rootPart: rootPart,
      mapperName: mapperName,
      usbDisk: usbDisk,
      usbPart: usbPart,
      keyfileName: keyfileName,
      loginMethod: loginMethod,
      session: session,
      autostartOnTty: autostartOnTty,
      nopasswdSudo: nopasswdSudo,
      basePackages: basePackages,
      officialPackages: officialPackages,
      aurPackages: aurPackages,
      packageHooks: packageHooks,
      gitName: gitName,
      gitEmail: gitEmail,
      installDotfiles: installDotfiles,
      dotfilesRepoUrl: dotfilesRepoUrl,
      dotfilesPath: dotfilesPath,
      installCustomTools: installCustomTools,
      customTools: customTools,
      installFlutter: installFlutter,
      flutterUrl: flutterUrl,
      flutterTemplateRepo: flutterTemplateRepo,
      androidComponents: androidComponents,
    );
  }
}

bool pkgSelected(AppConfig c, String pkg) =>
    c.basePackages.contains(pkg) ||
    c.officialPackages.contains(pkg) ||
    c.aurPackages.contains(pkg);

String partitionSuffix(String disk) {
  final base = disk.split('/').last;
  return RegExp(r'\d$').hasMatch(base) ? 'p' : '';
}

Future<String> pickDisk() async {
  List<String> disks = [];
  try {
    final result = await Process.run('lsblk', [
      '-dnpo',
      'NAME,SIZE,MODEL',
      '-e',
      '7,11',
    ]);
    if (result.exitCode == 0) {
      disks = (result.stdout as String)
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    }
  } catch (_) {}

  if (disks.isEmpty) {
    return askString(
      'Target disk (e.g. /dev/nvme0n1)',
      fallback: '/dev/nvme0n1',
    );
  }

  const manualEntry = 'Enter manually';
  final choice = askChoice('Target disk', [...disks, manualEntry]);
  if (choice == manualEntry) {
    return askString(
      'Target disk (e.g. /dev/nvme0n1)',
      fallback: '/dev/nvme0n1',
    );
  }
  return choice.split(RegExp(r'\s+')).first;
}

Future<String> flutterVersion() async {
  final client = HttpClient();
  String version = '3.44.0';
  try {
    final request = await client.getUrl(
      Uri.parse(
        'https://pub.myket.ir/flutter_infra_release/releases/releases_linux.json',
      ),
    );
    final response = await request.close();
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);
      version = json['releases'][0]['version'] as String;
    }
  } catch (_) {
  } finally {
    client.close();
  }
  return version;
}
