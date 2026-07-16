import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'proxy_models.dart';

/// Управляет жизненным циклом процесса mihomo и общением с его REST API.
///
/// Это первый сквозной тест архитектуры: Dart спавнит subprocess,
/// ждёт, пока поднимется RESTful API, и стучится в него как в обычный
/// HTTP-сервис. TUN/маршрутизация сюда пока не входят — только core.
class MihomoService {
  MihomoService({
    required this.executablePath,
    required this.configPath,
    required this.workingDirectory,
    this.controllerHost = '127.0.0.1',
    this.controllerPort = 9090,
    this.secret = 'test-secret-123',
  });

  final String executablePath;
  final String configPath;
  final String workingDirectory;
  final String controllerHost;
  final int controllerPort;
  final String secret;

  Process? _process;

  Uri _uri(String path) =>
      Uri.parse('http://$controllerHost:$controllerPort$path');

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $secret',
      };

  /// Запускает mihomo как отдельный процесс.
  Future<void> start() async {
    if (_process != null) {
      throw StateError('mihomo уже запущен');
    }

    _process = await Process.start(
      executablePath,
      ['-d', workingDirectory, '-f', configPath],
      workingDirectory: workingDirectory,
      runInShell: false,
    );

    // Логи ядра пробрасываем в консоль Dart — позже это станет
    // источником данных для экрана логов из макета.
    _process!.stdout.transform(utf8.decoder).listen((line) {
      stdout.write('[mihomo] $line');
    });
    _process!.stderr.transform(utf8.decoder).listen((line) {
      stderr.write('[mihomo:err] $line');
    });

    _process!.exitCode.then((code) {
      stdout.writeln('[mihomo] процесс завершился с кодом $code');
      _process = null;
    });

    // Ждём, пока REST API реально поднимется, прежде чем
    // считать старт успешным — простой поллинг с таймаутом.
    await _waitUntilReady();
  }

  Future<void> _waitUntilReady({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final response = await getVersion();
        if (response != null) return;
      } catch (_) {
        // API ещё не поднялся — пробуем ещё раз
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    throw TimeoutException('mihomo REST API не ответил за $timeout');
  }

  /// GET /version — простейшая проверка, что ядро живо.
  Future<Map<String, dynamic>?> getVersion() async {
    final response = await http.get(_uri('/version'), headers: _headers);
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /proxies — список прокси/групп, пригодится для экрана локаций.
  Future<Map<String, dynamic>> getProxies() async {
    final response = await http.get(_uri('/proxies'), headers: _headers);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// То же самое, но сразу разобранное в удобные для UI модели
  /// (см. proxy_models.dart) — это то, что реально дёргается из экранов.
  Future<ProxySnapshot> getSnapshot() async {
    final raw = await getProxies();
    return ProxySnapshot.fromJson(raw);
  }

  /// PUT /proxies/{group} — переключает выбранный сервер внутри группы.
  /// Работает только для групп типа Selector (ручной выбор) — у
  /// URLTest/Fallback выбор идёт автоматически, дёргать этот метод
  /// для них mihomo просто откажется выполнять.
  Future<void> selectProxy({
    required String group,
    required String nodeName,
  }) async {
    final response = await http.put(
      _uri('/proxies/${Uri.encodeComponent(group)}'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'name': nodeName}),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw StateError(
        'Не удалось переключить прокси: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Останавливает процесс mihomo (важно вызывать при выходе из приложения —
  /// иначе останется висеть в фоне без UI, тот самый watchdog-риск).
  Future<void> stop() async {
    _process?.kill();
    _process = null;
  }

  bool get isRunning => _process != null;
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;

  @override
  String toString() => 'TimeoutException: $message';
}