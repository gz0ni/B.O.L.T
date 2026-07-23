import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'mihomo_service.dart';
import 'proxy_link_parser.dart';

class Subscription {
  const Subscription({required this.id, required this.name, required this.url});

  final String id;
  final String name;
  final String url; // пусто для локальных источников (файл/ключи/полный конфиг)

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url};

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
      );
}

/// Подписка = полностью независимый профиль mihomo, а не набор нод,
/// подмешанный в общий конфиг. Переключение между подписками означает
/// "загрузить именно этот файл целиком" (PUT /configs), поэтому у
/// каждой подписки могут быть свои proxy-groups и даже свои rules,
/// если она сама их прислала — общий конфиг при этом не трогается.
class SubscriptionsService {
  SubscriptionsService({
    required this.mihomo,
    required this.baseConfigPath, // ваш рукописный config.yaml — всегда доступен как профиль "по умолчанию"
    required this.profilesDir,
    required this.storagePath,
    this.targetGroups = const ['🌍 VPN', '⚡️ Fastest'],
  });

  final MihomoService mihomo;
  final String baseConfigPath;
  final String profilesDir;
  final String storagePath; // subscriptions.json
  final List<String> targetGroups;

  String _profilePath(String id) => '$profilesDir${Platform.pathSeparator}$id.yaml';
  String get _activeMarkerPath => '$profilesDir${Platform.pathSeparator}.active';

  Future<List<Subscription>> loadSubscriptions() async {
    final file = File(storagePath);
    if (!await file.exists()) return [];
    final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
    return raw.map((e) => Subscription.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveSubscriptions(List<Subscription> subs) async {
    await File(storagePath).writeAsString(jsonEncode(subs.map((s) => s.toJson()).toList()));
  }

  /// null означает "активен базовый config.yaml", а не подписка.
  Future<String?> loadActiveId() async {
    final file = File(_activeMarkerPath);
    if (!await file.exists()) return null;
    final content = (await file.readAsString()).trim();
    return content.isEmpty ? null : content;
  }

  Future<void> _saveActiveId(String? id) async {
    await Directory(profilesDir).create(recursive: true);
    await File(_activeMarkerPath).writeAsString(id ?? '');
  }

  /// Активирует профиль — полностью заменяет запущенный конфиг mihomo.
  /// `null` — вернуться на базовый config.yaml.
  Future<void> activate(String? subscriptionId) async {
    final path = subscriptionId == null ? baseConfigPath : _profilePath(subscriptionId);
    await mihomo.loadConfigFromFile(path);
    await _saveActiveId(subscriptionId);
  }

  List<Map<String, dynamic>> parseRawLinks(String text) => ProxyLinkParser.parseSubscriptionBody(text);

  /// Полный ли это конфиг (со своими rules/группами) или просто список
  /// ссылок/base64 — от этого зависит, сохраняем ли как есть или
  /// собираем профиль на основе базового шаблона.
  bool _looksLikeFullConfig(String text) {
    try {
      final doc = loadYaml(text);
      return doc is YamlMap && (doc.containsKey('rules') || doc.containsKey('proxy-groups'));
    } catch (_) {
      return false;
    }
  }

  /// Собирает полноценный профиль из списка нод на основе базового
  /// config.yaml как шаблона: те же порты/dns/rules/settings, но
  /// собственный набор proxies и переопределённые группы.
  Future<String> _materializeFromNodes(List<Map<String, dynamic>> nodes, String subName) async {
    final baseContent = await File(baseConfigPath).readAsString();
    final base = loadYaml(baseContent) as YamlMap;
    final editor = YamlEditor(baseContent);

    editor.update(['proxies'], nodes);

    final groups = base['proxy-groups'] as YamlList;
    final names = nodes.map((n) => n['name']).toList();
    for (final groupName in targetGroups) {
      final idx = groups.toList().indexWhere((g) => (g as Map)['name'] == groupName);
      if (idx == -1) continue;
      editor.update(['proxy-groups', idx, 'proxies'], names);
      final group = groups[idx] as YamlMap;
      if (group.containsKey('use')) editor.remove(['proxy-groups', idx, 'use']);
    }
    return editor.toString();
  }

  Future<void> addFromUrl({required String name, required String url, String? existingId}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw StateError('Подписка вернула ${response.statusCode}');
    await _addFromRawText(name: name, url: url, rawText: response.body, existingId: existingId);
  }

  Future<void> addFromRawText({
    required String name,
    required String rawText,
    String? existingId,
  }) =>
      _addFromRawText(name: name, url: '', rawText: rawText, existingId: existingId);

  Future<void> addFromNodes({
    required String name,
    required List<Map<String, dynamic>> nodes,
    String? existingId,
  }) async {
    if (nodes.isEmpty) throw StateError('Список пуст — нечего добавлять');
    final id = existingId ?? 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final content = await _materializeFromNodes(nodes, name);
    await Directory(profilesDir).create(recursive: true);
    await File(_profilePath(id)).writeAsString(content);
    await _persistEntry(id: id, name: name, url: '');
  }

  Future<void> _addFromRawText({
    required String name,
    required String url,
    required String rawText,
    String? existingId,
  }) async {
    final id = existingId ?? 'sub_${DateTime.now().millisecondsSinceEpoch}';
    String content;
    if (_looksLikeFullConfig(rawText)) {
      // Подписка прислала готовый конфиг со своими rules/группами —
      // сохраняем как есть, ничего не подставляем.
      content = rawText;
    } else {
      final nodes = ProxyLinkParser.parseSubscriptionBody(rawText);
      if (nodes.isEmpty) throw StateError('Не удалось разобрать содержимое подписки');
      content = await _materializeFromNodes(nodes, name);
    }
    await Directory(profilesDir).create(recursive: true);
    await File(_profilePath(id)).writeAsString(content);
    await _persistEntry(id: id, name: name, url: url);
  }

  Future<void> _persistEntry({required String id, required String name, required String url}) async {
    final subs = await loadSubscriptions();
    final idx = subs.indexWhere((s) => s.id == id);
    final entry = Subscription(id: id, name: name, url: url);
    if (idx >= 0) {
      subs[idx] = entry;
    } else {
      subs.add(entry);
    }
    await _saveSubscriptions(subs);
  }

  Future<void> remove(Subscription subscription) async {
    final file = File(_profilePath(subscription.id));
    if (await file.exists()) await file.delete();

    final activeId = await loadActiveId();
    if (activeId == subscription.id) {
      await activate(null); // удалили активную — откатываемся на базовый конфиг
    }

    final subs = await loadSubscriptions();
    subs.removeWhere((s) => s.id == subscription.id);
    await _saveSubscriptions(subs);
  }

  /// Открывает файл профиля в системном редакторе — "Открыть YAML"
  /// из макета. `null` — открыть базовый config.yaml.
  Future<void> openProfileFile(Subscription? subscription) async {
    final path = subscription == null ? baseConfigPath : _profilePath(subscription.id);
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', '', path], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [path]);
    } else if (Platform.isLinux) {
      await Process.start('xdg-open', [path]);
    }
  }
}