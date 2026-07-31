import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  void _changeMode(WidgetRef ref, Mode mode) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  void _updatePatchConfig(WidgetRef ref, PatchClashConfig Function(PatchClashConfig) update) {
    ref.read(patchClashConfigProvider.notifier).update(update);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final patchConfig = ref.watch(patchClashConfigProvider);
    final network = ref.watch(networkSettingProvider);
    final appSetting = ref.watch(appSettingProvider);
    final themeProps = ref.watch(themeSettingProvider);

    return Container(
      color: surfaces.bg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s4),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    color: surfaces.text1,
                  ),
                ),
              ),
              if (onClose != null)
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),

          const SettingsSectionLabel('Ядро · mihomo'),
          SettingsRow(
            title: 'Режим маршрутизации',
            trailing: SettingsSegmented<Mode>(
              options: Mode.values,
              value: patchConfig.mode,
              labels: const {
                Mode.rule: 'Правила',
                Mode.global: 'Глобальный',
                Mode.direct: 'Прямой',
              },
              onChanged: (v) => _changeMode(ref, v),
            ),
          ),
          SettingsRow(
            title: 'TUN-режим',
            description:
                'Перехват всего системного трафика через виртуальный адаптер. '
                'При включении ядро запросит права администратора.',
            trailing: SettingsSwitch(
              value: patchConfig.tun.enable,
              onChanged: (v) => _updatePatchConfig(
                ref,
                (state) => state.copyWith.tun(enable: v),
              ),
            ),
          ),
          SettingsRow(
            title: 'Стек TUN',
            trailing: SettingsSegmented<TunStack>(
              options: TunStack.values,
              value: patchConfig.tun.stack,
              labels: const {
                TunStack.gvisor: 'gVisor',
                TunStack.system: 'System',
                TunStack.mixed: 'Mixed',
              },
              onChanged: (v) => _updatePatchConfig(
                ref,
                (state) => state.copyWith.tun(stack: v),
              ),
            ),
          ),
          SettingsRow(
            title: 'Системный прокси',
            description: 'Проксировать системный трафик через mixed-порт ядра',
            trailing: SettingsSwitch(
              value: network.systemProxy,
              onChanged: (v) => ref
                  .read(networkSettingProvider.notifier)
                  .update((state) => state.copyWith(systemProxy: v)),
            ),
          ),
          const SettingsRow(
            title: 'Строгий роут',
            description: 'Strict Route — исключает утечки мимо TUN. '
                'На Windows фиксирован ядром',
            trailing: SettingsSwitch(value: false),
          ),
          SettingsRow(
            title: 'Разрешить LAN',
            trailing: SettingsSwitch(
              value: patchConfig.allowLan,
              onChanged: (v) =>
                  _updatePatchConfig(ref, (state) => state.copyWith(allowLan: v)),
            ),
          ),
          SettingsRow(
            title: 'IPv6',
            trailing: SettingsSwitch(
              value: patchConfig.ipv6,
              onChanged: (v) =>
                  _updatePatchConfig(ref, (state) => state.copyWith(ipv6: v)),
            ),
          ),
          const SettingsRow(
            title: 'Sniffer',
            description: 'Определение домена по TLS SNI / HTTP Host — '
                'управляется профилем',
            trailing: SettingsSwitch(value: false),
          ),

          const SettingsDivider(),
          const SettingsSectionLabel('DNS'),
          SettingsRow(
            title: 'Режим DNS',
            trailing: SettingsSegmented<DnsMode>(
              options: const [DnsMode.fakeIp, DnsMode.redirHost],
              value: patchConfig.dns.enhancedMode,
              labels: const {
                DnsMode.fakeIp: 'Fake IP',
                DnsMode.redirHost: 'Redir Host',
              },
              onChanged: (v) => _updatePatchConfig(
                ref,
                (state) => state.copyWith(
                  dns: state.dns.copyWith(enhancedMode: v),
                ),
              ),
            ),
          ),

          const SettingsDivider(),
          const SettingsSectionLabel('Подключение'),
          SettingsRow(
            title: 'Автоподключение при запуске',
            description: 'Поднимать соединение сразу при старте приложения',
            trailing: SettingsSwitch(
              value: appSetting.autoRun,
              onChanged: (v) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(autoRun: v)),
            ),
          ),
          const SettingsRow(
            title: 'Kill Switch',
            description: 'Блокировать интернет при падении ядра — не реализовано',
            trailing: SettingsSwitch(value: false),
          ),
          SettingsRow(
            title: 'TCP Concurrent',
            description: 'Параллельные попытки подключения для ускорения',
            trailing: SettingsSwitch(
              value: patchConfig.tcpConcurrent,
              onChanged: (v) => _updatePatchConfig(
                ref,
                (state) => state.copyWith(tcpConcurrent: v),
              ),
            ),
          ),
          const SettingsRow(
            title: 'MTU',
            description: 'Не реализовано — MTU фиксирован ядром',
            trailing: SettingsStepper(value: 1500),
          ),

          const SettingsDivider(),
          const SettingsSectionLabel('Приложение'),
          SettingsRow(
            title: 'Запуск вместе с системой',
            trailing: SettingsSwitch(
              value: appSetting.autoLaunch,
              onChanged: (v) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(autoLaunch: v)),
            ),
          ),
          const SettingsRow(
            title: 'Уведомления',
            description: 'Не реализовано — переключатель отключён',
            trailing: SettingsSwitch(value: false),
          ),
          SettingsRow(
            title: 'Тема',
            trailing: SettingsSegmented<ThemeMode>(
              options: const [ThemeMode.dark, ThemeMode.light, ThemeMode.system],
              value: themeProps.themeMode,
              labels: const {
                ThemeMode.dark: 'Тёмная',
                ThemeMode.light: 'Светлая',
                ThemeMode.system: 'Авто',
              },
              onChanged: (v) => ref
                  .read(themeSettingProvider.notifier)
                  .update((state) => state.copyWith(themeMode: v)),
            ),
          ),

          const SizedBox(height: AppSpace.s6),
        ],
      ),
    );
  }
}
