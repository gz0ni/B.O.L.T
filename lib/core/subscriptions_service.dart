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
  final String url;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url};

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
      );
}

/// Группы, в которые попадают ноды из подписок — те же самые
/// "🌍 VPN" (ручной выбор) и "⚡️ Fastest" (авто по пингу), что мы
/// уже используем на экранах локаций/подключения.
class SubscriptionsService {
  SubscriptionsService({
    required this.mihomo,
    required this.configPath,
    required this.storagePath,
    this.targetGroups = const ['🌍 VPN', '⚡️ Fastest'],
  });

  final MihomoService mihomo;
  final String configPath;
  final String storagePath; // путь к subscriptions.json
  final List<String> targetGroups;

  /// Разделитель между именем подписки и именем ноды внутри неё —
  /// по нему же находим и удаляем старые ноды при обновлении подписки.
  static const _sep = ' | ';

  Future<List<Subscription>> loadSubscriptions() async {
    final file = File(storagePath);
    if (!await file.exists()) return [];
    final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
    return raw
        .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveSubscriptions(List<Subscription> subs) async {
    final file = File(storagePath);
    await file.writeAsString(
      jsonEncode(subs.map((s) => s.toJson()).toList()),
    );
  }

  /// Добавляет (или обновляет, если имя уже существует) подписку:
  /// скачивает, парсит, вписывает ноды в config.yaml и перезагружает
  /// живое ядро — всё за один вызов.
  Future<int> addOrRefresh({required String name, required String url}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('Подписка вернула ${response.statusCode}');
    }

    final nodes = ProxyLinkParser.parseSubscriptionBody(response.body);
    if (nodes.isEmpty) {
      throw StateError('Не удалось разобрать ни одной ссылки из подписки');
    }

    // Префиксуем имена нод именем подписки — так на экране локаций
    // видно, откуда сервер, и мы можем безопасно найти/заменить
    // именно эти ноды при следующем обновлении, не трогая остальные.
    for (final node in nodes) {
      node['name'] = '$name$_sep${node['name']}';
    }

    await _applyToConfig(subscriptionName: name, nodes: nodes);
    await mihomo.reloadConfig();

    final subs = await loadSubscriptions();
    final existingIndex = subs.indexWhere((s) => s.name == name);
    final entry = Subscription(
      id: existingIndex >= 0 ? subs[existingIndex].id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
    );
    if (existingIndex >= 0) {
      subs[existingIndex] = entry;
    } else {
      subs.add(entry);
    }
    await _saveSubscriptions(subs);

    return nodes.length;
  }

  Future<void> remove(Subscription subscription) async {
    await _applyToConfig(subscriptionName: subscription.name, nodes: []);
    await mihomo.reloadConfig();

    final subs = await loadSubscriptions();
    subs.removeWhere((s) => s.id == subscription.id);
    await _saveSubscriptions(subs);
  }

  /// Точечная правка config.yaml через yaml_edit — сохраняет всё
  /// остальное содержимое файла (dns, rules и т.п.) нетронутым.
  /// `nodes: []` используется для удаления всех нод подписки (refresh/remove).
  Future<void> _applyToConfig({
    required String subscriptionName,
    required List<Map<String, dynamic>> nodes,
  }) async {
    final file = File(configPath);
    final content = await file.readAsString();
    final editor = YamlEditor(content);
    final doc = loadYaml(content) as YamlMap;

    // 1. Секция proxies: — убираем старые ноды этой подписки, добавляем новые
    final existingProxies = (doc['proxies'] as YamlList?) ?? YamlList();
    final prefix = '$subscriptionName$_sep';
    final keptProxies = existingProxies
        .cast<dynamic>()
        .where((p) => !((p as Map)['name'] as String).startsWith(prefix))
        .toList();
    final newProxiesList = [...keptProxies, ...nodes];
    editor.update(['proxies'], newProxiesList);

    // 2. Секции proxy-groups: — обновляем список имён внутри целевых групп
    final groups = doc['proxy-groups'] as YamlList;
    final newNames = nodes.map((n) => n['name'] as String).toList();

    for (final groupName in targetGroups) {
      final index = groups.toList().indexWhere(
            (g) => (g as Map)['name'] == groupName,
          );
      if (index == -1) continue;

      final group = groups[index] as YamlMap;
      final existingMembers = (group['proxies'] as YamlList?) ?? YamlList();
      final keptMembers = existingMembers
          .cast<dynamic>()
          .where((name) => !(name as String).startsWith(prefix))
          .toList();

      editor.update(
        ['proxy-groups', index, 'proxies'],
        [...keptMembers, ...newNames],
      );
    }

    await file.writeAsString(editor.toString());
  }
}