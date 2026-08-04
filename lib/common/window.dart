import 'dart:io';

import 'package:bolt/common/common.dart';
import 'package:bolt/models/config.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/state.dart';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class Window {
  static Window? _instance;

  Window._internal();

  factory Window() {
    _instance ??= Window._internal();
    return _instance!;
  }

  static const _desktopMinimumSize = Size(640, 540);
  static const _mobileMinimumSize = Size(360, 640);

  Future<void> init(int version, WindowProps props) async {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      exit(0);
    }
    if (system.isWindows) {
      protocol.register('clash');
      protocol.register('clashmeta');
      protocol.register('flclash');
    }
    await windowManager.ensureInitialized();
    final forceMobileView =
        globalState.container.read(appSettingProvider).forceMobileView;
    final minimumSize =
        forceMobileView ? _mobileMinimumSize : _desktopMinimumSize;
    final WindowOptions windowOptions = WindowOptions(
      size: forceMobileView ? minimumSize : props.size,
      minimumSize: minimumSize,
    );
    if (system.isMacOS) {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await windowManager.setMaximizable(true);
    await _windowPosition(props);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
      await windowManager.setMinimumSize(minimumSize);
    });
  }

  Future<void> _windowPosition(WindowProps props) async {
    if (!system.isMacOS) {
      final left = props.left ?? 0;
      final top = props.top ?? 0;
      final right = left + props.width;
      final bottom = top + props.height;
      if (left == 0 && top == 0) {
        await windowManager.setAlignment(Alignment.center);
      } else {
        final displays = await screenRetriever.getAllDisplays();
        final isPositionValid = displays.any((display) {
          final displayBounds = Rect.fromLTWH(
            display.visiblePosition!.dx,
            display.visiblePosition!.dy,
            display.size.width,
            display.size.height,
          );
          return displayBounds.contains(Offset(left, top)) ||
              displayBounds.contains(Offset(right, bottom));
        });
        if (isPositionValid) {
          await windowManager.setPosition(Offset(left, top));
        }
      }
    }
  }

  Future<void> setMinimumSize(Size size) async {
    await windowManager.setMinimumSize(size);
  }

  Future<void> show() async {
    render?.resume();
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setSkipTaskbar(false);
  }

  Future<bool> get isVisible async {
    final value = await windowManager.isVisible();
    commonPrint.log('window visible check: $value');
    return value;
  }

  Future<void> close() async {
    await windowManager.close();
  }

  void forceExit() {
    exit(0);
  }

  Future<void> hide() async {
    render?.pause();
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }
}

final window = system.isDesktop ? Window() : null;
