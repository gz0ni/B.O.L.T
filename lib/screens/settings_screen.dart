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

  void _updatePatchConfig(
    WidgetRef ref,
    PatchClashConfig Function(PatchClashConfig) update,
  ) {
    ref.read(patchClashConfigProvider.notifier).update(update);
  }

  void _updateDns(WidgetRef ref, Dns Function(Dns) update) {
    ref.read(overrideDnsProvider.notifier).value = true;
    ref.read(patchClashConfigProvider.notifier).update(
      (state) => state.copyWith(dns: update(state.dns)),
    );
  }

  void _updateAppSetting(
    WidgetRef ref,
    AppSettingProps Function(AppSettingProps) update,
  ) {
    ref.read(appSettingProvider.notifier).update(update);
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
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s4,
          ),
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
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
              title: 'MTU',
              description: 'Применяется перезапуском ядра',
              trailing: SettingsStepper(
                value: patchConfig.tun.mtu == 0 ? 9000 : patchConfig.tun.mtu,
                step: 100,
                min: 1000,
                max: 9000,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith.tun(mtu: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Строгий роут',
              description:
                  'Весь трафик идёт через TUN, без обхода маршрутов',
              trailing: SettingsSwitch(
                value: patchConfig.tun.strictRoute,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith.tun(strictRoute: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Sniffer',
              description: 'Определение домена по TLS SNI / HTTP Host',
              trailing: SettingsSwitch(
                value: patchConfig.sniffer.enable,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(sniffer: state.sniffer.copyWith(enable: v)),
                ),
              ),
            ),
            SettingsRow(
              title: 'Разрешить LAN',
              trailing: SettingsSwitch(
                value: patchConfig.allowLan,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(allowLan: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'IPv6',
              trailing: SettingsSwitch(
                value: patchConfig.ipv6,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(ipv6: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Find Process Mode',
              description: 'Определение процесса-владельца соединения',
              trailing: SettingsSegmented<FindProcessMode>(
                options: FindProcessMode.values,
                value: patchConfig.findProcessMode,
                labels: const {
                  FindProcessMode.always: 'Always',
                  FindProcessMode.off: 'Off',
                },
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(findProcessMode: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Unified Delay',
              description: 'Единый метод замера задержки',
              trailing: SettingsSwitch(
                value: patchConfig.unifiedDelay,
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(unifiedDelay: v),
                ),
              ),
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
            SettingsRow(
              title: 'Geodata Loader',
              trailing: SettingsSegmented<GeodataLoader>(
                options: GeodataLoader.values,
                value: patchConfig.geodataLoader,
                labels: const {
                  GeodataLoader.memconservative: 'Memory',
                  GeodataLoader.standard: 'Standard',
                },
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(geodataLoader: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'External Controller',
              description: 'HTTP-API ядра (127.0.0.1:9090)',
              trailing: SettingsSegmented<ExternalControllerStatus>(
                options: ExternalControllerStatus.values,
                value: patchConfig.externalController,
                labels: const {
                  ExternalControllerStatus.close: 'Выкл',
                  ExternalControllerStatus.open: 'Вкл',
                },
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(externalController: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Keep-alive',
              description: 'Интервал проверки соединений, сек',
              trailing: SettingsInput(
                width: 80,
                numeric: true,
                value: '${patchConfig.keepAliveInterval}',
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed == null || parsed <= 0) return;
                  _updatePatchConfig(
                    ref,
                    (state) => state.copyWith(keepAliveInterval: parsed),
                  );
                },
              ),
            ),
            SettingsRow(
              title: 'Порты',
              description: 'Mixed / SOCKS / HTTP / Redir / TProxy',
              trailing: SettingsPortsEditor(
                mixedPort: patchConfig.mixedPort,
                socksPort: patchConfig.socksPort,
                port: patchConfig.port,
                redirPort: patchConfig.redirPort,
                tproxyPort: patchConfig.tproxyPort,
                onChanged: (mixed, socks, port, redir, tproxy) =>
                    _updatePatchConfig(
                      ref,
                      (state) => state.copyWith(
                        mixedPort: mixed,
                        socksPort: socks,
                        port: port,
                        redirPort: redir,
                        tproxyPort: tproxy,
                      ),
                    ),
              ),
            ),
            SettingsRow(
              title: 'Hosts',
              description: 'Статические DNS-записи',
              trailing: SettingsMapEditor(
                title: 'Hosts',
                value: patchConfig.hosts,
                keyHint: 'example.com',
                valueHint: '1.2.3.4',
                onChanged: (v) => _updatePatchConfig(
                  ref,
                  (state) => state.copyWith(hosts: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'User-Agent',
              description: 'UA при обновлении подписок',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingsInput(
                    width: 160,
                    value: patchConfig.globalUa ?? '',
                    hint: 'clash-verge/v2.4.2',
                    onChanged: (v) => _updatePatchConfig(
                      ref,
                      (state) => state.copyWith(globalUa: v),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  PopupMenuButton<String>(
                    tooltip: 'Пресеты',
                    onSelected: (v) => _updatePatchConfig(
                      ref,
                      (state) => state.copyWith(globalUa: v),
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'clash-verge/v2.4.2',
                        child: Text('clash-verge/v2.4.2'),
                      ),
                      PopupMenuItem(
                        value: 'ClashforWindows/0.19.23',
                        child: Text('ClashforWindows/0.19.23'),
                      ),
                      PopupMenuItem(
                        value: '',
                        child: Text('По умолчанию'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfaces.card2,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(color: surfaces.border),
                      ),
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: surfaces.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SettingsRow(
              title: 'Test URL',
              description: 'Ссылка для замера задержки',
              trailing: SettingsInput(
                width: 180,
                value: appSetting.testUrl,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(testUrl: v),
                ),
              ),
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
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(enhancedMode: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Listen',
              description: 'Адрес встроенного DNS-сервера',
              trailing: SettingsInput(
                width: 130,
                value: patchConfig.dns.listen,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(listen: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Prefer H3',
              trailing: SettingsSwitch(
                value: patchConfig.dns.preferH3,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(preferH3: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Use Hosts',
              trailing: SettingsSwitch(
                value: patchConfig.dns.useHosts,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(useHosts: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Use System Hosts',
              trailing: SettingsSwitch(
                value: patchConfig.dns.useSystemHosts,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(useSystemHosts: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Respect Rules',
              description: 'Учитывать правила при DNS-запросах',
              trailing: SettingsSwitch(
                value: patchConfig.dns.respectRules,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(respectRules: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'IPv6',
              trailing: SettingsSwitch(
                value: patchConfig.dns.ipv6,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(ipv6: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Fake-IP Range',
              trailing: SettingsInput(
                width: 130,
                value: patchConfig.dns.fakeIpRange,
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(fakeIpRange: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Fake-IP Filter',
              trailing: SettingsListEditor(
                title: 'Fake-IP Filter',
                value: patchConfig.dns.fakeIpFilter,
                hint: '*.lan',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(fakeIpFilter: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Default Nameserver',
              trailing: SettingsListEditor(
                title: 'Default Nameserver',
                value: patchConfig.dns.defaultNameserver,
                hint: '223.5.5.5',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(defaultNameserver: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Nameserver',
              trailing: SettingsListEditor(
                title: 'Nameserver',
                value: patchConfig.dns.nameserver,
                hint: 'https://doh.pub/dns-query',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(nameserver: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Fallback',
              trailing: SettingsListEditor(
                title: 'Fallback',
                value: patchConfig.dns.fallback,
                hint: 'tls://8.8.4.4',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(fallback: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Proxy Server Nameserver',
              trailing: SettingsListEditor(
                title: 'Proxy Server Nameserver',
                value: patchConfig.dns.proxyServerNameserver,
                hint: 'https://doh.pub/dns-query',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(proxyServerNameserver: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Nameserver Policy',
              trailing: SettingsMapEditor(
                title: 'Nameserver Policy',
                value: patchConfig.dns.nameserverPolicy,
                keyHint: 'geosite:cn',
                valueHint: 'https://doh.pub/dns-query',
                onChanged: (v) => _updateDns(
                  ref,
                  (dns) => dns.copyWith(nameserverPolicy: v),
                ),
              ),
            ),

            const SettingsDivider(),
            const SettingsSectionLabel('Сеть'),
            SettingsRow(
              title: 'Системный прокси',
              description:
                  'Проксировать системный трафик через mixed-порт ядра',
              trailing: SettingsSwitch(
                value: network.systemProxy,
                onChanged: (v) => ref
                    .read(networkSettingProvider.notifier)
                    .update((state) => state.copyWith(systemProxy: v)),
              ),
            ),
            SettingsRow(
              title: 'Append System DNS',
              description: 'Добавлять system:// в nameserver',
              trailing: SettingsSwitch(
                value: network.appendSystemDns,
                onChanged: (v) => ref
                    .read(networkSettingProvider.notifier)
                    .update((state) => state.copyWith(appendSystemDns: v)),
              ),
            ),
            SettingsRow(
              title: 'Bypass Domain',
              description: 'Домены, идущие в обход прокси',
              trailing: SettingsListEditor(
                title: 'Bypass Domain',
                value: network.bypassDomain,
                hint: '*.local',
                onChanged: (v) => ref
                    .read(networkSettingProvider.notifier)
                    .update((state) => state.copyWith(bypassDomain: v)),
              ),
            ),

            const SettingsDivider(),
            const SettingsSectionLabel('Приложение'),
            SettingsRow(
              title: 'Автоподключение при запуске',
              description: 'Поднимать соединение сразу при старте приложения',
              trailing: SettingsSwitch(
                value: appSetting.autoRun,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(autoRun: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Запуск вместе с системой',
              trailing: SettingsSwitch(
                value: appSetting.autoLaunch,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(autoLaunch: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Свернуть при закрытии',
              description: 'Закрытие окна сворачивает приложение в трей',
              trailing: SettingsSwitch(
                value: appSetting.minimizeOnExit,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(minimizeOnExit: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Закрывать соединения при выходе',
              trailing: SettingsSwitch(
                value: appSetting.closeConnections,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(closeConnections: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Статистика только прокси',
              description: 'Учитывать трафик только через прокси',
              trailing: SettingsSwitch(
                value: appSetting.onlyStatisticsProxy,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(onlyStatisticsProxy: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Проверять обновления',
              trailing: SettingsSwitch(
                value: appSetting.autoCheckUpdate,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(autoCheckUpdate: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Уведомления',
              description:
                  'Обновление подписок и предупреждение об истечении',
              trailing: SettingsSwitch(
                value: appSetting.notifications,
                onChanged: (v) => _updateAppSetting(
                  ref,
                  (state) => state.copyWith(notifications: v),
                ),
              ),
            ),
            SettingsRow(
              title: 'Тема',
              trailing: SettingsSegmented<ThemeMode>(
                options: const [
                  ThemeMode.dark,
                  ThemeMode.light,
                  ThemeMode.system,
                ],
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
      ),
    );
  }
}
