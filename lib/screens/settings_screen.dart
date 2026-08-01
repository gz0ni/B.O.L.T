import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'settings_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _categories = [
    'Основное',
    'Приложение',
    'Ядро · mihomo',
    'DNS',
    'Сеть',
  ];

  int _category = 0;

  void _changeMode(Mode mode) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  void _updatePatchConfig(PatchClashConfig Function(PatchClashConfig) update) {
    ref.read(patchClashConfigProvider.notifier).update(update);
  }

  void _updateDns(Dns Function(Dns) update) {
    ref.read(overrideDnsProvider.notifier).value = true;
    ref.read(patchClashConfigProvider.notifier).update(
      (state) => state.copyWith(dns: update(state.dns)),
    );
  }

  void _updateAppSetting(AppSettingProps Function(AppSettingProps) update) {
    ref.read(appSettingProvider.notifier).update(update);
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final patchConfig = ref.watch(patchClashConfigProvider);
    final network = ref.watch(networkSettingProvider);
    final appSetting = ref.watch(appSettingProvider);
    final themeProps = ref.watch(themeSettingProvider);

    return Container(
      color: surfaces.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s4, AppSpace.s2, 0),
            child: Row(
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, 0),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: surfaces.card2,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _categories.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _category = i),
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _category == i
                                ? semantic.on
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.xs - 2),
                          ),
                          child: Text(
                            _categories[i],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFontSize.sm,
                              color: _category == i
                                  ? const Color(0xFF0A130F)
                                  : surfaces.text2,
                              fontWeight: _category == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s4,
                  vertical: AppSpace.s2,
                ),
                children: [
                  if (_category == 0)
                    ..._quickRows(patchConfig, network, themeProps),
                  if (_category == 1) ..._appRows(appSetting, themeProps),
                  if (_category == 2) ..._coreRows(patchConfig, appSetting),
                  if (_category == 3) ..._dnsRows(patchConfig),
                  if (_category == 4) ..._networkRows(network),
                  const SizedBox(height: AppSpace.s6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SettingsRow _modeRow(PatchClashConfig patchConfig) {
    return SettingsRow(
      title: 'Режим маршрутизации',
      help: 'Правила — трафик по правилам конфига; Глобальный — весь '
          'трафик через прокси; Прямой — без прокси.',
      trailing: SettingsSegmented<Mode>(
        options: Mode.values,
        value: patchConfig.mode,
        labels: const {
          Mode.rule: 'Правила',
          Mode.global: 'Глобальный',
          Mode.direct: 'Прямой',
        },
        onChanged: _changeMode,
      ),
    );
  }

  SettingsRow _tunRow(PatchClashConfig patchConfig) {
    final semantic = context.semanticColors;
    final surfaces = context.surfaces;
    final tunEnable = ref.watch(realTunEnableProvider);
    final coreConnected = ref.watch(coreStatusProvider) == CoreStatus.connected;
    final running = tunEnable && coreConnected;
    return SettingsRow(
      title: 'TUN-режим',
      description:
          'Перехват всего системного трафика через виртуальный адаптер. '
          'При включении ядро запросит права администратора.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: running ? semantic.on : surfaces.text3,
            ),
          ),
          const SizedBox(width: AppSpace.s1),
          Text(
            running ? 'Работает' : 'Остановлен',
            style: TextStyle(
              fontSize: AppFontSize.xs,
              fontWeight: FontWeight.w600,
              color: running ? semantic.on : surfaces.text3,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          SettingsSwitch(
            value: patchConfig.tun.enable,
            onChanged: (v) => _updatePatchConfig(
              (state) => state.copyWith.tun(enable: v),
            ),
          ),
        ],
      ),
    );
  }

  SettingsRow _systemProxyRow(NetworkProps network) {
    return SettingsRow(
      title: 'Системный прокси',
      description: 'Проксировать системный трафик через mixed-порт ядра',
      trailing: SettingsSwitch(
        value: network.systemProxy,
        onChanged: (v) => ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: v)),
      ),
    );
  }

  SettingsRow _themeRow(ThemeProps themeProps) {
    return SettingsRow(
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
    );
  }

  List<Widget> _quickRows(
    PatchClashConfig patchConfig,
    NetworkProps network,
    ThemeProps themeProps,
  ) {
    return [
      _modeRow(patchConfig),
      _tunRow(patchConfig),
      _systemProxyRow(network),
      _themeRow(themeProps),
    ];
  }

  List<Widget> _coreRows(PatchClashConfig patchConfig, AppSettingProps appSetting) {
    final surfaces = context.surfaces;
    return [
      _modeRow(patchConfig),
      _tunRow(patchConfig),
      SettingsRow(
        title: 'Стек TUN',
        help: 'gVisor — лучшая совместимость; System — выше производительность; '
            'Mixed — гибрид обоих.',
        trailing: SettingsSegmented<TunStack>(
          options: TunStack.values,
          value: patchConfig.tun.stack,
          labels: const {
            TunStack.gvisor: 'gVisor',
            TunStack.system: 'System',
            TunStack.mixed: 'Mixed',
          },
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith.tun(stack: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'MTU',
        description: 'Применяется перезапуском ядра',
        help: 'Максимальный размер пакета в TUN. Стандарт — 9000; при '
            'проблемах подключения попробуйте 1500.',
        trailing: SettingsStepper(
          value: patchConfig.tun.mtu == 0 ? 9000 : patchConfig.tun.mtu,
          step: 100,
          min: 1000,
          max: 9000,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith.tun(mtu: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Строгий роут',
        description: 'Весь трафик идёт через TUN, без обхода маршрутов',
        trailing: SettingsSwitch(
          value: patchConfig.tun.strictRoute,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith.tun(strictRoute: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Sniffer',
        description: 'Определение домена по TLS SNI / HTTP Host',
        help: 'Распознаёт домен из зашифрованного трафика — нужно для '
            'корректной работы правил по доменам.',
        trailing: SettingsSwitch(
          value: patchConfig.sniffer.enable,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(
              sniffer: state.sniffer.copyWith(enable: v),
            ),
          ),
        ),
      ),
      SettingsRow(
        title: 'Разрешить LAN',
        help: 'Разрешить подключения к ядру с других устройств в локальной сети.',
        trailing: SettingsSwitch(
          value: patchConfig.allowLan,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(allowLan: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'IPv6',
        help: 'Разрешить IPv6-трафик через ядро.',
        trailing: SettingsSwitch(
          value: patchConfig.ipv6,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(ipv6: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Find Process Mode',
        description: 'Определение процесса-владельца соединения',
        help: 'Нужно для правил PROCESS-NAME. Always — определять всегда; '
            'Off — отключить (ниже нагрузка).',
        trailing: SettingsSegmented<FindProcessMode>(
          options: FindProcessMode.values,
          value: patchConfig.findProcessMode,
          labels: const {
            FindProcessMode.always: 'Always',
            FindProcessMode.off: 'Off',
          },
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(findProcessMode: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Unified Delay',
        description: 'Единый метод замера задержки',
        help: 'Все группы используют один метод замера, чтобы показания были '
            'сопоставимы между собой.',
        trailing: SettingsSwitch(
          value: patchConfig.unifiedDelay,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(unifiedDelay: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'TCP Concurrent',
        description: 'Параллельные попытки подключения для ускорения',
        help: 'Ускоряет установку соединения за счёт параллельных попыток, '
            'но может увеличить расход трафика.',
        trailing: SettingsSwitch(
          value: patchConfig.tcpConcurrent,
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(tcpConcurrent: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Geodata Loader',
        help: 'Memory — геоданные в оперативной памяти (быстрее старт); '
            'Standard — с диска (меньше памяти).',
        trailing: SettingsSegmented<GeodataLoader>(
          options: GeodataLoader.values,
          value: patchConfig.geodataLoader,
          labels: const {
            GeodataLoader.memconservative: 'Memory',
            GeodataLoader.standard: 'Standard',
          },
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(geodataLoader: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'External Controller',
        description: 'HTTP-API ядра (127.0.0.1:9090)',
        help: 'Внешний API для управления ядром (например, через '
            'сторонние дашборды).',
        trailing: SettingsSegmented<ExternalControllerStatus>(
          options: ExternalControllerStatus.values,
          value: patchConfig.externalController,
          labels: const {
            ExternalControllerStatus.close: 'Выкл',
            ExternalControllerStatus.open: 'Вкл',
          },
          onChanged: (v) => _updatePatchConfig(
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
              (state) => state.copyWith(keepAliveInterval: parsed),
            );
          },
        ),
      ),
      SettingsRow(
        title: 'Порты',
        description: 'Mixed / SOCKS / HTTP / Redir / TProxy',
        help: 'Порты, на которых ядро слушает прокси-протоколы. 0 — порт '
            'отключён.',
        trailing: SettingsPortsEditor(
          mixedPort: patchConfig.mixedPort,
          socksPort: patchConfig.socksPort,
          port: patchConfig.port,
          redirPort: patchConfig.redirPort,
          tproxyPort: patchConfig.tproxyPort,
          onChanged: (mixed, socks, port, redir, tproxy) =>
              _updatePatchConfig(
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
                (state) => state.copyWith(globalUa: v),
              ),
            ),
            const SizedBox(width: AppSpace.s2),
            PopupMenuButton<String>(
              tooltip: 'Пресеты',
              onSelected: (v) => _updatePatchConfig(
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
        help: 'Ссылка, которой ядро проверяет задержку серверов.',
        trailing: SettingsInput(
          width: 180,
          value: appSetting.testUrl,
          onChanged: (v) => _updateAppSetting(
            (state) => state.copyWith(testUrl: v),
          ),
        ),
      ),
    ];
  }

  List<Widget> _dnsRows(PatchClashConfig patchConfig) {
    return [
      SettingsRow(
        title: 'Режим DNS',
        help: 'Fake IP — доменам выдаются виртуальные адреса; '
            'Redir Host — перезапись Host в DNS-ответах.',
        trailing: SettingsSegmented<DnsMode>(
          options: const [DnsMode.fakeIp, DnsMode.redirHost],
          value: patchConfig.dns.enhancedMode,
          labels: const {
            DnsMode.fakeIp: 'Fake IP',
            DnsMode.redirHost: 'Redir Host',
          },
          onChanged: (v) => _updateDns((dns) => dns.copyWith(enhancedMode: v)),
        ),
      ),
      SettingsRow(
        title: 'Listen',
        description: 'Адрес встроенного DNS-сервера',
        help: 'Адрес:порт, на котором ядро слушает DNS-запросы.',
        trailing: SettingsInput(
          width: 130,
          value: patchConfig.dns.listen,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(listen: v)),
        ),
      ),
      SettingsRow(
        title: 'Prefer H3',
        help: 'Использовать HTTP/3 (QUIC) для DoH-резолверов, где '
            'поддерживается.',
        trailing: SettingsSwitch(
          value: patchConfig.dns.preferH3,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(preferH3: v)),
        ),
      ),
      SettingsRow(
        title: 'Use Hosts',
        help: 'Учитывать файл hosts конфига при резолве.',
        trailing: SettingsSwitch(
          value: patchConfig.dns.useHosts,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(useHosts: v)),
        ),
      ),
      SettingsRow(
        title: 'Use System Hosts',
        help: 'Учитывать системные hosts Windows при резолве.',
        trailing: SettingsSwitch(
          value: patchConfig.dns.useSystemHosts,
          onChanged: (v) => _updateDns(
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
            (dns) => dns.copyWith(respectRules: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'IPv6',
        help: 'Отвечать на AAAA-запросы встроенным DNS-сервером.',
        trailing: SettingsSwitch(
          value: patchConfig.dns.ipv6,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(ipv6: v)),
        ),
      ),
      SettingsRow(
        title: 'Fake-IP Range',
        help: 'Подсеть для fake-ip адресов. Используется только в режиме '
            'Fake IP.',
        trailing: SettingsInput(
          width: 130,
          value: patchConfig.dns.fakeIpRange,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fakeIpRange: v)),
        ),
      ),
      SettingsRow(
        title: 'Fake-IP Filter',
        help: 'Домены из списка резолвятся реальным IP, а не через fake-ip '
            '(например, *.lan).',
        trailing: SettingsListEditor(
          title: 'Fake-IP Filter',
          value: patchConfig.dns.fakeIpFilter,
          hint: '*.lan',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fakeIpFilter: v)),
        ),
      ),
      SettingsRow(
        title: 'Default Nameserver',
        help: 'Резолверы для запросов, не попавших под nameserver-policy.',
        trailing: SettingsListEditor(
          title: 'Default Nameserver',
          value: patchConfig.dns.defaultNameserver,
          hint: '223.5.5.5',
          onChanged: (v) => _updateDns(
            (dns) => dns.copyWith(defaultNameserver: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Nameserver',
        help: 'Основные DNS-резолверы для обычных запросов.',
        trailing: SettingsListEditor(
          title: 'Nameserver',
          value: patchConfig.dns.nameserver,
          hint: 'https://doh.pub/dns-query',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(nameserver: v)),
        ),
      ),
      SettingsRow(
        title: 'Fallback',
        help: 'Резолверы для запросов, которые нужно обрабатывать отдельно '
            '(например, при блокировке основного DNS).',
        trailing: SettingsListEditor(
          title: 'Fallback',
          value: patchConfig.dns.fallback,
          hint: 'tls://8.8.4.4',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fallback: v)),
        ),
      ),
      SettingsRow(
        title: 'Proxy Server Nameserver',
        help: 'Резолверы для доменных имён прокси-серверов.',
        trailing: SettingsListEditor(
          title: 'Proxy Server Nameserver',
          value: patchConfig.dns.proxyServerNameserver,
          hint: 'https://doh.pub/dns-query',
          onChanged: (v) => _updateDns(
            (dns) => dns.copyWith(proxyServerNameserver: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Nameserver Policy',
        help: 'Правила выбора резолверов по доменам (например, '
            'geosite:cn → китайские DoH).',
        trailing: SettingsMapEditor(
          title: 'Nameserver Policy',
          value: patchConfig.dns.nameserverPolicy,
          keyHint: 'geosite:cn',
          valueHint: 'https://doh.pub/dns-query',
          onChanged: (v) => _updateDns(
            (dns) => dns.copyWith(nameserverPolicy: v),
          ),
        ),
      ),
    ];
  }

  List<Widget> _networkRows(NetworkProps network) {
    return [
      _systemProxyRow(network),
      SettingsRow(
        title: 'Append System DNS',
        description: 'Добавлять system:// в nameserver',
        help: 'Подмешивает системные резолверы Windows к DNS-серверам ядра.',
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
        help: 'Домены из списка не будут проходить через системный прокси.',
        trailing: SettingsListEditor(
          title: 'Bypass Domain',
          value: network.bypassDomain,
          hint: '*.local',
          onChanged: (v) => ref
              .read(networkSettingProvider.notifier)
              .update((state) => state.copyWith(bypassDomain: v)),
        ),
      ),
    ];
  }

  List<Widget> _appRows(
    AppSettingProps appSetting,
    ThemeProps themeProps,
  ) {
    return [
      SettingsRow(
        title: 'Автоподключение при запуске',
        description: 'Поднимать соединение сразу при старте приложения',
        trailing: SettingsSwitch(
          value: appSetting.autoRun,
          onChanged: (v) => _updateAppSetting(
            (state) => state.copyWith(autoRun: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Запуск вместе с системой',
        help: 'Добавляет приложение в автозагрузку Windows.',
        trailing: SettingsSwitch(
          value: appSetting.autoLaunch,
          onChanged: (v) => _updateAppSetting(
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
            (state) => state.copyWith(minimizeOnExit: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Закрывать соединения при выходе',
        help: 'Закрывать активные соединения и останавливать ядро при '
            'выходе из приложения.',
        trailing: SettingsSwitch(
          value: appSetting.closeConnections,
          onChanged: (v) => _updateAppSetting(
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
            (state) => state.copyWith(onlyStatisticsProxy: v),
          ),
        ),
      ),
      SettingsRow(
        title: 'Проверять обновления',
        help: 'Автоматически проверять наличие новых версий приложения.',
        trailing: SettingsSwitch(
          value: appSetting.autoCheckUpdate,
          onChanged: (v) => _updateAppSetting(
            (state) => state.copyWith(autoCheckUpdate: v),
          ),
        ),
      ),
      _themeRow(themeProps),
    ];
  }
}
