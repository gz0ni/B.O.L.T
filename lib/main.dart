import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'core/mihomo_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Хранится на уровне файла, а не внутри виджета — должен пережить
/// весь процесс, а не пересоздаваться при перестройке дерева виджетов.
AppLifecycleListener? _appExitListener;

void _registerShutdownHooks(MihomoService mihomo) {
  // Ctrl+C в терминале — поддерживается dart:io только через SIGINT,
  // SIGTERM на Windows не работает (ограничение платформы, не наше).
  ProcessSignal.sigint.watch().listen((_) async {
    await mihomo.stop();
    exit(0);
  });

  // Закрытие окна крестиком / системный запрос на выход.
  // У AppLifecycleListener.onExitRequested есть известные баги именно
  // на Windows (зависания в связке с некоторыми плагинами) — поэтому
  // оборачиваем stop() таймаутом: даже если что-то пойдёт не так,
  // окно всё равно закроется, а не подвиснет в "Не отвечает".
  // Второй уровень защиты — _killOrphans() в MihomoService.start(),
  // который подчистит процесс на следующем запуске, если этот
  // механизм всё же не сработает.
  _appExitListener = AppLifecycleListener(
    onExitRequested: () async {
      try {
        await mihomo.stop().timeout(const Duration(seconds: 2));
      } catch (_) {
        // Не даём зависшей остановке заблокировать закрытие окна
      }
      return ui.AppExitResponse.exit;
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final coreDir = p.join(Directory.current.path, 'assets', 'mihomo');
  final mihomo = MihomoService(
    executablePath: p.join(coreDir, 'mihomo.exe'),
    configPath: p.join(coreDir, 'config.yaml'),
    workingDirectory: coreDir,
  );

  await mihomo.start();
  _registerShutdownHooks(mihomo);

  runApp(MaterialApp(
    theme: AppTheme.dark(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    home: Scaffold(
      body: HomeScreen(mihomo: mihomo),
    ),
  ));
}