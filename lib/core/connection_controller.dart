import 'package:flutter/foundation.dart';

import 'mihomo_service.dart';
import 'proxy_models.dart';

enum ConnectionStatus { idle, connecting, on, error }

/// Управляет состоянием "подключено/отключено" на верхнем уровне UI.
///
/// ВАЖНО: на этом этапе это НЕ полноценный VPN-тумблер — реальная
/// маршрутизация системного трафика через TUN ещё не реализована
/// (это следующий архитектурный шаг). Сейчас "подключение" означает:
/// проверить, что выбранный сервер жив, и отразить это состояние в UI.
/// Как только появится TUN-режим, метод `connect()` здесь же обрастёт
/// реальным включением туннеля — сам UI/state machine менять не придётся.
class ConnectionController extends ChangeNotifier {
  ConnectionController({required this.mihomo, required this.groupName});

  final MihomoService mihomo;
  final String groupName;

  ConnectionStatus status = ConnectionStatus.idle;
  ProxyNode? selectedNode;
  String? errorMessage;
  DateTime? _connectedAt;

  Duration get elapsed =>
      _connectedAt == null ? Duration.zero : DateTime.now().difference(_connectedAt!);

  Future<void> refreshSelectedNode() async {
    try {
      final snapshot = await mihomo.getSnapshot();
      final group = snapshot.groups[groupName];
      if (group == null) return;
      final node = snapshot.nodes[group.now];
      selectedNode = node;
      notifyListeners();
    } catch (_) {
      // Молча игнорируем — это фоновое обновление, не критичная операция
    }
  }

  Future<void> toggle() async {
    if (status == ConnectionStatus.on || status == ConnectionStatus.connecting) {
      _disconnect();
      return;
    }
    await _connect();
  }

  Future<void> _connect() async {
    status = ConnectionStatus.connecting;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await mihomo.getSnapshot();
      final group = snapshot.groups[groupName];
      final node = group == null ? null : snapshot.nodes[group.now];

      if (node == null) {
        throw StateError('Не выбран ни один сервер');
      }
      if (!node.alive) {
        throw StateError('Сервер "${node.name}" сейчас недоступен');
      }

      // TODO(tun): здесь будет реальное включение TUN-туннеля.
      // Пока просто фиксируем состояние на основе проверки живости ноды.
      await Future.delayed(const Duration(milliseconds: 500));

      selectedNode = node;
      status = ConnectionStatus.on;
      _connectedAt = DateTime.now();
    } catch (e) {
      status = ConnectionStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  void _disconnect() {
    status = ConnectionStatus.idle;
    _connectedAt = null;
    notifyListeners();
  }
}