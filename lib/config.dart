import 'dart:convert';
import 'dart:io';

import 'prompt.dart';

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

  static AppConfig fromJson(Map<String, dynamic> j) => AppConfig(
    hostname: j['hostname'],
    username: j['username'],
    timezone: j['timezone'],
    locale: j['locale'],
    keymap: j['keymap'],
    consoleFont: j['consoleFont'],
    encryptionEnabled: j['encryptionEnabled'],
    useUsbKeyfile: j['useUsbKeyfile'],
    rootDisk: j['rootDisk'],
    efiSize: j['efiSize'],
    bootPart: j['bootPart'],
    rootPart: j['rootPart'],
    mapperName: j['mapperName'],
    usbDisk: j['usbDisk'],
    usbPart: j['usbPart'],
    keyfileName: j['keyfileName'],
    loginMethod: j['loginMethod'],
    session: j['session'],
    autostartOnTty: j['autostartOnTty'],
    nopasswdSudo: j['nopasswdSudo'],
    basePackages: List<String>.from(j['basePackages']),
    officialPackages: List<String>.from(j['officialPackages']),
    aurPackages: List<String>.from(j['aurPackages']),
    packageHooks: Map<String, String>.from(j['packageHooks']),
    gitName: j['gitName'],
    gitEmail: j['gitEmail'],
    installDotfiles: j['installDotfiles'],
    dotfilesRepoUrl: j['dotfilesRepoUrl'] ?? j['repoUrl'],
    dotfilesPath: j['dotfilesPath'],
    installCustomTools: j['installCustomTools'],
    customTools: (j['customTools'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, Map<String, String>.from(v as Map)),
    ),
    installFlutter: j['installFlutter'],
    flutterUrl: j['flutterUrl'],
    flutterTemplateRepo: j['flutterTemplateRepo'],
    androidComponents: List<String>.from(j['androidComponents']),
  );

  static Future<AppConfig> load(String path) async {
    final content = await File(path).readAsString();
    return AppConfig.fromJson(jsonDecode(content));
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
    final loginMethod = askChoice('How do you want to log in?', [
      'tty',
      'greetd',
    ], fallback: 1);
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
      final latest = await flutterVersion();
      final version = askString('Flutter version', fallback: latest);
      flutterUrl =
          'https://pub.myket.ir/flutter_infra_release/releases/stable/'
          'linux/flutter_linux_$version-stable.tar.xz';
      flutterTemplateRepo = askString(
        'Flutter template repo URL',
        fallback: 'https://github.com/psdkjoon/flutter-tmpl',
      );
      if (useDefaults) {
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
      version = json['releases'][0]['version'];
    }
  } catch (_) {
  } finally {
    client.close();
  }
  return version;
}
