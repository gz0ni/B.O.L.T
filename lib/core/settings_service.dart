import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'mihomo_service.dart';

enum RoutingMode { rule, global, direct }

enum TunStack { gvisor, system, mixed }

enum AppThemeMode { dark, light, auto }

class AppSettings {
  AppSettings({
    this.routingMode = RoutingMode.rule,
    this.tunEnabled = false, // выключено по умолчанию — реальный TUN ещё не готов, включать осознанно
    this.tunStack = TunStack.gvisor,
    this.strictRoute = true,
    this.allowLan = false,
    this.ipv6 = false,
    this.sniffer = true,
    this.dnsMode = 'fake-ip',
    this.autoConnectOnStart = false,
    this.killSwitch = false, // пока не реализовано функционально, см. комментарий в SettingsScreen
    this.tcpConcurrent = true,
    this.mtu = 1500,
    this.autostartWithSystem = false,
    this.notifications = true, // пока не реализовано функционально
    this.themeMode = AppThemeMode.dark,
  });

  RoutingMode routingMode;
  bool tunEnabled;
  TunStack tunStack;
  bool strictRoute;
  bool allowLan;
  bool ipv6;
  bool sniffer;
  String dnsMode;
  bool autoConnectOnStart;
  bool killSwitch;
  bool tcpConcurrent;
  int mtu;
  bool autostartWithSystem;
  bool notifications;
  AppThemeMode themeMode;

  Map<String, dynamic> toJson() => {
        'routingMode': routingMode.name,
        'tunEnabled': tunEnabled,
        'tunStack': tunStack.name,
        'strictRoute': strictRoute,
        'allowLan': allowLan,
        'ipv6': ipv6,
        'sniffer': sniffer,
        'dnsMode': dnsMode,
        'autoConnectOnStart': autoConnectOnStart,
        'killSwitch': killSwitch,
        'tcpConcurrent': tcpConcurrent,
        'mtu': mtu,
        'autostartWithSystem': autostartWithSystem,
        'notifications': notifications,
        'themeMode': themeMode.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        routingMode: RoutingMode.values.byName(json['routingMode'] as String? ?? 'rule'),
        tunEnabled: json['tunEnabled'] as bool? ?? false,
        tunStack: TunStack.values.byName(json['tunStack'] as String? ?? 'gvisor'),
        strictRoute: json['strictRoute'] as bool? ?? true,
        allowLan: json['allowLan'] as bool? ?? false,
        ipv6: json['ipv6'] as bool? ?? false,
        sniffer: json['sniffer'] as bool? ?? true,
        dnsMode: json['dnsMode'] as String? ?? 'fake-ip',
        autoConnectOnStart: json['autoConnectOnStart'] as bool? ?? false,
        killSwitch: json['killSwitch'] as bool? ?? false,
        tcpConcurrent: json['tcpConcurrent'] as bool? ?? true,
        mtu: json['mtu'] as int? ?? 1500,
        autostartWithSystem: json['autostartWithSystem'] as bool? ?? false,
        notifications: json['notifications'] as bool? ?? true,
        themeMode: AppThemeMode.values.byName(json['themeMode'] as String? ?? 'dark'),
      );
}

/// Хранит настройки, применяет часть из них к живому конфигу mihomo
/// (через yaml_edit + горячую перезагрузку — тот же приём, что и в
/// SubscriptionsService), плюс автозапуск с системой через реестр Windows.
class SettingsService extends ChangeNotifier {
  SettingsService({
    required this.mihomo,
    required this.configPath,
    required this.storagePath,
    required this.appExecutablePath,
  });

  final MihomoService mihomo;
  final String configPath;
  final String storagePath; // settings.json
  final String appExecutablePath; // для прописывания в реестр автозапуска

  AppSettings settings = AppSettings();

  Future<void> load() async {
    final file = File(storagePath);
    if (await file.exists()) {
      try {
        settings = AppSettings.fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>,
        );
      } catch (_) {
        settings = AppSettings(); // повреждённый файл — откатываемся к дефолтам, не падаем
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await File(storagePath).writeAsString(jsonEncode(settings.toJson()));
  }

  /// Вызывать после любого изменения settings — сохраняет на диск,
  /// применяет то, что реально влияет на mihomo, и оповещает UI.
  Future<void> save({bool applyToCore = true}) async {
    await _persist();
    if (applyToCore) {
      await _applyCoreSettings();
      if (settings.tunEnabled && !mihomo.isElevated) {
        // Обычный reloadConfig() тут не поможет — уже запущенный
        // неэлевейтед процесс физически не может создать TUN-адаптер,
        // нужен полный перезапуск с правами администратора.
        await mihomo.startElevated();
      } else {
        await mihomo.reloadConfig();
      }
    }
    notifyListeners();
  }

  Future<void> _applyCoreSettings() async {
    final file = File(configPath);
    final content = await file.readAsString();
    final editor = YamlEditor(content);
    final doc = loadYaml(content) as YamlMap;

    editor.update(['mode'], settings.routingMode.name);
    editor.update(['allow-lan'], settings.allowLan);
    editor.update(['ipv6'], settings.ipv6);
    editor.update(['tcp-concurrent'], settings.tcpConcurrent);

    // tun: и sniffer: могут отсутствовать в изначальном конфиге —
    // yaml_edit сам создаёт недостающий узел при обновлении по пути.
    if (doc['tun'] == null) {
      editor.update(['tun'], {
        'enable': settings.tunEnabled,
        'stack': settings.tunStack.name,
        'strict-route': settings.strictRoute,
        'mtu': settings.mtu,
      });
    } else {
      editor.update(['tun', 'enable'], settings.tunEnabled);
      editor.update(['tun', 'stack'], settings.tunStack.name);
      editor.update(['tun', 'strict-route'], settings.strictRoute);
      editor.update(['tun', 'mtu'], settings.mtu);
    }

    if (doc['sniffer'] == null) {
      editor.update(['sniffer'], {'enable': settings.sniffer});
    } else {
      editor.update(['sniffer', 'enable'], settings.sniffer);
    }

    editor.update(['dns', 'enhanced-mode'], settings.dnsMode);

    await file.writeAsString(editor.toString());
  }

  /// Автозапуск с системой — реальная запись в HKCU\...\Run, не
  /// требует прав администратора (пользовательский, а не машинный ключ).
  Future<void> setAutostart(bool enabled) async {
    settings.autostartWithSystem = enabled;
    if (!Platform.isWindows) {
      await save(applyToCore: false);
      return;
    }
    try {
      if (enabled) {
        await Process.run('reg', [
          'add',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
          '/v', 'BoltVpn',
          '/t', 'REG_SZ',
          '/d', '"$appExecutablePath"',
          '/f',
        ]);
      } else {
        await Process.run('reg', [
          'delete',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
          '/v', 'BoltVpn',
          '/f',
        ]);
      }
    } catch (_) {
      // Не критично — просто не применилось, значение всё равно сохранено локально
    }
    await save(applyToCore: false);
  }
}