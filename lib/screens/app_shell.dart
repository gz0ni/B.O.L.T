import 'dart:async';

import 'package:bolt/common/common.dart';
import 'package:bolt/common/format.dart';
import 'package:bolt/core/core.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_editor_screen.dart';
import 'logs_screen.dart';
import 'power_button.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/bolt_icon_button.dart';
import '../widgets/bolt_list.dart';
import '../widgets/bolt_surfaces.dart';

/// Имя группы, которую показываем как список локаций в сайдбаре.
/// Если такой группы нет в текущем профиле (например, у стороннего
/// импортированного конфига группы называются иначе) — берём первую
/// попавшуюся группу-селектор.
const _preferredGroupName = preferredGroupName;

Group? _resolvePreferredGroup(List<Group> groups) {
  final preferred = groups.getGroup(_preferredGroupName);
  if (preferred != null) return preferred;
  for (final g in groups) {
    if (g.type == GroupType.Selector) return g;
  }
  return groups.isNotEmpty ? groups.first : null;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Future<void> _openSheet(Widget child, {String? title}) {
    return showBoltSheet<void>(
      context,
      title: title,
      builder: (sheetContext) => child,
    );
  }

  void _openSubscriptions({bool autoOpenAdd = false}) => _openSheet(
    SubscriptionsScreen(
      onClose: () => Navigator.of(context).pop(),
      autoOpenAdd: autoOpenAdd,
    ),
  );

  void _openLogs() =>
      _openSheet(LogsScreen(onClose: () => Navigator.of(context).pop()));

  void _openSettings() =>
      _openSheet(SettingsScreen(onClose: () => Navigator.of(context).pop()));

  void _openConfigEditor() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) {
      showBoltToast(
        context,
        context.appLocalizations.activateSubscriptionFirst,
      );
      return;
    }
    _openSheet(
      ConfigEditorScreen(
        profileId: profile.id,
        onClose: () => Navigator.of(context).pop(),
      ),
      title: context.appLocalizations.configuration,
    );
  }

  void _openLocations() =>
      _openSheet(const _LocationsSheet());

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final isMobile = system.isAndroid
        ? ref.watch(isMobileViewProvider)
        : ref.watch(appSettingProvider.select((s) => s.forceMobileView));

    return Scaffold(
      body: isMobile
          ? _MobileShell(
              onOpenLogs: _openLogs,
              onOpenSettings: _openSettings,
              onOpenSubscriptions: _openSubscriptions,
              onOpenLocations: _openLocations,
              onAddSubscription: () =>
                  _openSubscriptions(autoOpenAdd: true),
            )
          : Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const _LocationsSidebar(),
                      Container(width: 1, color: surfaces.border),
                      Expanded(
                        child: _MainArea(
                          onOpenLogs: _openLogs,
                          onOpenSettings: _openSettings,
                          onOpenSubscriptions: _openSubscriptions,
                          onOpenConfigEditor: _openConfigEditor,
                          onAddSubscription: () =>
                              _openSubscriptions(autoOpenAdd: true),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: surfaces.border,
                ),
                const _StatsPanel(),
              ],
            ),
    );
  }
}

/// Сайдбар — список локаций текущего профиля с поиском и избранным.
class _LocationsSidebar extends ConsumerStatefulWidget {
  const _LocationsSidebar();

  @override
  ConsumerState<_LocationsSidebar> createState() => _LocationsSidebarState();
}

class _LocationsSidebarState extends ConsumerState<_LocationsSidebar> {
  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      width: 280,
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s5,
              AppSpace.s4,
              AppSpace.s2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: AppSpace.s2),
                Text(
                  'B.O.L.T',
                  style: TextStyle(
                    color: surfaces.text1,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.lg,
                  ),
                ),
                const SizedBox(width: AppSpace.s1),
                Text(
                  'v${globalState.packageInfo.version}'
                  '${globalState.isPre ? '-beta' : ''}',
                  style: TextStyle(
                    color: surfaces.text3,
                    fontSize: AppFontSize.xs,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: _LocationsBody()),
        ],
      ),
    );
  }
}

/// Общее тело списка локаций: заголовок с «проверить все», поиск и список.
/// Используется в десктоп-сайдбаре и в мобильной шторке локаций.
class _LocationsBody extends ConsumerStatefulWidget {
  const _LocationsBody({this.onClose});

