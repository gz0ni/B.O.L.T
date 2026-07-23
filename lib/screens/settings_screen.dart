import 'package:flutter/material.dart';

import '../core/settings_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.service, this.onClose});

  final SettingsService service;
  final VoidCallback? onClose;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saving = false;

  AppSettings get s => widget.service.settings;

  Future<void> _apply({bool applyToCore = true}) async {
    setState(() => _saving = true);
    try {
      await widget.service.save(applyToCore: applyToCore);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось применить настройки: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Container(
      color: surfaces.bg,
      child: Stack(
        children: [
          ListView(
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
                  if (widget.onClose != null)
                    IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose),
                ],
              ),

              const SettingsSectionLabel('Ядро · mihomo'),
              SettingsRow(
                title: 'Режим маршрутизации',
                trailing: SettingsSegmented<RoutingMode>(
                  options: RoutingMode.values,
                  value: s.routingMode,
                  labels: const {
                    RoutingMode.rule: 'Правила',
                    RoutingMode.global: 'Глобальный',
                    RoutingMode.direct: 'Прямой',
                  },
                  onChanged: (v) {
                    s.routingMode = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'TUN-режим',
                description:
                    'Перехват всего системного трафика через виртуальный адаптер. '
                    'Требует прав администратора — сейчас без службы может не подняться.',
                trailing: SettingsSwitch(
                  value: s.tunEnabled,
                  onChanged: (v) async {
                    if (v) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Потребуется запрос UAC'),
                          content: const Text(
                            'Для TUN-режима ядро будет перезапущено с правами '
                            'администратора — Windows покажет запрос подтверждения. '
                            'Пока не реализован фоновый Windows-сервис, полностью '
                            'остановить процесс с правами администратора можно '
                            'только вручную через Диспетчер задач.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Продолжить'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                    }
                    s.tunEnabled = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'Стек TUN',
                trailing: SettingsSegmented<TunStack>(
                  options: TunStack.values,
                  value: s.tunStack,
                  labels: const {
                    TunStack.gvisor: 'gVisor',
                    TunStack.system: 'System',
                    TunStack.mixed: 'Mixed',
                  },
                  onChanged: (v) {
                    s.tunStack = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'Строгий роут',
                description: 'Strict Route — исключает утечки мимо TUN',
                trailing: SettingsSwitch(
                  value: s.strictRoute,
                  onChanged: (v) {
                    s.strictRoute = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'Разрешить LAN',
                trailing: SettingsSwitch(
                  value: s.allowLan,
                  onChanged: (v) {
                    s.allowLan = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'IPv6',
                trailing: SettingsSwitch(
                  value: s.ipv6,
                  onChanged: (v) {
                    s.ipv6 = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'Sniffer',
                description: 'Определение домена по TLS SNI / HTTP Host',
                trailing: SettingsSwitch(
                  value: s.sniffer,
                  onChanged: (v) {
                    s.sniffer = v;
                    _apply();
                  },
                ),
              ),

              const SettingsDivider(),
              const SettingsSectionLabel('DNS'),
              SettingsRow(
                title: 'Режим DNS',
                trailing: SettingsSegmented<String>(
                  options: const ['fake-ip', 'redir-host'],
                  value: s.dnsMode,
                  labels: const {'fake-ip': 'Fake IP', 'redir-host': 'Redir Host'},
                  onChanged: (v) {
                    s.dnsMode = v;
                    _apply();
                  },
                ),
              ),

              const SettingsDivider(),
              const SettingsSectionLabel('Подключение'),
              SettingsRow(
                title: 'Автоподключение при запуске',
                description: 'Поднимать соединение сразу при старте приложения',
                trailing: SettingsSwitch(
                  value: s.autoConnectOnStart,
                  onChanged: (v) {
                    s.autoConnectOnStart = v;
                    _apply(applyToCore: false);
                  },
                ),
              ),
              SettingsRow(
                title: 'Kill Switch',
                description:
                    'Блокировать интернет при падении ядра — пока не реализовано, '
                    'переключатель ничего не делает',
                trailing: SettingsSwitch(
                  value: s.killSwitch,
                  onChanged: (v) {
                    s.killSwitch = v;
                    _apply(applyToCore: false);
                  },
                ),
              ),
              SettingsRow(
                title: 'TCP Concurrent',
                description: 'Параллельные попытки подключения для ускорения',
                trailing: SettingsSwitch(
                  value: s.tcpConcurrent,
                  onChanged: (v) {
                    s.tcpConcurrent = v;
                    _apply();
                  },
                ),
              ),
              SettingsRow(
                title: 'MTU',
                trailing: SettingsStepper(
                  value: s.mtu,
                  onChanged: (v) {
                    s.mtu = v;
                    _apply();
                  },
                ),
              ),

              const SettingsDivider(),
              const SettingsSectionLabel('Приложение'),
              SettingsRow(
                title: 'Запуск вместе с системой',
                trailing: SettingsSwitch(
                  value: s.autostartWithSystem,
                  onChanged: (v) async {
                    setState(() => _saving = true);
                    await widget.service.setAutostart(v);
                    if (mounted) setState(() => _saving = false);
                  },
                ),
              ),
              SettingsRow(
                title: 'Уведомления',
                description: 'Пока не реализовано — переключатель только сохраняет значение',
                trailing: SettingsSwitch(
                  value: s.notifications,
                  onChanged: (v) {
                    s.notifications = v;
                    _apply(applyToCore: false);
                  },
                ),
              ),
              SettingsRow(
                title: 'Тема',
                trailing: SettingsSegmented<AppThemeMode>(
                  options: AppThemeMode.values,
                  value: s.themeMode,
                  labels: const {
                    AppThemeMode.dark: 'Тёмная',
                    AppThemeMode.light: 'Светлая',
                    AppThemeMode.auto: 'Авто',
                  },
                  onChanged: (v) {
                    s.themeMode = v;
                    _apply(applyToCore: false);
                  },
                ),
              ),

              const SizedBox(height: AppSpace.s6),
            ],
          ),
          if (_saving)
            Positioned(
              top: AppSpace.s4,
              right: AppSpace.s4,
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}