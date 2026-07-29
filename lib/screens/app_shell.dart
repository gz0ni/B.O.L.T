import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logs_screen.dart';
import 'power_button.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Имя группы, которую показываем как список локаций в сайдбаре.
/// Если такой группы нет в текущем профиле (например, у стороннего
/// импортированного конфига группы называются иначе) — берём первую
/// попавшуюся группу-селектор.
const _preferredGroupName = '🌍 VPN';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Future<void> _openSheet(Widget child) {
    final surfaces = context.surfaces;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaces.card,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      barrierColor: Colors.black54,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 1,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: surfaces.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  void _openSubscriptions() =>
      _openSheet(SubscriptionsScreen(onClose: () => Navigator.of(context).pop()));

  void _openLogs() => _openSheet(LogsScreen(onClose: () => Navigator.of(context).pop()));

  void _openSettings() =>
      _openSheet(SettingsScreen(onClose: () => Navigator.of(context).pop()));

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Scaffold(
      body: Row(
        children: [
          const _LocationsSidebar(),
          Container(width: 1, color: surfaces.border),
          Expanded(
            child: _MainArea(
              onOpenLogs: _openLogs,
              onOpenSettings: _openSettings,
              onOpenSubscriptions: _openSubscriptions,
            ),
          ),
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
  final _favorites = <String>{}; // локальный UI-стейт, не персистится
  final _searchController = TextEditingController();
  String _query = '';

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
    super.dispose();
  }

  Group? _resolveGroup(List<Group> groups) {
    final preferred = groups.getGroup(_preferredGroupName);
    if (preferred != null) return preferred;
    for (final g in groups) {
      if (g.type == GroupType.Selector) return g;
    }
    return groups.isNotEmpty ? groups.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final groups = ref.watch(currentGroupsStateProvider).value;
    final group = _resolveGroup(groups);

    var nodes = group?.all ?? const <Proxy>[];
    // Служебные/вложенные группы-обёртки внутри all — оставляем только
    // реальные ноды (без вложенных Selector/URLTest записей).
    nodes = nodes.where((p) => p.type != 'Selector' && p.type != 'URLTest').toList();
    if (_query.isNotEmpty) {
      nodes = nodes.where((n) => n.name.toLowerCase().contains(_query)).toList();
    }
    nodes.sort((a, b) {
      final favA = _favorites.contains(a.name) ? 0 : 1;
      final favB = _favorites.contains(b.name) ? 0 : 1;
      return favA.compareTo(favB);
    });

    return Container(
      width: 280,
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s5, AppSpace.s4, AppSpace.s2),
            child: Row(
              children: [
                Icon(Icons.bolt, color: semantic.on, size: 22),
                const SizedBox(width: AppSpace.s2),
                Text(
                  'B.O.L.T',
                  style: TextStyle(
                    color: surfaces.text1,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.lg,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            child: Text(
              'ЛОКАЦИИ',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                color: surfaces.text3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
              decoration: InputDecoration(
                hintText: 'Поиск локации...',
                hintStyle: TextStyle(color: surfaces.text3, fontSize: AppFontSize.sm),
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
                    child: Text('Нет доступных локаций',
                        style: TextStyle(color: surfaces.text3)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isSelected = node.name == group.realNow;
                      final isFav = _favorites.contains(node.name);
                      return _LocationTile(
                        node: node,
                        groupName: group.name,
                        testUrl: group.testUrl,
                        isSelected: isSelected,
                        isFavorite: isFav,
                        onFavoriteTap: () => setState(() {
                          if (isFav) {
                            _favorites.remove(node.name);
                          } else {
                            _favorites.add(node.name);
                          }
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
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
    required this.onFavoriteTap,
  });

  final Proxy node;
  final String groupName;
  final String? testUrl;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final delayMs = ref.watch(delayProvider(proxyName: node.name, testUrl: testUrl));

    Color pingColor() {
      if (delayMs == null) return surfaces.text3;
      if (delayMs == 0) return semantic.danger;
      if (delayMs < 150) return semantic.on;
      if (delayMs < 350) return semantic.connecting;
      return semantic.danger;
    }

    return Material(
      color: isSelected ? surfaces.card2 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => ref
            .read(profilesActionProvider.notifier)
            .updateCurrentSelectedMap(groupName, node.name),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: AppSpace.s2),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaces.card2,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  node.type.length >= 2 ? node.type.substring(0, 2).toUpperCase() : node.type,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: surfaces.text2),
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: surfaces.text1,
                        fontSize: AppFontSize.sm,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    Text(node.type, style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs)),
                  ],
                ),
              ),
              Text(
                delayMs == null ? '...' : (delayMs == 0 ? 'н/д' : '$delayMs мс'),
                style: TextStyle(color: pingColor(), fontSize: AppFontSize.xs),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 16,
                  color: isFavorite ? semantic.connecting : surfaces.text3,
                ),
                onPressed: onFavoriteTap,
                visualDensity: VisualDensity.compact,
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? semantic.on : Colors.transparent,
                  border: Border.all(color: isSelected ? semantic.on : surfaces.border, width: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
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
  });

  final VoidCallback onOpenLogs;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSubscriptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final isStart = ref.watch(isStartProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final traffic = ref.watch(trafficsProvider).lastOrNull;
    final runTime = ref.watch(runTimeProvider);

    final status = isStart ? ConnectionStatus.on : ConnectionStatus.idle;

    return Container(
      color: surfaces.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconGhostButton(icon: Icons.terminal, tooltip: 'Логи ядра', onTap: onOpenLogs),
                const SizedBox(width: AppSpace.s2),
                _IconGhostButton(icon: Icons.settings, tooltip: 'Настройки', onTap: onOpenSettings),
              ],
            ),
          ),
          const Spacer(),
          PowerButton(
            status: status,
            onTap: () => ref.read(commonActionProvider.notifier).updateStart(),
          ),
          const SizedBox(height: AppSpace.s6),
          Text(
            isStart ? 'Подключено' : 'Отключено',
            style: TextStyle(
              fontSize: AppFontSize.xl,
              fontWeight: FontWeight.w600,
              color: isStart ? semantic.on : surfaces.text1,
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            isStart ? (currentProfile?.currentGroupName ?? '') : 'Нажмите, чтобы подключиться',
            style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.sm, fontFamily: 'monospace'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, 0, AppSpace.s4, AppSpace.s3),
            child: _UsageCard(profile: currentProfile, onTap: onOpenSubscriptions),
          ),
          if (isStart) ...[
            Container(height: 1, color: surfaces.border),
            Padding(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Скорость',
                      value: (traffic ?? const Traffic()).speedText,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(child: _StatCard(label: 'Время', value: _formatRunTime(runTime))),
                ],
              ),
            ),
          ] else
            const SizedBox(height: AppSpace.s2),
        ],
      ),
    );
  }

  static String _formatRunTime(int? runTimeMs) {
    if (runTimeMs == null) return '--:--:--';
    final d = Duration(milliseconds: runTimeMs);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}

class _IconGhostButton extends StatelessWidget {
  const _IconGhostButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Material(
      color: surfaces.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        side: BorderSide(color: surfaces.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s2),
          child: Icon(icon, size: 18, color: surfaces.text2),
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.profile, required this.onTap});
  final Profile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final info = profile?.subscriptionInfo;

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s3),
          child: Row(
            children: [
              Icon(Icons.sim_card_outlined, size: 20, color: surfaces.text2),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.label.isNotEmpty == true ? profile!.label : 'Нет активной подписки',
                      style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
                    ),
                    if (info != null && info.total > 0) ...[
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: ((info.upload + info.download) / info.total).clamp(0, 1),
                          minHeight: 3,
                          backgroundColor: surfaces.card2,
                          valueColor: AlwaysStoppedAnimation(semantic.on),
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s3),
      decoration: BoxDecoration(
        color: surfaces.card,
        border: Border.all(color: surfaces.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: AppFontSize.sm,
              color: surfaces.text1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: surfaces.text3, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}