import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'core/logs_controller.dart';
import 'core/mihomo_service.dart';
import 'core/settings_service.dart';
import 'core/subscriptions_service.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

AppLifecycleListener? _appExitListener;

void _registerShutdownHooks(MihomoService mihomo) {
  ProcessSignal.sigint.watch().listen((_) async {
    await mihomo.stop();
    exit(0);
  });

  _appExitListener = AppLifecycleListener(
    onExitRequested: () async {
      try {
        await mihomo.stop().timeout(const Duration(seconds: 2));
      } catch (_) {}
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

  await mihomo.startAuto();
  _registerShutdownHooks(mihomo);

  final subsService = SubscriptionsService(
    mihomo: mihomo,
    baseConfigPath: p.join(coreDir, 'config.yaml'),
    profilesDir: p.join(coreDir, 'profiles'),
    storagePath: p.join(coreDir, 'subscriptions.json'),
  );

  final settingsService = SettingsService(
    mihomo: mihomo,
    configPath: p.join(coreDir, 'config.yaml'),
    storagePath: p.join(coreDir, 'settings.json'),
    appExecutablePath: Platform.resolvedExecutable,
  );
  await settingsService.load();

  final logsController = LogsController(
    host: '127.0.0.1',
    port: 19090,
    secret: 'test-secret-123',
  );

  runApp(
    ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        final mode = switch (settingsService.settings.themeMode) {
          AppThemeMode.dark => ThemeMode.dark,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.auto => ThemeMode.system,
        };
        return MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: AppShell(
            mihomo: mihomo,
            subscriptionsService: subsService,
            settingsService: settingsService,
            logsController: logsController,
          ),
        );
      },
    ),
  );
}