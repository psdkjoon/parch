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

  // Git
  String gitName;
  String gitEmail;

  // Dotfiles / extras
  bool installDotfiles;
  String repoUrl;
  bool installCustomTools;
  Map<String, String> customInstallers;
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
    required this.gitName,
    required this.gitEmail,
    required this.installDotfiles,
    required this.repoUrl,
    required this.installCustomTools,
    required this.customInstallers,
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
        'gitName': gitName,
        'gitEmail': gitEmail,
        'installDotfiles': installDotfiles,
        'repoUrl': repoUrl,
        'installCustomTools': installCustomTools,
        'customInstallers': customInstallers,
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
        gitName: j['gitName'],
        gitEmail: j['gitEmail'],
        installDotfiles: j['installDotfiles'],
        repoUrl: j['repoUrl'],
        installCustomTools: j['installCustomTools'],
        customInstallers: Map<String, String>.from(j['customInstallers']),
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
      'Timezone (e.g. Asia/Baku)',
      fallback: 'Asia/Baku',
    );
    final locale = askString('Locale', fallback: 'en_US.UTF-8');
    final keymap = askString('Console keymap', fallback: 'us');
    final consoleFont = askString('Console font', fallback: 'ter-132b');

    section('Disk');
    final rootDisk = askString(
      'Target disk (e.g. /dev/nvme0n1)',
      fallback: '/dev/nvme0n1',
    );
    final bootPart = askString('EFI/boot partition', fallback: '${rootDisk}p1');
    final rootPart = askString('Root partition', fallback: '${rootDisk}p2');

    section('Encryption');
    final encryptionEnabled = askBool(
      'Enable full-disk encryption (LUKS)?',
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
        fallback: 1);
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
    ]);
    final aurPackages = askList('AUR packages (installed via yay)', [
      'oh-my-posh',
      'hyprlauncher',
      'thefuck',
      'gping',
      'mpd-mpris',
    ]);

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
    var repoUrl = 'https://github.com/psdkjoon/parch';
    if (installDotfiles) {
      repoUrl = askString(
        'This repo\'s URL (post phase clones it to grab dotfiles/)',
        fallback: repoUrl,
      );
    }

    section('Custom tools');
    final installCustomTools = askBool(
      'Install your custom pdm/asd installers?',
      fallback: true,
    );
    var customInstallers = <String, String>{};
    if (installCustomTools) {
      customInstallers = {
        'pdm': askString(
          'pdm installer URL',
          fallback:
              'https://github.com/psdkjoon/pdm/releases/download/latest/pdm-installer-linux-x64',
        ),
        'asd': askString(
          'asd installer URL',
          fallback:
              'https://github.com/psdkjoon/asd/releases/download/latest/installer-linux',
        ),
      };
    }

    section('Flutter');
    final installFlutter = askBool(
      'Set up Flutter + your custom template?',
      fallback: true,
    );
    var flutterUrl = '';
    var flutterVer = await flutterVersion();
    var flutterTemplateRepo = '';
    var androidComponents = <String>[];
    if (installFlutter) {
      flutterUrl = askString(
        'Flutter SDK tarball URL',
        fallback:
            'https://pub.myket.ir/flutter_infra_release/releases/stable/linux/flutter_linux_$flutterVer-stable.tar.xz',
      );
      flutterTemplateRepo = askString(
        'Flutter template repo URL',
        fallback: 'https://github.com/psdkjoon/flutter-tmpl',
      );
      androidComponents = askList('Android SDK components (via `asd`)', [
        'cmdline-tools',
        'platform-tools',
        'ndk',
        'platforms',
        'build-tools',
      ]);
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
      gitName: gitName,
      gitEmail: gitEmail,
      installDotfiles: installDotfiles,
      repoUrl: repoUrl,
      installCustomTools: installCustomTools,
      customInstallers: customInstallers,
      installFlutter: installFlutter,
      flutterUrl: flutterUrl,
      flutterTemplateRepo: flutterTemplateRepo,
      androidComponents: androidComponents,
    );
  }
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
