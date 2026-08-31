import 'dart:convert';
import 'dart:io';

import 'config.dart';
import 'prompt.dart';

Future<void> sh(String cmd, {bool check = true}) async {
  stdout.writeln('\n\$ $cmd');
  final proc = await Process.start('bash', [
    '-c',
    cmd,
  ], mode: ProcessStartMode.inheritStdio);
  final code = await proc.exitCode;
  if (check && code != 0) {
    stderr.writeln('!! Command failed ($code): $cmd');
    exit(code);
  }
}

Future<String> capture(String cmd) async {
  final result = await Process.run('bash', ['-c', cmd]);
  return (result.stdout as String).trim();
}

Future<void> carryForward(String configPath, String destDir) async {
  final exe = Platform.resolvedExecutable;
  if (!exe.endsWith('parch') && !exe.contains('parch')) {
    stdout.writeln(
      "\n(Running via 'dart run' - copy this project and $configPath "
      'into $destDir yourself before continuing.)',
    );
    return;
  }
  await sh('mkdir -p $destDir', check: false);
  await sh('cp "$exe" "$destDir/parch"', check: false);
  await sh('cp "$configPath" "$destDir/parch_config.json"', check: false);
}

String sessionCommand(AppConfig c) =>
    c.session == 'hyprland' ? 'Hyprland' : 'cage -s -- kitty';

List<String> sessionPackages(AppConfig c) {
  final pkgs = <String>[];
  if (c.session == 'hyprland') {
    pkgs.addAll([
      'hyprland',
      'hyprcursor',
      'hyprlock',
      'hyprpaper',
      'waybar',
      'swaync',
      'lxqt-polkit-agent',
      'hyprlauncher',
    ]);
  } else {
    pkgs.add('cage');
  }
  if (c.loginMethod == 'greetd') {
    pkgs.addAll(['greetd', 'greetd-tuigreeter']);
  }
  return pkgs;
}

Future<String?> latestReleaseAssetUrl(String repo, String assetName) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
    );
    request.headers.set('User-Agent', 'parch');
    request.headers.set('Accept', 'application/vnd.github+json');
    final response = await request.close();
    if (response.statusCode != 200) return null;
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset['name'] == assetName) {
        return asset['browser_download_url'] as String?;
      }
    }
  } catch (_) {
  } finally {
    client.close();
  }
  return null;
}

Future<void> phaseLive(AppConfig c, String configPath) async {
  section('Console setup');
  await sh('setfont ${c.consoleFont}');
  await sh('loadkeys ${c.keymap}');
  await sh('ping -c1 archlinux.org', check: false);

  section(
    'Partitioning (automatic - GPT on ${c.rootDisk}: EFI ${c.efiSize} + '
    'root with the rest of the disk)',
  );
  final proceed = askBool(
    'This will WIPE ALL PARTITIONS on ${c.rootDisk} and create '
    '${c.bootPart} (EFI, ${c.efiSize}) + ${c.rootPart} (root). Continue?',
    fallback: true,
  );
  if (!proceed) {
    stderr.writeln('Aborted before touching the disk.');
    exit(1);
  }
  await sh('sgdisk --zap-all ${c.rootDisk}');
  await sh('sgdisk -n1:0:+${c.efiSize} -t1:ef00 -c1:EFI ${c.rootDisk}');
  await sh('sgdisk -n2:0:0 -t2:8300 -c2:root ${c.rootDisk}');
  await sh('partprobe ${c.rootDisk}', check: false);

  if (c.encryptionEnabled && c.useUsbKeyfile) {
    final proceedUsb = askBool(
      'This will WIPE ALL PARTITIONS on ${c.usbDisk} and create '
      '${c.usbPart} for the keyfile. Continue?',
      fallback: false,
    );
    if (!proceedUsb) {
      stderr.writeln('Aborted before touching the USB disk.');
      exit(1);
    }
    await sh('sgdisk --zap-all ${c.usbDisk}');
    await sh('sgdisk -n1:0:0 -t1:0700 -c1:KEYUSB ${c.usbDisk}');
    await sh('partprobe ${c.usbDisk}', check: false);
  }

  section('Filesystems${c.encryptionEnabled ? " + LUKS2" : ""}');
  await sh('mkfs.fat -F32 ${c.bootPart}');

  String rootMapped;
  if (c.encryptionEnabled) {
    await sh('cryptsetup luksFormat --type luks2 ${c.rootPart}');
    await sh('cryptsetup open ${c.rootPart} ${c.mapperName}');
    rootMapped = '/dev/mapper/${c.mapperName}';
  } else {
    rootMapped = c.rootPart;
  }
  await sh('mkfs.ext4 $rootMapped');
  await sh('mount $rootMapped /mnt');
  await sh('mount -m ${c.bootPart} /mnt/boot');

  if (c.encryptionEnabled && c.useUsbKeyfile) {
    section('LUKS2 keyfile on USB');
    await sh('mkfs.fat -F32 ${c.usbPart}');
    await sh('mount -m ${c.usbPart} /mnt/keyusb');
    await sh(
      'dd if=/dev/urandom of=/mnt/keyusb/${c.keyfileName} '
      'bs=4096 count=1',
    );
    await sh('chmod 000 /mnt/keyusb/${c.keyfileName}');
    await sh(
      'cryptsetup luksAddKey ${c.rootPart} '
      '/mnt/keyusb/${c.keyfileName}',
    );
    await sh('umount /mnt/keyusb');
  }

  section('Base install');
  await sh('pacstrap -K /mnt ${c.basePackages.join(' ')} base-devel');
  await sh('genfstab -U /mnt >> /mnt/etc/fstab');

  await carryForward(configPath, '/mnt/root');

  stdout.writeln(
    '\nDone. Now:\n'
    '  arch-chroot /mnt\n'
    '  ./parch chroot',
  );
}

