import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum LogLevel { debug, info, warning, error }

LogLevel _levelFromString(String s) {
  switch (s.toLowerCase()) {
    case 'debug':
      return LogLevel.debug;
    case 'warning':
      return LogLevel.warning;
    case 'error':
      return LogLevel.error;
    default:
      return LogLevel.info;
  }
}

class LogEntry {
  LogEntry({required this.time, required this.level, required this.message});

  final DateTime time;
  final LogLevel level;
  final String message;
}

/// Подключается к mihomo `/logs` (WebSocket) и копит последние записи
/// в кольцевом буфере — та же живая лента, что и в макете, только
/// вместо демо-данных — реальный вывод ядра.
class LogsController extends ChangeNotifier {
  LogsController({
    required this.host,
    required this.port,
    required this.secret,
    this.maxEntries = 500,
  });

  final String host;
  final int port;
  final String secret;
  final int maxEntries;

  final List<LogEntry> entries = [];
  LogLevel minLevel = LogLevel.debug;
  bool paused = false;
  bool connected = false;
  String? error;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  List<LogEntry> get filtered =>
      entries.where((e) => e.level.index >= minLevel.index).toList();

  Future<void> connect() async {
    disconnect(); // на случай повторного вызова — не плодим подключения
    try {
      final uri = Uri.parse('ws://$host:$port/logs?level=debug');
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $secret'},
      );
      connected = true;
      error = null;
      notifyListeners();

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          connected = false;
          error = e.toString();
          notifyListeners();
        },
        onDone: () {
          connected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      connected = false;
      error = e.toString();
      notifyListeners();
    }
  }

  void _onMessage(dynamic raw) {
    if (paused) return;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final entry = LogEntry(
        time: DateTime.now(),
        level: _levelFromString(json['type'] as String? ?? 'info'),
        message: json['payload'] as String? ?? raw,
      );
      entries.add(entry);
      if (entries.length > maxEntries) {
        entries.removeRange(0, entries.length - maxEntries);
      }
      notifyListeners();
    } catch (_) {
      // Пропускаем строки, которые не смогли разобрать как JSON
    }
  }

  void togglePause() {
    paused = !paused;
    notifyListeners();
  }

  void clear() {
    entries.clear();
    notifyListeners();
  }

  void setMinLevel(LogLevel level) {
    minLevel = level;
    notifyListeners();
  }

  void disconnect() {
    _sub?.cancel();
    _channel?.sink.close();
    _sub = null;
    _channel = null;
    connected = false;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}