  /// Если задан — в шапке появляется кнопка закрытия шторки.
  final VoidCallback? onClose;

  @override
  ConsumerState<_LocationsBody> createState() => _LocationsBodyState();
}

/// Мобильная шторка локаций (переиспользует общее тело списка).
class _LocationsSheet extends ConsumerWidget {
  const _LocationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LocationsBody(onClose: () => Navigator.of(context).pop());
  }
}

class _LocationsBodyState extends ConsumerState<_LocationsBody> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _pingingNodes = <String>{};
  String _query = '';
  bool _pinging = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _testUrl(String? groupTestUrl) {
    return groupTestUrl?.isNotEmpty == true
        ? groupTestUrl!
        : ref.read(appSettingProvider).testUrl;
  }

  Future<void> _pingNode(Proxy node, String? groupTestUrl) async {
    if (_pingingNodes.contains(node.name)) return;
    setState(() => _pingingNodes.add(node.name));
    try {
      await coreController.getDelay(_testUrl(groupTestUrl), node.name);
    } finally {
      if (mounted) setState(() => _pingingNodes.remove(node.name));
    }
  }

  Future<void> _testAllDelays(List<Proxy> nodes, String? groupTestUrl) async {
    if (_pinging || nodes.isEmpty) return;
    setState(() => _pinging = true);
    try {
      final testUrl = _testUrl(groupTestUrl);
      // Пингуем все ноды параллельно: каждая добавляется в _pingingNodes,
      // чтобы тайл показывал спиннер до получения собственного результата.
      final futures = nodes.map((node) async {
        setState(() => _pingingNodes.add(node.name));
        try {
          await coreController.getDelay(testUrl, node.name);
        } finally {
          if (mounted) setState(() => _pingingNodes.remove(node.name));
        }
      });
      await Future.wait(futures);
    } finally {
      if (mounted) setState(() => _pinging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    final groups = ref.watch(currentGroupsStateProvider).value;
    final group = _resolvePreferredGroup(groups);

    final favorites = ref
        .watch(appSettingProvider.select((s) => s.favoriteLocations))
        .toSet();

    var nodes = group?.all ?? const <Proxy>[];
    // Служебные/вложенные группы-обёртки внутри all — оставляем только
    // реальные ноды (без вложенных Selector/URLTest записей).
    nodes = nodes
        .where((p) => p.type != 'Selector' && p.type != 'URLTest')
        .toList();
    if (_query.isNotEmpty) {
      nodes = nodes
          .where((n) => n.name.toLowerCase().contains(_query))
          .toList();
    }
    nodes.sort((a, b) {
      final favA = favorites.contains(a.name) ? 0 : 1;
      final favB = favorites.contains(b.name) ? 0 : 1;
      return favA.compareTo(favB);
    });

    final selectedName = ref.watch(
      currentProfileProvider.select((s) => s?.selectedMap[group?.name]),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
          child: Row(
            children: [
              Text(
                context.appLocalizations.locations,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: surfaces.text3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _pinging
                  ? const SizedBox(
                      width: 34,
                      height: 34,
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    )
                  : BoltIconButton(
                      icon: Icons.bolt,
                      tooltip: context.appLocalizations.testAllServers,
                      onTap: () => _testAllDelays(nodes, group?.testUrl),
                    ),
              if (widget.onClose != null) ...[
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  icon: Icons.close,
                  tooltip: context.appLocalizations.close,
                  onTap: widget.onClose,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.s2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
            decoration: InputDecoration(
              hintText: context.appLocalizations.searchLocations,
              hintStyle: TextStyle(
                color: surfaces.text3,
                fontSize: AppFontSize.sm,
              ),
              prefixIcon: Icon(Icons.search, size: 18, color: surfaces.text3),
              filled: true,
              fillColor: surfaces.card2,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s2),
        Expanded(
          child: group == null
              ? Center(
                  child: Text(
                    context.appLocalizations.noLocationsAvailable,
                    style: TextStyle(color: surfaces.text3),
                  ),
                )
              : Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s3,
                      0,
                      AppSpace.s3,
                      AppSpace.s2,
                    ),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isSelected = node.name == selectedName;
                      final isFav = favorites.contains(node.name);
                      return _LocationTile(
                        node: node,
                        groupName: group.name,
                        testUrl: group.testUrl,
                        isSelected: isSelected,
                        isFavorite: isFav,
                        isPinging: _pingingNodes.contains(node.name),
                        onPingTap: () => _pingNode(node, group.testUrl),
                        onFavoriteTap: () {
                          ref
                              .read(appSettingProvider.notifier)
                              .update((state) {
                                final current = List<String>.from(
                                  state.favoriteLocations,
                                );
                                if (isFav) {
                                  current.remove(node.name);
                                } else {
                                  current.add(node.name);
                                }
                                return state.copyWith(
                                  favoriteLocations: current,
                                );
                              });
                          ref
                              .read(storeActionProvider.notifier)
                              .savePreferencesDebounce();
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _LocationTile extends ConsumerWidget {
  const _LocationTile({
    required this.node,
    required this.groupName,
    required this.testUrl,
    required this.isSelected,
    required this.isFavorite,
    required this.isPinging,
    required this.onPingTap,
    required this.onFavoriteTap,
  });

  final Proxy node;
  final String groupName;
  final String? testUrl;
  final bool isSelected;
  final bool isFavorite;
  final bool isPinging;
  final VoidCallback onPingTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final delayMs = ref.watch(
      delayProvider(proxyName: node.name, testUrl: testUrl),
    );

    Color pingColor() {
      if (delayMs == null) return surfaces.text3;
      if (delayMs <= 0) return semantic.danger;
      if (delayMs < 150) return semantic.on;
      if (delayMs < 350) return semantic.connecting;
      return semantic.danger;
    }

    return Material(
      color: isSelected ? surfaces.card2 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () {
          ref
              .read(proxiesActionProvider.notifier)
              .changeProxyDebounce(groupName, node.name);
          ref
              .read(profilesActionProvider.notifier)
              .updateCurrentSelectedMap(groupName, node.name);
          ref
              .read(proxiesActionProvider.notifier)
              .updateCurrentGroupName(groupName);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: AppSpace.s2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MarqueeText(
                      node.name,
                      style: TextStyle(
                        color: surfaces.text1,
                        fontSize: AppFontSize.sm,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    Text(
                      node.type,
                      style: TextStyle(
                        color: surfaces.text3,
                        fontSize: AppFontSize.xs,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isPinging ? null : onPingTap,
                child: SizedBox(
                  width: 44,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: AppMotion.ease,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: isPinging
                          ? SizedBox(
                              key: const ValueKey('pinging'),
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(semantic.on),
                              ),
                            )
                          : Text(
                              delayMs == null
                                  ? '...'
                                  : (delayMs <= 0
                                        ? 'n/a'
                                        : '$delayMs мс'),
                              key: ValueKey(delayMs ?? -1),
                              style: TextStyle(
                                color: pingColor(),
                                fontSize: AppFontSize.xs,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              BoltIconButton(
                icon: isFavorite ? Icons.star : Icons.star_border,
                tooltip: isFavorite
                    ? context.appLocalizations.removeFromFavorites
                    : context.appLocalizations.addToFavorites,
                color: isFavorite ? semantic.connecting : surfaces.text3,
                onTap: onFavoriteTap,
              ),
              const SizedBox(width: AppSpace.s2),
              BoltCheck(active: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Текст с многоточием, если не влезает в доступную ширину.
class _MarqueeText extends StatelessWidget {
  const _MarqueeText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Правая часть — power-button, статус, карточка подписки (с реальными
/// цифрами трафика из SubscriptionInfo), статистика скорости и IP.
class _MainArea extends ConsumerWidget {
  const _MainArea({
    required this.onOpenLogs,
    required this.onOpenSettings,
    required this.onOpenSubscriptions,
    required this.onOpenConfigEditor,
    required this.onAddSubscription,
  });

  final VoidCallback onOpenLogs;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSubscriptions;
  final VoidCallback onOpenConfigEditor;
  final VoidCallback onAddSubscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;

    final isStart = ref.watch(isStartProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final hasProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final currentGroup = _resolvePreferredGroup(
      ref.watch(currentGroupsStateProvider).value,
    );
    final currentSelected = currentGroup == null
        ? null
        : currentProfile?.selectedMap[currentGroup.name];

    final status = !isStart
        ? (ref.watch(isTransitioningProvider)
              ? ConnectionStatus.connecting
              : ConnectionStatus.idle)
        : ConnectionStatus.on;

    return Container(
      color: surfaces.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BoltIconButton(
                  icon: Icons.terminal,
                  tooltip: l.logs,
                  onTap: onOpenLogs,
                ),
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  icon: Icons.code,
                  tooltip: context.appLocalizations.configEditor,
                  onTap: onOpenConfigEditor,
                ),
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  icon: Icons.settings,
                  tooltip: l.settings,
                  onTap: onOpenSettings,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (hasProfiles) ...[
            PowerButton(
              status: status,
              onTap: () =>
                  ref.read(commonActionProvider.notifier).updateStart(),
            ),
            const SizedBox(height: AppSpace.s6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              switchInCurve: AppMotion.ease,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                isStart ? l.connected : l.disconnected,
                key: ValueKey(isStart),
                style: TextStyle(
                  fontSize: AppFontSize.xl,
                  fontWeight: FontWeight.w600,
                  color: isStart ? semantic.on : surfaces.text1,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s2),
            AnimatedSwitcher(
              duration: AppMotion.base,
              switchInCurve: AppMotion.ease,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                isStart
                    ? (currentSelected?.isNotEmpty == true
                          ? currentSelected!
                          : '—')
                    : l.pressToConnect,
                key: ValueKey(isStart ? currentSelected : 'idle'),
                style: TextStyle(
                  color: surfaces.text3,
                  fontSize: AppFontSize.sm,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ] else ...[
            _AddSubscriptionButton(onTap: onAddSubscription),
            const SizedBox(height: AppSpace.s6),
            Text(
              l.addSubscription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.xl,
                fontWeight: FontWeight.w600,
                color: surfaces.text1,
              ),
            ),
            const SizedBox(height: AppSpace.s2),
            Text(
              l.pressToAddConfig,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: surfaces.text3,
                fontSize: AppFontSize.sm,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const Spacer(),
          if (hasProfiles)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s4,
                0,
                AppSpace.s4,
                AppSpace.s3,
              ),
              child: SizedBox(
                width: double.infinity,
                child: _UsageCard(
                  profile: currentProfile,
                  onTap: onOpenSubscriptions,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Кнопка «+» на месте кнопки питания, когда конфигов нет вообще.
class _AddSubscriptionButton extends StatelessWidget {
  const _AddSubscriptionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return SizedBox(
      width: 208,
      height: 208,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: AppMotion.slow,
              curve: AppMotion.ease,
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.36, -0.44),
                  radius: 0.9,
                  colors: [surfaces.card2, surfaces.card],
                  stops: const [0.0, 0.7],
                ),
                border: Border.all(color: surfaces.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.add, size: 54, color: semantic.on),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Мобильная раскладка (Android): topbar с брендом, пилюли локации и
/// подписки, power-кнопка, футер со статистикой при подключении.
class _MobileShell extends ConsumerWidget {
  const _MobileShell({
    required this.onOpenLogs,
    required this.onOpenSettings,
    required this.onOpenSubscriptions,
    required this.onOpenLocations,
    required this.onAddSubscription,
  });

  final VoidCallback onOpenLogs;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSubscriptions;
  final VoidCallback onOpenLocations;
  final VoidCallback onAddSubscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final isStart = ref.watch(isStartProvider);

    return Column(
      children: [
        _MobileTopBar(onOpenLogs: onOpenLogs, onOpenSettings: onOpenSettings),
        Expanded(
          child: hasProfiles
              ? _MobileMainArea(
                  onOpenLocations: onOpenLocations,
                  onOpenSubscriptions: onOpenSubscriptions,
                )
              : _MobileEmptyState(onAddSubscription: onAddSubscription),
        ),
        if (hasProfiles) _MobileFooter(isStart: isStart),
      ],
    );
  }
}

/// Верхняя панель: бренд-марка с цветом состояния + иконки логов/настроек.
class _MobileTopBar extends ConsumerWidget {
  const _MobileTopBar({
    required this.onOpenLogs,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenLogs;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;

    final isStart = ref.watch(isStartProvider);
    final isTransitioning = ref.watch(isTransitioningProvider);
    final markColor = isStart
        ? semantic.on
        : isTransitioning
            ? semantic.connecting
            : semantic.idle;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s5,
          AppSpace.s5,
          AppSpace.s5,
          6,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: surfaces.card,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: markColor),
                boxShadow: isStart
                    ? [
                        BoxShadow(
                          color: semantic.onDim,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Image.asset(
                'assets/images/icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: AppSpace.s2 + 1),
            Text(
              'B.O.L.T',
              style: TextStyle(
                fontFamily: AppFontFamily.display,
                fontSize: AppFontSize.xl,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08,
                color: surfaces.text1,
              ),
            ),
            const Spacer(),
            BoltIconButton(
              icon: Icons.terminal,
              tooltip: l.logs,
              onTap: onOpenLogs,
              boxSize: 38,
            ),
            const SizedBox(width: AppSpace.s2),
            BoltIconButton(
              icon: Icons.settings,
              tooltip: l.settings,
              onTap: onOpenSettings,
              boxSize: 38,
            ),
          ],
        ),
      ),
    );
  }
}

/// Центральная область мобильного экрана: пилюля локации, power-кнопка
/// со статусом и пилюля подписки.
class _MobileMainArea extends ConsumerWidget {
  const _MobileMainArea({
    required this.onOpenLocations,
    required this.onOpenSubscriptions,
  });

  final VoidCallback onOpenLocations;
  final VoidCallback onOpenSubscriptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;

    final isStart = ref.watch(isStartProvider);
    final isTransitioning = ref.watch(isTransitioningProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final currentGroup = _resolvePreferredGroup(
      ref.watch(currentGroupsStateProvider).value,
    );
    final currentSelected = currentGroup == null
        ? null
        : currentProfile?.selectedMap[currentGroup.name];

    final status = !isStart
        ? (isTransitioning
              ? ConnectionStatus.connecting
              : ConnectionStatus.idle)
        : ConnectionStatus.on;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s5,
            AppSpace.s4 - 2,
            AppSpace.s5,
            0,
          ),
          child: _MobileLocationPill(
            selectedName: currentSelected,
            testUrl: currentGroup?.testUrl,
            onTap: onOpenLocations,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PowerButton(
                status: status,
                onTap: () =>
                    ref.read(commonActionProvider.notifier).updateStart(),
              ),
              const SizedBox(height: AppSpace.s6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: AppMotion.ease,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  isStart ? l.connected : l.disconnected,
                  key: ValueKey(isStart),
                  style: TextStyle(
                    fontSize: AppFontSize.xl,
                    fontWeight: FontWeight.w600,
                    color: isStart ? semantic.on : surfaces.text1,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s2),
              AnimatedSwitcher(
                duration: AppMotion.base,
                switchInCurve: AppMotion.ease,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  isStart
                      ? (currentSelected?.isNotEmpty == true
                            ? currentSelected!
                            : '—')
                      : l.pressToConnect,
                  key: ValueKey(isStart ? currentSelected : 'idle'),
                  style: TextStyle(
                    color: surfaces.text3,
                    fontSize: AppFontSize.sm,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s5,
            0,
            AppSpace.s5,
            AppSpace.s3,
          ),
          child: _MobileSubscriptionPill(
            profile: currentProfile,
            onTap: onOpenSubscriptions,
          ),
        ),
      ],
    );
  }
}

/// Empty-состояние: кнопка «+» и подсказка добавить подписку.
class _MobileEmptyState extends ConsumerWidget {
  const _MobileEmptyState({required this.onAddSubscription});

  final VoidCallback onAddSubscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final l = context.appLocalizations;
    return Column(
      children: [
        const Spacer(),
        _AddSubscriptionButton(onTap: onAddSubscription),
        const SizedBox(height: AppSpace.s6),
        Text(
          l.addSubscription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSize.xl,
            fontWeight: FontWeight.w600,
            color: surfaces.text1,
          ),
        ),
        const SizedBox(height: AppSpace.s2),
        Text(
          l.pressToAddConfig,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: surfaces.text3,
            fontSize: AppFontSize.sm,
            fontFamily: 'monospace',
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// Пилюля «Локация»: выбранная нода + задержка с цветной точкой.
class _MobileLocationPill extends ConsumerWidget {
  const _MobileLocationPill({
    required this.selectedName,
    required this.testUrl,
    required this.onTap,
  });

  final String? selectedName;
  final String? testUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final delayMs = selectedName == null
        ? null
        : ref.watch(delayProvider(proxyName: selectedName!, testUrl: testUrl));

    String pingText() {
      if (delayMs == null) return '...';
      if (delayMs <= 0) return 'n/a';
      return '$delayMs мс';
    }

    Color pingColor() {
      if (delayMs == null) return surfaces.text3;
      if (delayMs <= 0) return semantic.danger;
      if (delayMs < 150) return semantic.on;
      if (delayMs < 350) return semantic.connecting;
      return semantic.danger;
    }

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: surfaces.card2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, size: 17, color: surfaces.text2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedName?.isNotEmpty == true
                          ? selectedName!
                          : '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontSize.lg,
                        fontWeight: FontWeight.w600,
                        color: surfaces.text1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pingColor(),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          pingText(),
                          style: TextStyle(
                            fontSize: 14,
                            color: surfaces.text2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: surfaces.text3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Пилюля «Подписка»: имя профиля + расход трафика и прогресс-бар снизу.
class _MobileSubscriptionPill extends ConsumerWidget {
  const _MobileSubscriptionPill({required this.profile, required this.onTap});

  final Profile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;

    final info = profile?.subscriptionInfo;
    final used = info == null ? 0 : info.upload + info.download;
    final summary = usageSummary(info);

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: surfaces.card2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sim_card_outlined,
                      size: 17,
                      color: surfaces.text2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.label.isNotEmpty == true
                              ? profile!.label
                              : l.noActiveSubscription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFontSize.lg,
                            fontWeight: FontWeight.w600,
                            color: surfaces.text1,
                          ),
                        ),
                        if (summary != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: surfaces.text2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: surfaces.text3),
                ],
              ),
            ),
            if (info != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: info.total > 0
                      ? (used / info.total).clamp(0, 1)
                      : 1.0,
                  minHeight: 2,
                  backgroundColor: surfaces.borderSoft,
                  valueColor: AlwaysStoppedAnimation(semantic.on),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Мобильный футер: три стата (Приём/Отдача/Время) и строка IP.
/// Статичная панель: видна всегда, при выключенном VPN значения приглушены.
class _MobileFooter extends ConsumerStatefulWidget {
  const _MobileFooter({required this.isStart});

  final bool isStart;

  @override
  ConsumerState<_MobileFooter> createState() => _MobileFooterState();
}

class _MobileFooterState extends ConsumerState<_MobileFooter> {
  Timer? _copyTimer;
  bool _copied = false;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyIp(String ip) async {
    await Clipboard.setData(ClipboardData(text: ip));
    if (!mounted) return;
    _copyTimer?.cancel();
    setState(() => _copied = true);
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;

    final isStart = widget.isStart;
    final dimmed = !isStart;
    final traffic = ref.watch(trafficsProvider).list.safeLast(const Traffic());
    final runTime = ref.watch(runTimeProvider);
    final ipInfo = ref.watch(networkDetectionProvider).ipInfo;

    return SafeArea(
      top: false,
      child: Container(
        color: surfaces.bgSoft,
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s5,
          AppSpace.s3,
          AppSpace.s5,
          AppSpace.s4,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MobileStatCard(
                    label: l.statReceive,
                    value: '${traffic.down.traffic.show}/s',
                    dimmed: dimmed,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                Expanded(
                  child: _MobileStatCard(
                    label: l.statTransmit,
                    value: '${traffic.up.traffic.show}/s',
                    dimmed: dimmed,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                Expanded(
                  child: _MobileStatCard(
                    label: l.statTime,
                    value: _formatRunTime(runTime),
                    dimmed: dimmed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ipInfo?.countryCode ?? 'IP',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.05,
                    color: surfaces.text3,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                Text(
                  ipInfo?.ip ?? '—',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: AppFontSize.sm,
                    fontWeight: FontWeight.w500,
                    color: dimmed ? surfaces.text3 : surfaces.text1,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                Material(
                  color: surfaces.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: surfaces.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: !dimmed && ipInfo != null
                        ? () => _copyIp(ipInfo.ip)
                        : null,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 12,
                        color: dimmed
                            ? surfaces.text3
                            : _copied
                            ? semantic.on
                            : surfaces.text2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка стата мобильного футера: значение + подпись.
class _MobileStatCard extends StatelessWidget {
  const _MobileStatCard({
    required this.label,
    required this.value,
    this.dimmed = false,
  });

  final String label;
  final String value;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: surfaces.card,
        border: Border.all(color: surfaces.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: dimmed ? surfaces.text3 : surfaces.text1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.6,
              color: surfaces.text3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Нижняя панель статистики на всю ширину окна.
class _StatsPanel extends ConsumerStatefulWidget {
  const _StatsPanel();

  @override
  ConsumerState<_StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends ConsumerState<_StatsPanel> {
  Timer? _copyTimer;
  bool _copied = false;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyIp(String ip) async {
    await Clipboard.setData(ClipboardData(text: ip));
    if (!mounted) return;
    _copyTimer?.cancel();
    setState(() => _copied = true);
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final l = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    final traffic = ref.watch(trafficsProvider).list.safeLast(const Traffic());
    final runTime = ref.watch(runTimeProvider);
    final ipInfo = ref.watch(networkDetectionProvider).ipInfo;

    return Container(
      color: surfaces.bgSoft,
      padding: const EdgeInsets.all(AppSpace.s3),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l.statReceive,
              value: isStart ? '${traffic.down.traffic.show}/s' : '—',
              dimmed: !isStart,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: _StatCard(
              label: l.statTransmit,
              value: isStart ? '${traffic.up.traffic.show}/s' : '—',
              dimmed: !isStart,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: _StatCard(
              label: l.statTime,
              value: isStart ? _formatRunTime(runTime) : '—',
              dimmed: !isStart,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: _StatCard(
              label: ipInfo?.countryCode ?? 'IP',
              value: isStart ? (ipInfo?.ip ?? '—') : '—',
              dimmed: !isStart || ipInfo == null,
              showCopied: _copied,
              onCopy: isStart && ipInfo != null
                  ? () => _copyIp(ipInfo.ip)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRunTime(int? runTimeMs) {
  if (runTimeMs == null) return '--:--:--';
  final d = Duration(milliseconds: runTimeMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.profile, required this.onTap});
  final Profile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;
    final info = profile?.subscriptionInfo;
    final used = info == null ? 0 : info.upload + info.download;
    final usageTooltipText = usageTooltip(info);

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.s3),
              child: Row(
                children: [
                  Icon(
                    Icons.sim_card_outlined,
                    size: 18,
                    color: surfaces.text2,
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Text(
                      profile?.label.isNotEmpty == true
                          ? profile!.label
                          : l.noActiveSubscription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: surfaces.text1,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                  ),
                  if (profile?.type == ProfileType.url) ...[
                    const SizedBox(width: AppSpace.s2),
                    BoltIconButton(
                      tooltip: usageTooltipText ?? l.noTrafficData,
                      onTap: null,
                      icon: Icons.data_usage,
                      color: surfaces.text3,
                    ),
                  ],
                  const SizedBox(width: AppSpace.s2),
                  Icon(Icons.chevron_right, size: 16, color: surfaces.text3),
                ],
              ),
            ),
            if (info != null && (info.total > 0 || used > 0))
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: info.total > 0 ? (used / info.total).clamp(0, 1) : 1.0,
                  minHeight: 2,
                  backgroundColor: surfaces.borderSoft,
                  valueColor: AlwaysStoppedAnimation(semantic.on),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.dimmed = false,
    this.showCopied = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool dimmed;
  final bool showCopied;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final l = context.appLocalizations;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s3),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onCopy != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: showCopied
                      ? Icon(
                          Icons.check,
                          key: const ValueKey('copied'),
                          size: 12,
                          color: semantic.on,
                        )
                      : Icon(
                          Icons.copy,
                          key: const ValueKey('copy'),
                          size: 11,
                          color: surfaces.text3,
                        ),
                ),
              if (onCopy != null) const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: AppFontSize.sm,
                  color: dimmed ? surfaces.text3 : surfaces.text1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: surfaces.text3,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
    final card = Material(
      color: surfaces.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: surfaces.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onCopy, child: content),
    );
    if (onCopy == null) return card;
    return Tooltip(message: l.copyIp, child: card);
  }
}
