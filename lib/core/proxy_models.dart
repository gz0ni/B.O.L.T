/// Отдельная прокси-нода (конечный сервер) — то, что показывается
/// одной строкой в списке локаций.
class ProxyNode {
  const ProxyNode({
    required this.name,
    required this.type,
    required this.alive,
    required this.delayMs,
  });

  final String name;
  final String type; // "Vless" | "Trojan" | "Hysteria2" | "Direct" | ...
  final bool alive;
  final int? delayMs; // null, если ещё не тестировался

  factory ProxyNode.fromJson(Map<String, dynamic> json) {
    return ProxyNode(
      name: json['name'] as String,
      type: json['type'] as String,
      alive: json['alive'] as bool? ?? false,
      delayMs: _latestDelay(json),
    );
  }

  /// mihomo кладёт результаты тестов в `history` (последний тест группы,
  /// к которой нода принадлежит напрямую) — берём самый свежий замер.
  static int? _latestDelay(Map<String, dynamic> json) {
    final history = json['history'] as List<dynamic>?;
    if (history == null || history.isEmpty) return null;
    final last = history.last as Map<String, dynamic>;
    final delay = last['delay'] as int?;
    // delay == 0 в связке с alive:false означает "тест не прошёл",
    // а не "нулевой пинг" — трактуем как недоступность, не как значение.
    if (delay == 0) return null;
    return delay;
  }
}

/// Группа-селектор (то, между чем выбирает пользователь) — например,
/// "🌍 VPN" (ручной выбор) или "⚡️ Fastest" (авто-выбор по пингу).
class ProxyGroup {
  const ProxyGroup({
    required this.name,
    required this.type,
    required this.now,
    required this.memberNames,
  });

  final String name;
  final String type; // "Selector" | "URLTest" | "Fallback" | "LoadBalance"
  final String now; // что выбрано сейчас
  final List<String> memberNames;

  factory ProxyGroup.fromJson(Map<String, dynamic> json) {
    return ProxyGroup(
      name: json['name'] as String,
      type: json['type'] as String,
      now: json['now'] as String? ?? '',
      memberNames: (json['all'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  bool get isSelectable => type == 'Selector';
  bool get isAutoTest => type == 'URLTest';
}

/// Результат разбора всего ответа /proxies — группы и ноды разложены
/// по отдельным мапам, чтобы UI не гадал, что есть что по полю `type`.
class ProxySnapshot {
  const ProxySnapshot({required this.groups, required this.nodes});

  final Map<String, ProxyGroup> groups;
  final Map<String, ProxyNode> nodes;

  static const _groupTypes = {'Selector', 'URLTest', 'Fallback', 'LoadBalance'};

  factory ProxySnapshot.fromJson(Map<String, dynamic> json) {
    final proxies = json['proxies'] as Map<String, dynamic>;
    final groups = <String, ProxyGroup>{};
    final nodes = <String, ProxyNode>{};

    for (final entry in proxies.entries) {
      final value = entry.value as Map<String, dynamic>;
      final type = value['type'] as String;
      if (_groupTypes.contains(type)) {
        groups[entry.key] = ProxyGroup.fromJson(value);
      } else {
        nodes[entry.key] = ProxyNode.fromJson(value);
      }
    }

    return ProxySnapshot(groups: groups, nodes: nodes);
  }

  /// Список нод внутри группы, уже развёрнутый из имён в объекты —
  /// то, что напрямую скармливается в список локаций на экране.
  /// Служебные группы (DIRECT/REJECT/PASS/...) и вложенные группы
  /// (например "⚡️ Fastest" внутри "🌍 VPN") отфильтровываются —
  /// в списке остаются только реальные серверы.
  List<ProxyNode> nodesInGroup(String groupName) {
    final group = groups[groupName];
    if (group == null) return [];
    return group.memberNames
        .map((name) => nodes[name])
        .whereType<ProxyNode>()
        .toList();
  }
}