import 'dart:async';
import 'dart:io';

import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rust_api/rust_api.dart';

import 'application.dart';
import 'common/common.dart';
import 'common/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (system.isDesktop) {
      await RustLib.init();
    }
    final version = await system.version;
    final container = await globalState.init(version);
    HttpOverrides.global = FlClashHttpOverrides();
    if (system.isDesktop) {
      await initNotifications();
    }
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText('$e\n\n$s'),
          ),
        ),
      ),
    );
  }
}
