import 'dart:io';

import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:win_toast/win_toast.dart';

const _aumId = 'B.O.L.T';
const _clsid = '8F2A2B4C-6D3E-4F5A-9B1C-2D3E4F5A6B7C';
bool _initialized = false;

bool get _isWindowsToastSupported => !kIsWeb && Platform.isWindows;

Future<void> initNotifications() async {
  if (!_isWindowsToastSupported || _initialized) return;
  _initialized = true;
  try {
    await WinToast.instance().initialize(
      aumId: _aumId,
      displayName: _aumId,
      iconPath: Platform.resolvedExecutable,
      clsid: _clsid,
    );
  } catch (_) {}
}

Future<void> _showToast(String title, String body) async {
  if (!_isWindowsToastSupported) return;
  try {
    await WinToast.instance().showToast(
      toast: Toast(
        children: [
          ToastChildVisual(
            binding: ToastVisualBinding(
              children: [
                ToastVisualBindingChildText(text: title, id: 1),
                ToastVisualBindingChildText(text: body, id: 2),
              ],
            ),
          ),
        ],
      ),
      group: 'B.O.L.T',
    );
  } catch (_) {}
}

bool _isNotificationsEnabled() {
  try {
    return globalState.container
        .read(appSettingProvider)
        .notifications;
  } catch (_) {
    return false;
  }
}

Future<void> notifySubscriptionUpdated(String label) async {
  if (!_isNotificationsEnabled()) return;
  await _showToast('Подписка обновлена', label);
}

Future<void> notifySubscriptionError(String label, String error) async {
  if (!_isNotificationsEnabled()) return;
  await _showToast('Ошибка обновления подписки', '$label\n$error');
}

Future<void> notifySubscriptionExpiring(String label, int daysLeft) async {
  if (!_isNotificationsEnabled()) return;
  await _showToast('Подписка заканчивается', '$label: осталось $daysLeft дн.');
}
