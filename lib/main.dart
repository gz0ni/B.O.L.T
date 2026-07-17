import 'dart:io';
import 'package:path/path.dart' as p;
import 'core/mihomo_service.dart';
import 'theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void _registerShutdownHooks(MihomoService mihomo) {
  ProcessSignal.sigint.watch().listen((_) async {
    await mihomo.stop();
    exit(0);
  });
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