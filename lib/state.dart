import 'dart:async';
import 'dart:io';

import 'package:bolt/common/theme.dart';
import 'package:bolt/theme/app_theme.dart';
import 'package:bolt/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'database/database.dart';
import 'enum/enum.dart';
import 'l10n/l10n.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'widgets/bolt_surfaces.dart';

class GlobalState {
  static GlobalState? _instance;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool isPre = true;
  late final String coreSHA256;
  late final PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  late Measure measure;
  late CommonTheme theme;
  late ProviderContainer container;
  bool needInitStatus = true;

  String? lastConfigMd5;
  VpnState? lastVpnState;
  bool isAttach = false;

  GlobalState._internal();

  factory GlobalState() {
    _instance ??= GlobalState._internal();
    return _instance!;
  }

  Future<ProviderContainer> init(int version) async {
    coreSHA256 = const String.fromEnvironment('CORE_SHA256');
    isPre = const String.fromEnvironment('APP_ENV') != 'stable';
    return _initData(version);
  }

  String get ua => container
      .read(patchClashConfigProvider.select((state) => state.globalUa))
      .takeFirstValid([packageInfo.ua]);

  Future<ProviderContainer> _initData(int version) async {
    final appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLength),
      traffics: FixedList(30),
      totalTraffic: const Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    final appStateOverrides = buildAppStateOverrides(appState);
    packageInfo = await PackageInfo.fromPlatform();
    final configMap = await preferences.getConfigMap();
    final config = await migration.migrationIfNeeded(
      configMap,
      sync: (data) async {
        final newConfigMap = data.configMap;
        final config = Config.realFromJson(newConfigMap);
        await Future.wait([
          database.restore(
            data.profiles,
            data.scripts,
            data.rules,
            data.links,
            data.proxyGroups,
          ),
          preferences.saveConfig(config),
        ]);
        return config;
      },
    );
    final configOverrides = buildConfigOverrides(config);
    container = ProviderContainer(
      overrides: [...appStateOverrides, ...configOverrides],
    );
    final profiles = await database.profilesDao.query().get();
    container.read(profilesProvider.notifier).setAndReorder(profiles);
    await AppLocalizations.load(
      utils.getLocaleForString(config.appSettingProps.locale) ??
          WidgetsBinding.instance.platformDispatcher.locale,
    );
    await window?.init(version, config.windowProps);
    if (system.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    return container;
  }

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return globalState.safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).start();
        }
      },
      onEnd: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).stop();
        }
      },
    );
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    bool silence = true,
  }) async {
    try {
      onStart?.call();
      return await futureFunction();
    } catch (e, s) {
      commonPrint.log('$title ===> $e, $s', logLevel: LogLevel.warning);
      if (silence) {
        showNotifier(e.toString());
      } else {
        showMessage(
          title: title ?? currentAppLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }

  Future<bool?> showMessage({
    required InlineSpan message,
    BuildContext? context,
    String? title,
    String? confirmText,
    String? cancelText,
    bool cancelable = true,
    bool? dismissible,
  }) async {
    final dialogContext = context ?? navigatorKey.currentContext!;
    return showBoltDialog<bool>(
      dialogContext,
      barrierDismissible: dismissible ?? true,
      title: title ?? dialogContext.appLocalizations.tip,
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: SelectableText.rich(
            TextSpan(
              style: Theme.of(dialogContext).textTheme.labelLarge,
              children: [message],
            ),
            style: const TextStyle(overflow: TextOverflow.visible),
          ),
        ),
      ),
      actions: [
        if (cancelable)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(cancelText ?? dialogContext.appLocalizations.cancel),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          child: Text(confirmText ?? dialogContext.appLocalizations.confirm),
        ),
      ],
    );
  }

  Future<bool?> showAllUpdatingMessagesDialog(
    List<UpdatingMessage> messages,
  ) async {
    final dialogContext = navigatorKey.currentContext!;
    final surfaces = dialogContext.surfaces;
    return showBoltDialog<bool>(
      dialogContext,
      title: dialogContext.appLocalizations.tip,
      content: SizedBox(
        width: 300,
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final message = messages[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s2,
                vertical: AppSpace.s2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.label,
                    style: TextStyle(
                      color: surfaces.text1,
                      fontSize: AppFontSize.md,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: surfaces.text2,
                      fontSize: AppFontSize.sm,
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: messages.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          child: Text(dialogContext.appLocalizations.confirm),
        ),
      ],
    );
  }

  void showNotifier(String text, {MessageActionState? actionState}) {
    if (text.isEmpty) {
      return;
    }
    navigatorKey.currentContext?.showNotifier(text, actionState: actionState);
  }

  Future<void> openUrl(String url) async {
    final res = await showMessage(
      message: TextSpan(text: url),
      title: currentAppLocalizations.externalLink,
      confirmText: currentAppLocalizations.go,
    );
    if (res != true) {
      return;
    }
    launchUrl(Uri.parse(url));
  }

  Future<void> attach() async {
    if (isAttach == true) {
      return;
    }
    await _initApp();
    isAttach = true;
  }

  Future<void> _initApp() async {
    FlutterError.onError = (details) {
      Future.microtask(() {
        commonPrint.log(
          'exception: ${details.exception} stack: ${details.stack}',
          logLevel: LogLevel.warning,
        );
      });
    };
    container.read(systemActionProvider.notifier).updateTray();
    container.read(profilesActionProvider.notifier).autoUpdateProfiles();
    container.read(commonActionProvider.notifier).autoCheckUpdate();
    autoLaunch?.updateStatus(container.read(appSettingProvider).autoLaunch);
    if (!container.read(appSettingProvider).silentLaunch) {
      window?.show();
    } else {
      window?.hide();
    }
    await _handleFailedPreference();
    await container.read(coreActionProvider.notifier).connectCore();
    await container.read(coreActionProvider.notifier).initCore();
    await container.read(setupActionProvider.notifier).initStatus();
    container.read(initProvider.notifier).value = true;
    permissions.check();
  }

  Future<void> _handleFailedPreference() async {
    if (await preferences.isInit) return;
    final res = await showMessage(
      title: currentAppLocalizations.tip,
      message: TextSpan(text: currentAppLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    await container.read(systemActionProvider.notifier).handleExit();
  }
}

final globalState = GlobalState();