Future<void> phaseChroot(AppConfig c, String configPath) async {
  section('Time + locale');
  await sh('ln -sf /usr/share/zoneinfo/${c.timezone} /etc/localtime');
  await sh('hwclock --systohc');
  await sh("sed -i 's/^#${c.locale}/${c.locale}/' /etc/locale.gen");
  await sh('locale-gen');
  await sh("echo 'LANG=${c.locale}' > /etc/locale.conf");
  await sh("echo 'KEYMAP=${c.keymap}' > /etc/vconsole.conf");
  await sh('echo "${c.hostname}" > /etc/hostname');

  section('Users');
  stdout.writeln('Set the root password:');
  await sh('passwd');
  await sh('useradd -m -G wheel ${c.username}');
  stdout.writeln('Set password for ${c.username}:');
  await sh('passwd ${c.username}');

  final sudoLine = c.nopasswdSudo
      ? '${c.username} ALL=(ALL:ALL) NOPASSWD: ALL'
      : '${c.username} ALL=(ALL:ALL) ALL';
  await sh("echo '$sudoLine' > /etc/sudoers.d/${c.username}");
  await sh('chmod 440 /etc/sudoers.d/${c.username}');
  await sh('visudo -c');

  section('mkinitcpio');
  await sh("sed -i 's/^MODULES=.*/MODULES=(vfat fat)/' /etc/mkinitcpio.conf");
  final hooks = c.encryptionEnabled
      ? 'base systemd autodetect microcode modconf kms keyboard '
            'sd-vconsole block sd-encrypt filesystems fsck'
      : 'base systemd autodetect microcode modconf kms keyboard '
            'sd-vconsole block filesystems fsck';
  await sh("sed -i 's/^HOOKS=.*/HOOKS=($hooks)/' /etc/mkinitcpio.conf");

  section('Packages (official repo, including session/login extras)');
  final pkgs = {...c.officialPackages, ...sessionPackages(c)}.toList();
  await sh('pacman -Sy --noconfirm --needed ${pkgs.join(' ')}');

  section('Login / session setup');
  if (c.loginMethod == 'greetd') {
    await sh('mkdir -p /etc/greetd');
    await File('/etc/greetd/config.toml').writeAsString(
      '[terminal]\n'
      'vt = 1\n\n'
      '[default_session]\n'
      'command = "tuigreeter --cmd \'${sessionCommand(c)}\'"\n'
      'user = "greeter"\n',
    );
    await sh('systemctl enable greetd');
  } else if (c.autostartOnTty) {
    final home = '/home/${c.username}';
    await sh('mkdir -p $home');
    final snippet =
        '\nif [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; '
        'then\n  exec ${sessionCommand(c)}\nfi\n';
    await File('$home/.zprofile').writeAsString(snippet, mode: FileMode.append);
    await sh('chown ${c.username}:${c.username} $home/.zprofile');
  }

  section('Bootloader');
  await sh('bootctl install');

  final rootUuid = await capture('blkid -s UUID -o value ${c.rootPart}');
  String? usbUuid;
  if (c.encryptionEnabled && c.useUsbKeyfile) {
    usbUuid = await capture('blkid -s UUID -o value ${c.usbPart}');
  }
  if (rootUuid.isEmpty) {
    stderr.writeln(
      '!! Could not resolve the root partition UUID via '
      'blkid - fix the loader entry manually before rebooting.',
    );
  }

  String options;
  if (!c.encryptionEnabled) {
    options = 'root=UUID=$rootUuid rw quiet';
  } else if (c.useUsbKeyfile) {
    options =
        'rd.luks.name=$rootUuid=${c.mapperName} '
        'rd.luks.key=$rootUuid=/${c.keyfileName}:UUID=$usbUuid '
        'rd.luks.options=$rootUuid=keyfile-timeout=10s '
        'root=/dev/mapper/${c.mapperName} rw quiet';
  } else {
    options =
        'rd.luks.name=$rootUuid=${c.mapperName} '
        'root=/dev/mapper/${c.mapperName} rw quiet';
  }

  await File('/boot/loader/loader.conf').writeAsString(
    'default arch.conf\ntimeout 4\nconsole-mode max\neditor no\n',
  );
  await File('/boot/loader/entries/arch.conf').writeAsString(
    'title   Arch\n'
    'linux   /vmlinuz-linux\n'
    'initrd  /intel-ucode.img\n'
    'initrd  /initramfs-linux.img\n'
    'options $options\n',
  );
  stdout.writeln('\nWrote /boot/loader/entries/arch.conf with:\n$options');

  await sh('mkinitcpio -P');
  await sh('systemctl enable NetworkManager');

  await carryForward(configPath, '/home/${c.username}');
  await sh(
    'chown ${c.username}:${c.username} /home/${c.username}/parch '
    '/home/${c.username}/parch_config.json',
    check: false,
  );

  stdout.writeln(
    '\nDone. Now: exit, umount -R /mnt'
    '${c.encryptionEnabled ? ", cryptsetup close ${c.mapperName}" : ""}, '
    'reboot. After reboot, log in as ${c.username} and run:\n'
    '  ./parch post',
  );
}

