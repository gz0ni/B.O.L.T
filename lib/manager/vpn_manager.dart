import 'package:bolt/common/common.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/action.dart';
import 'package:bolt/providers/state.dart';
import 'package:bolt/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(vpnStateProvider, (prev, next) {
      if (prev != next) {
        showTip(next);
      }
    });
  }

  void showTip(VpnState state) {
    throttler.call(
      FunctionTag.vpnTip,
      () {
        if (!ref.read(isStartProvider) || state == globalState.lastVpnState) {
          return;
        }
        globalState.showNotifier(
          currentAppLocalizations.vpnConfigChangeDetected,
          actionState: MessageActionState(
            actionText: currentAppLocalizations.restart,
            action: () async {
              final setupAction = ref.read(setupActionProvider.notifier);
              await setupAction.handleStop();
              await setupAction.updateStatus(true);
            },
          ),
        );
      },
      duration: const Duration(seconds: 6),
      fire: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
