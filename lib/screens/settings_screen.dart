import 'package:bolt/common/common.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/bolt_controls.dart';
import '../widgets/bolt_icon_button.dart';
import '../widgets/bolt_surfaces.dart';
import 'settings_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _category = 0;

  List<String> _categories() {
    final l = context.appLocalizations;
    return [
      l.mainCategory,
      l.application,
      l.coreCategory,
      l.dnsCategory,
      l.networkCategory,
    ];
  }

  void _changeMode(Mode mode) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  void _updatePatchConfig(PatchClashConfig Function(PatchClashConfig) update) {
    ref.read(patchClashConfigProvider.notifier).update(update);
  }

  void _updateDns(Dns Function(Dns) update) {
    ref.read(overrideDnsProvider.notifier).value = true;
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(dns: update(state.dns)));
  }

  void _updateAppSetting(AppSettingProps Function(AppSettingProps) update) {
    ref.read(appSettingProvider.notifier).update(update);
  }

  void _openAbout() {
    final l = context.appLocalizations;
    showBoltSheet<void>(
      context,
      title: l.about,
      heightFactor: 0.8,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s4,
          AppSpace.s4,
          AppSpace.s4,
          AppSpace.s4,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s3),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/avatar/about.jpg',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpace.s2),
                Text(
                  'B.O.L.T',
                  style: TextStyle(
                    color: sheetContext.surfaces.text1,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.lg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v${globalState.packageInfo.version}'
                  '${globalState.isPre ? '-beta' : ''}',
                  style: TextStyle(
                    color: sheetContext.surfaces.text3,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              ],
            ),
          ),
          SettingsRow(
            title: l.author,
            trailing: Text(
              'gz0ni',
              style: TextStyle(
                color: sheetContext.surfaces.text1,
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SettingsRow(
            title: 'GitHub',
            description: 'github.com/$repository',
            trailing: BoltIconButton(
              icon: Icons.open_in_new,
              tooltip: l.openRepository,
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/$repository')),
            ),
          ),
          SettingsRow(
            title: l.update,
            description: l.checkUpdatesDesc,
            trailing: BoltMiniButton(
              label: l.checkUpdates,
              onTap: _checkUpdate,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    final data = await request.checkForUpdate();
    await ref
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: data, isUser: true);
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final patchConfig = ref.watch(patchClashConfigProvider);
    final network = ref.watch(networkSettingProvider);
    final appSetting = ref.watch(appSettingProvider);
    final themeProps = ref.watch(themeSettingProvider);

    return Container(
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s4,
              AppSpace.s4,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.appLocalizations.settings,
                    style: TextStyle(
                      fontFamily: AppFontFamily.display,
                      fontSize: AppFontSize.lg,
                      fontWeight: FontWeight.w600,
                      color: surfaces.text1,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  BoltIconButton(
                    icon: Icons.close,
                    tooltip: context.appLocalizations.close,
                    onTap: widget.onClose,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s2,
              AppSpace.s4,
              0,
            ),
            child: BoltSegmented<int>(
              expanded: true,
              options: _categories()
                  .asMap()
                  .entries
                  .map((e) => BoltSegmentedOption(e.key, e.value))
                  .toList(),
              value: _category,
              onChanged: (v) => setState(() => _category = v),
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
                    ..._quickRows(patchConfig, network, themeProps, appSetting),
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
    final l = context.appLocalizations;
    return SettingsRow(
      title: l.routeMode,
      help: l.routeModeHelp,
      trailing: SettingsSegmented<Mode>(
        options: Mode.values,
        value: patchConfig.mode,
        labels: {
          Mode.rule: l.routeModeRule,
          Mode.global: l.routeModeGlobal,
          Mode.direct: l.routeModeDirect,
        },
        onChanged: _changeMode,
      ),
    );
  }

  SettingsRow _tunRow(PatchClashConfig patchConfig) {
    final l = context.appLocalizations;
    final semantic = context.semanticColors;
    final surfaces = context.surfaces;
    final tunEnable = ref.watch(realTunEnableProvider);
    final coreConnected = ref.watch(coreStatusProvider) == CoreStatus.connected;
    final running = tunEnable && coreConnected;
    return SettingsRow(
      title: l.tunMode,
      description: l.tunModeDesc,
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
            running ? l.running : l.stopped,
            style: TextStyle(
              fontSize: AppFontSize.xs,
              fontWeight: FontWeight.w600,
              color: running ? semantic.on : surfaces.text3,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          SettingsSwitch(
            value: patchConfig.tun.enable,
            onChanged: (v) =>
                _updatePatchConfig((state) => state.copyWith.tun(enable: v)),
          ),
        ],
      ),
    );
  }

  SettingsRow _systemProxyRow(NetworkProps network) {
    final l = context.appLocalizations;
    return SettingsRow(
      title: l.systemProxy,
      description: l.systemProxyForkDesc,
      trailing: SettingsSwitch(
        value: network.systemProxy,
        onChanged: (v) => ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: v)),
      ),
    );
  }

  SettingsRow _themeRow(ThemeProps themeProps) {
    final l = context.appLocalizations;
    return SettingsRow(
      title: l.theme,
      trailing: SettingsSegmented<ThemeMode>(
        options: const [ThemeMode.dark, ThemeMode.light, ThemeMode.system],
        value: themeProps.themeMode,
        labels: {
          ThemeMode.dark: l.dark,
          ThemeMode.light: l.light,
          ThemeMode.system: l.auto,
        },
        onChanged: (v) => ref
            .read(themeSettingProvider.notifier)
            .update((state) => state.copyWith(themeMode: v)),
      ),
    );
  }

  String _languageLabel(String? locale) {
    switch (locale) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return context.appLocalizations.languageSystem;
    }
  }

  void _openLanguage() {
    final l = context.appLocalizations;
    final current = ref.read(appSettingProvider).locale;
    void select(String? value) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(locale: value));
    }

    showBoltSheet<void>(
      context,
      title: l.language,
      builder: (sheetContext) {
        final surfaces = sheetContext.surfaces;
        Widget option(String label, String? value) {
          final selected = current == value;
          return InkWell(
            onTap: () {
              Navigator.of(sheetContext).pop();
              select(value);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s4,
                vertical: AppSpace.s3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: surfaces.text1,
                        fontSize: AppFontSize.md,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check, size: 18, color: surfaces.text1),
                ],
              ),
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: [
            option(l.languageSystem, null),
            option('Русский', 'ru'),
            option('English', 'en'),
          ],
        );
      },
    );
  }

  Widget _languageRow(AppSettingProps appSetting) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openLanguage,
        child: SettingsRow(
          title: context.appLocalizations.language,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _languageLabel(appSetting.locale),
                style: TextStyle(
                  color: context.surfaces.text2,
                  fontSize: AppFontSize.md,
                ),
              ),
              const SizedBox(width: AppSpace.s1),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.surfaces.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _quickRows(
    PatchClashConfig patchConfig,
    NetworkProps network,
    ThemeProps themeProps,
    AppSettingProps appSetting,
  ) {
    return [
      _modeRow(patchConfig),
      _tunRow(patchConfig),
      _systemProxyRow(network),
      _themeRow(themeProps),
      _languageRow(appSetting),
    ];
  }

  List<Widget> _coreRows(
    PatchClashConfig patchConfig,
    AppSettingProps appSetting,
  ) {
    final l = context.appLocalizations;
    return [
      _modeRow(patchConfig),
      _tunRow(patchConfig),
      SettingsRow(
        title: l.tunStack,
        help: l.tunStackHelp,
        trailing: SettingsSegmented<TunStack>(
          options: TunStack.values,
          value: patchConfig.tun.stack,
          labels: const {
            TunStack.gvisor: 'gVisor',
            TunStack.system: 'System',
            TunStack.mixed: 'Mixed',
          },
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith.tun(stack: v)),
        ),
      ),
      SettingsRow(
        title: l.mtu,
        description: l.mtuReapplyRestart,
        help: l.mtuHelp,
        trailing: SettingsStepper(
          value: patchConfig.tun.mtu == 0 ? 9000 : patchConfig.tun.mtu,
          step: 100,
          min: 1000,
          max: 9000,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith.tun(mtu: v)),
        ),
      ),
      SettingsRow(
        title: l.strictRoute,
        description: l.strictRouteDesc,
        trailing: SettingsSwitch(
          value: patchConfig.tun.strictRoute,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith.tun(strictRoute: v)),
        ),
      ),
      SettingsRow(
        title: 'Sniffer',
        description: l.snifferDesc,
        help: l.snifferHelp,
        trailing: SettingsSwitch(
          value: patchConfig.sniffer.enable,
          onChanged: (v) => _updatePatchConfig(
            (state) =>
                state.copyWith(sniffer: state.sniffer.copyWith(enable: v)),
          ),
        ),
      ),
      SettingsRow(
        title: l.allowLan,
        help: l.allowLanHelp,
        trailing: SettingsSwitch(
          value: patchConfig.allowLan,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(allowLan: v)),
        ),
      ),
      SettingsRow(
        title: 'IPv6',
        help: l.ipv6EnabledHelp,
        trailing: SettingsSwitch(
          value: patchConfig.ipv6,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(ipv6: v)),
        ),
      ),
      SettingsRow(
        title: 'Find Process Mode',
        description: l.findProcessModeDesc,
        help: l.findProcessModeHelp,
        trailing: SettingsSegmented<FindProcessMode>(
          options: FindProcessMode.values,
          value: patchConfig.findProcessMode,
          labels: const {
            FindProcessMode.always: 'Always',
            FindProcessMode.off: 'Off',
          },
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(findProcessMode: v)),
        ),
      ),
      SettingsRow(
        title: 'Unified Delay',
        description: l.unifiedDelayForkDesc,
        help: l.unifiedDelayForkHelp,
        trailing: SettingsSwitch(
          value: patchConfig.unifiedDelay,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(unifiedDelay: v)),
        ),
      ),
      SettingsRow(
        title: 'TCP Concurrent',
        description: l.tcpConcurrentForkDesc,
        help: l.tcpConcurrentForkHelp,
        trailing: SettingsSwitch(
          value: patchConfig.tcpConcurrent,
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(tcpConcurrent: v)),
        ),
      ),
      SettingsRow(
        title: 'Geodata Loader',
        help: l.geodataLoaderHelp,
        trailing: SettingsSegmented<GeodataLoader>(
          options: GeodataLoader.values,
          value: patchConfig.geodataLoader,
          labels: const {
            GeodataLoader.memconservative: 'Memory',
            GeodataLoader.standard: 'Standard',
          },
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(geodataLoader: v)),
        ),
      ),
      SettingsRow(
        title: 'External Controller',
        description: l.externalControllerApiDesc,
        help: l.externalControllerHelp,
        trailing: SettingsSegmented<ExternalControllerStatus>(
          options: ExternalControllerStatus.values,
          value: patchConfig.externalController,
          labels: {
            ExternalControllerStatus.close: l.off,
            ExternalControllerStatus.open: l.on,
          },
          onChanged: (v) => _updatePatchConfig(
            (state) => state.copyWith(externalController: v),
          ),
        ),
      ),
      SettingsRow(
        title: l.keepAlive,
        description: l.keepAliveIntervalDesc,
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
        title: l.ports,
        description: 'Mixed / SOCKS / HTTP / Redir / TProxy',
        help: l.portsHelp,
        trailing: SettingsPortsEditor(
          mixedPort: patchConfig.mixedPort,
          socksPort: patchConfig.socksPort,
          port: patchConfig.port,
          redirPort: patchConfig.redirPort,
          tproxyPort: patchConfig.tproxyPort,
          onChanged: (mixed, socks, port, redir, tproxy) => _updatePatchConfig(
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
        description: l.staticHostsDesc,
        trailing: SettingsMapEditor(
          title: 'Hosts',
          value: patchConfig.hosts,
          keyHint: 'example.com',
          valueHint: '1.2.3.4',
          onChanged: (v) =>
              _updatePatchConfig((state) => state.copyWith(hosts: v)),
        ),
      ),
      SettingsRow(
        title: 'User-Agent',
        description: l.uaDesc,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsInput(
              width: 160,
              value: patchConfig.globalUa ?? '',
              hint: 'clash-verge/v2.4.2',
              onChanged: (v) =>
                  _updatePatchConfig((state) => state.copyWith(globalUa: v)),
            ),
            const SizedBox(width: AppSpace.s2),
            PopupMenuButton<String>(
              tooltip: l.presets,
              onSelected: (v) =>
                  _updatePatchConfig((state) => state.copyWith(globalUa: v)),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'clash-verge/v2.4.2',
                  child: Text('clash-verge/v2.4.2'),
                ),
                const PopupMenuItem(
                  value: 'ClashforWindows/0.19.23',
                  child: Text('ClashforWindows/0.19.23'),
                ),
                PopupMenuItem(value: '', child: Text(l.defaultText)),
              ],
              child: BoltIconButton(
                icon: Icons.arrow_drop_down,
                tooltip: l.presets,
                onTap: null,
                compact: true,
              ),
            ),
          ],
        ),
      ),
      SettingsRow(
        title: 'Test URL',
        description: l.testUrlDesc,
        help: l.testUrlHelp,
        trailing: SettingsInput(
          width: 180,
          value: appSetting.testUrl,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(testUrl: v)),
        ),
      ),
    ];
  }

  List<Widget> _dnsRows(PatchClashConfig patchConfig) {
    final l = context.appLocalizations;
    return [
      SettingsRow(
        title: l.dnsMode,
        help: l.dnsModeHelp,
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
        title: l.dnsListen,
        description: l.dnsListenDesc,
        help: l.dnsListenHelp,
        trailing: SettingsInput(
          width: 130,
          value: patchConfig.dns.listen,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(listen: v)),
        ),
      ),
      SettingsRow(
        title: 'Prefer H3',
        help: l.preferH3Help,
        trailing: SettingsSwitch(
          value: patchConfig.dns.preferH3,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(preferH3: v)),
        ),
      ),
      SettingsRow(
        title: 'Use Hosts',
        help: l.useHostsHelp,
        trailing: SettingsSwitch(
          value: patchConfig.dns.useHosts,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(useHosts: v)),
        ),
      ),
      SettingsRow(
        title: 'Use System Hosts',
        help: l.useSystemHostsHelp,
        trailing: SettingsSwitch(
          value: patchConfig.dns.useSystemHosts,
          onChanged: (v) =>
              _updateDns((dns) => dns.copyWith(useSystemHosts: v)),
        ),
      ),
      SettingsRow(
        title: 'Respect Rules',
        description: l.respectRulesDesc,
        trailing: SettingsSwitch(
          value: patchConfig.dns.respectRules,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(respectRules: v)),
        ),
      ),
      SettingsRow(
        title: 'IPv6',
        help: l.ipv6DnsHelp,
        trailing: SettingsSwitch(
          value: patchConfig.dns.ipv6,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(ipv6: v)),
        ),
      ),
      SettingsRow(
        title: 'Fake-IP Range',
        help: l.fakeipRangeHelp,
        trailing: SettingsInput(
          width: 130,
          value: patchConfig.dns.fakeIpRange,
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fakeIpRange: v)),
        ),
      ),
      SettingsRow(
        title: 'Fake-IP Filter',
        help: l.fakeipFilterHelp,
        trailing: SettingsListEditor(
          title: 'Fake-IP Filter',
          value: patchConfig.dns.fakeIpFilter,
          hint: '*.lan',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fakeIpFilter: v)),
        ),
      ),
      SettingsRow(
        title: 'Default Nameserver',
        help: l.defaultNameserverHelp,
        trailing: SettingsListEditor(
          title: 'Default Nameserver',
          value: patchConfig.dns.defaultNameserver,
          hint: '223.5.5.5',
          onChanged: (v) =>
              _updateDns((dns) => dns.copyWith(defaultNameserver: v)),
        ),
      ),
      SettingsRow(
        title: 'Nameserver',
        help: l.nameserverHelp,
        trailing: SettingsListEditor(
          title: 'Nameserver',
          value: patchConfig.dns.nameserver,
          hint: 'https://doh.pub/dns-query',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(nameserver: v)),
        ),
      ),
      SettingsRow(
        title: 'Fallback',
        help: l.fallbackHelp,
        trailing: SettingsListEditor(
          title: 'Fallback',
          value: patchConfig.dns.fallback,
          hint: 'tls://8.8.4.4',
          onChanged: (v) => _updateDns((dns) => dns.copyWith(fallback: v)),
        ),
      ),
      SettingsRow(
        title: 'Proxy Server Nameserver',
        help: l.proxyNameserverHelp,
        trailing: SettingsListEditor(
          title: 'Proxy Server Nameserver',
          value: patchConfig.dns.proxyServerNameserver,
          hint: 'https://doh.pub/dns-query',
          onChanged: (v) =>
              _updateDns((dns) => dns.copyWith(proxyServerNameserver: v)),
        ),
      ),
      SettingsRow(
        title: 'Nameserver Policy',
        help: l.nameserverPolicyHelp,
        trailing: SettingsMapEditor(
          title: 'Nameserver Policy',
          value: patchConfig.dns.nameserverPolicy,
          keyHint: 'geosite:cn',
          valueHint: 'https://doh.pub/dns-query',
          onChanged: (v) =>
              _updateDns((dns) => dns.copyWith(nameserverPolicy: v)),
        ),
      ),
    ];
  }

  List<Widget> _networkRows(NetworkProps network) {
    final l = context.appLocalizations;
    return [
      _systemProxyRow(network),
      SettingsRow(
        title: l.appendSystemDns,
        description: l.appendSystemDnsDesc,
        help: l.appendSystemDnsHelp,
        trailing: SettingsSwitch(
          value: network.appendSystemDns,
          onChanged: (v) => ref
              .read(networkSettingProvider.notifier)
              .update((state) => state.copyWith(appendSystemDns: v)),
        ),
      ),
      SettingsRow(
        title: 'Bypass Domain',
        description: l.bypassDomainDesc,
        help: l.bypassDomainHelp,
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

  List<Widget> _appRows(AppSettingProps appSetting, ThemeProps themeProps) {
    final l = context.appLocalizations;
    return [
      SettingsRow(
        title: l.autoRunFork,
        description: l.autoRunForkDesc,
        trailing: SettingsSwitch(
          value: appSetting.autoRun,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(autoRun: v)),
        ),
      ),
      SettingsRow(
        title: l.launchWithSystem,
        help: l.autoLaunchHelp,
        trailing: SettingsSwitch(
          value: appSetting.autoLaunch,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(autoLaunch: v)),
        ),
      ),
      SettingsRow(
        title: l.minimizeOnClose,
        description: l.minimizeOnExitForkDesc,
        trailing: SettingsSwitch(
          value: appSetting.minimizeOnExit,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(minimizeOnExit: v)),
        ),
      ),
      SettingsRow(
        title: l.closeConnectionsExit,
        help: l.closeConnectionsExitHelp,
        trailing: SettingsSwitch(
          value: appSetting.closeConnections,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(closeConnections: v)),
        ),
      ),
      SettingsRow(
        title: l.onlyStatisticsProxy,
        description: l.countTrafficThroughProxy,
        trailing: SettingsSwitch(
          value: appSetting.onlyStatisticsProxy,
          onChanged: (v) => _updateAppSetting(
            (state) => state.copyWith(onlyStatisticsProxy: v),
          ),
        ),
      ),
      SettingsRow(
        title: l.checkUpdatesTitle,
        help: l.checkUpdatesTitleHelp,
        trailing: SettingsSwitch(
          value: appSetting.autoCheckUpdate,
          onChanged: (v) =>
              _updateAppSetting((state) => state.copyWith(autoCheckUpdate: v)),
        ),
      ),
      _themeRow(themeProps),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openAbout,
          child: SettingsRow(
            title: context.appLocalizations.about,
            description: context.appLocalizations.aboutDesc,
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: context.surfaces.text3,
            ),
          ),
        ),
      ),
    ];
  }
}