Future<void> phasePostReboot(AppConfig c, String configPath) async {
  section('AUR helper (yay)');
  await sh('sudo pacman -S --needed --noconfirm base-devel git');
  await sh(
    'mkdir -p ~/git && cd ~/git && '
    '(test -d yay-bin || git clone https://aur.archlinux.org/yay-bin) && '
    'cd yay-bin && makepkg -si --noconfirm',
  );
  if (c.aurPackages.isNotEmpty) {
    await sh('yay -S --noconfirm ${c.aurPackages.join(' ')}');
  }

  if (c.officialPackages.contains('mpd')) {
    section('MPD');
    await sh('mkdir -p ~/.config/mpd/playlists ~/Music', check: false);
    await sh('systemctl --user enable --now mpd.service', check: false);
  }

  section('git config');
  await sh(
    'git config --global alias.lg "log --graph --pretty=format:'
    "'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) "
    "%C(bold blue)<%an>%Creset' --abbrev-commit --all\"",
  );
  await sh('git config --global user.name "${c.gitName}"');
  await sh('git config --global user.email "${c.gitEmail}"');
  await sh('git config --global init.defaultBranch main');

  section('GitHub CLI auth');
  await sh('gh auth login');
  await sh('gh auth setup-git');

  if (c.installDotfiles) {
    section('Dotfiles');
    final repoName = c.dotfilesRepoUrl.split('/').last;
    await sh(
      'mkdir -p ~/git && cd ~/git && '
      '(test -d $repoName || git clone ${c.dotfilesRepoUrl})',
    );
    await sh(
      'mkdir -p ~/.config && cp -r ~/git/$repoName/${c.dotfilesPath}/* '
      '~/.config/',
    );
    await sh('mv ~/.config/zsh/.zshrc ~/ 2>/dev/null || true');
    if (c.username != 'psdk') {
      await sh(
        'grep -rIl "/home/psdk" ~/.config ~/.zshrc 2>/dev/null | '
        'xargs -r sed -i "s#/home/psdk#/home/${c.username}#g"',
        check: false,
      );
    }
  }

  if (c.installCustomTools) {
    section('Custom installers');
    await sh('mkdir -p ~/Downloads');
    for (final entry in c.customTools.entries) {
      final name = entry.key;
      final repo = entry.value['repo']!;
      final asset = entry.value['asset']!;
      final url = await latestReleaseAssetUrl(repo, asset);
      if (url == null) {
        stderr.writeln(
          '!! Could not find asset "$asset" in the latest release of '
          '$repo - skipping $name.',
        );
        continue;
      }
      await sh(
        'cd ~/Downloads && aria2c -x16 -s16 "$url" -o "$name-installer" && '
        'chmod +x "./$name-installer" && "./$name-installer" && '
        'rm "./$name-installer"',
      );
    }
  }

  if (c.installFlutter) {
    section('Flutter');
    final flutterFile = c.flutterUrl.split('/').last;
    await sh(
      'cd ~/Downloads && wget ${c.flutterUrl} && '
      '7z x $flutterFile && mkdir -p ~/dev && mv flutter ~/dev/ && '
      'rm $flutterFile',
    );
    await sh(
      'cd ~/git && '
      '(test -d flutter-tmpl || git clone ${c.flutterTemplateRepo}) && '
      'rm -rf ~/dev/flutter/packages/flutter_tools/templates/app '
      '~/dev/flutter/packages/flutter_tools/templates/template_manifest.json'
      ' && cp -r flutter-tmpl/* '
      '~/dev/flutter/packages/flutter_tools/templates/',
    );

    if (c.androidComponents.isNotEmpty) {
      section('Android SDK components');
      for (final comp in c.androidComponents) {
        await sh('asd $comp');
      }
    }
  }

  stdout.writeln('\nAll done.');
}
