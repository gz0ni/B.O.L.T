import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

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
    this.controllerPort = 19090,
    this.secret = 'test-secret-123',
  });

  final String executablePath;
  final String configPath;
  final String workingDirectory;
  final String controllerHost;
  final int controllerPort;
  final String secret;

  Process? _process;
  bool _elevated = false;
  final Map<String, String> _lastSelection = {}; // group -> nodeName, переживает рестарты в рамках сессии

  /// true, если mihomo сейчас запущен через UAC-elevation (для TUN).
  /// В этом режиме у нас нет прямого Process-хендла — процесс живёт
  /// вне дерева процессов нашего приложения.
  bool get isElevated => _elevated;

  Uri _uri(String path) =>
      Uri.parse('http://$controllerHost:$controllerPort$path');

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $secret',
      };

  /// Убивает ранее осиротевшие процессы mihomo, запущенные именно из
  /// нашей рабочей папки (сравнение по полному пути exe) — не трогает
  /// другие процессы с тем же именем, если они запущены откуда-то ещё
  /// (например, отдельный личный VPN-клиент пользователя на mihomo).
  Future<void> _killOrphans() async {
    if (!Platform.isWindows) return; // пока актуально только для Windows-сборки
    try {
      final normalizedPath = executablePath.replaceAll('/', '\\');
      await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        "Get-CimInstance Win32_Process -Filter \"Name='mihomo.exe'\" | "
            "Where-Object { \$_.ExecutablePath -eq '$normalizedPath' } | "
            "ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }",
      ]);
    } catch (_) {
      // Не критично, если зачистка не удалась — просто попробуем стартовать как есть
    }
  }

  static const _helperPort = 47891;

  Future<bool> _pingHelper() async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:$_helperPort/ping'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Останавливает обычный процесс и просит постоянный Windows-сервис
  /// (bolt_helper, зарегистрированный через sc.exe create) запустить
  /// mihomo от имени SYSTEM. В отличие от Start-Process -Verb RunAs,
  /// UAC здесь не всплывает вообще — сервис уже работает с правами,
  /// установленными один раз при установке приложения.
  Future<void> startElevated() async {
    if (_elevated) return;
    if (!Platform.isWindows) {
      throw UnsupportedError('Elevated-запуск реализован пока только для Windows');
    }

    final helperAlive = await _pingHelper();
    if (!helperAlive) {
      throw StateError(
        'Служба BoltVpnHelperService не отвечает на 127.0.0.1:$_helperPort. '
        'Проверьте, что она установлена и запущена '
        '(sc.exe query BoltVpnHelperService).',
      );
    }

    await stop();
    await _killOrphans();

    final response = await http
        .post(
          Uri.parse('http://127.0.0.1:$_helperPort/start'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'path': executablePath,
            'args': ['-d', workingDirectory, '-f', configPath],
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200 || response.body.isNotEmpty) {
      throw StateError('Хелпер отказался запускать mihomo: ${response.body}');
    }

    _elevated = true;
    await _waitUntilReady(timeout: const Duration(seconds: 10));
    await _reapplySelections();
  }

  /// Проверяет config.yaml на диске — если там сохранено tun.enable:true
  /// (например, с прошлого запуска), нужно сразу стартовать elevated,
  /// а не обычным способом с гарантированной ошибкой Access is denied.
  Future<bool> _configHasTunEnabled() async {
    try {
      final content = await File(configPath).readAsString();
      final doc = loadYaml(content);
      if (doc is! Map) return false;
      final tun = doc['tun'];
      if (tun is! Map) return false;
      return tun['enable'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Запускает mihomo, сам выбирая обычный или elevated-режим —
  /// смотрит на то, что реально сохранено в config.yaml.
  Future<void> startAuto() async {
    if (await _configHasTunEnabled()) {
      await startElevated();
    } else {
      await start();
    }
  }

  /// Запускает mihomo как отдельный процесс.
  Future<void> start() async {
    if (_process != null) {
      throw StateError('mihomo уже запущен');
    }

    await _killOrphans();

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
    await _reapplySelections();
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
    _lastSelection[group] = nodeName;
  }

  /// Переприменяет все ранее сделанные вручную выборы локаций —
  /// вызывается после любого рестарта/hot-reload mihomo, потому что
  /// полный перезапуск процесса сбрасывает Selector-группы к дефолту
  /// из файла (обычно это первый элемент в списке proxies).
  Future<void> _reapplySelections() async {
    for (final entry in _lastSelection.entries) {
      try {
        await http.put(
          _uri('/proxies/${Uri.encodeComponent(entry.key)}'),
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode({'name': entry.value}),
        );
      } catch (_) {
        // Не критично — просто останется дефолтный выбор в этот раз
      }
    }
  }

  /// Останавливает процесс mihomo (важно вызывать при выходе из приложения —
  /// иначе останется висеть в фоне без UI, тот самый watchdog-риск).
  Future<void> stop() async {
    if (_elevated) {
      // Сервис сам убивает СВОЙ дочерний процесс — тут нет проблемы
      // "неэлевейтед не может убить elevated", потому что запрос идёт
      // просто по HTTP, а убийство делает сам сервис изнутри.
      try {
        await http
            .post(Uri.parse('http://127.0.0.1:$_helperPort/stop'))
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
      _elevated = false;
      return;
    }
    _process?.kill();
    _process = null;
  }

  /// PUT /configs с произвольным путём — полностью заменяет запущенный
  /// конфиг на другой файл (свои proxies, свои group, свои rules).
  /// Используется для переключения между профилями/подписками.
  Future<void> loadConfigFromFile(String path) async {
    final response = await http.put(
      _uri('/configs').replace(queryParameters: {'force': 'true'}),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'path': path, 'payload': ''}),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw StateError(
        'Не удалось загрузить конфиг: ${response.statusCode} ${response.body}',
      );
    }
    await _reapplySelections();
  }

  /// PUT /configs — горячая перезагрузка ТЕКУЩЕГО конфига с диска без
  /// рестарта самого процесса mihomo (например, после ручной правки).
  Future<void> reloadConfig() => loadConfigFromFile(configPath);

  /// GET /group/{name}/delay — штатный health-check mihomo, реально
  /// прогоняет все ноды группы через testUrl и обновляет их задержки.
  Future<void> testGroupDelay(String groupName) async {
    await http.get(
      _uri('/group/${Uri.encodeComponent(groupName)}/delay').replace(
        queryParameters: {
          'url': 'http://www.gstatic.com/generate_204',
          'timeout': '5000',
        },
      ),
      headers: _headers,
    );
  }

  bool get isRunning => _process != null;
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;

  @override
  String toString() => 'TimeoutException: $message';
}