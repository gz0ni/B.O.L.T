import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/connection_controller.dart';
import '../core/logs_controller.dart';
import '../core/mihomo_service.dart';
import '../core/proxy_models.dart';
import '../core/settings_service.dart';
import '../core/subscriptions_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'logs_screen.dart';
import 'power_button.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';

const _defaultGroup = '🌍 VPN';

/// Единственный источник истины для высоты шапки сайдбара (логотип +
/// заголовок "ЛОКАЦИИ"). Используется в двух местах: чтобы отрисовать
/// саму шапку, и чтобы шторка снизу знала, где именно заканчивается
/// "безопасная зона" и начинается поле поиска — без этой синхронизации
/// оба места неизбежно расходятся и получается нахлёст (см. обсуждение).
const double _kSidebarHeaderHeight = 148;

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.mihomo,
    required this.subscriptionsService,
    required this.settingsService,
    required this.logsController,
  });

  final MihomoService mihomo;
  final SubscriptionsService subscriptionsService;
  final SettingsService settingsService;
  final LogsController logsController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ConnectionController _connection;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _connection = ConnectionController(mihomo: widget.mihomo, groupName: _defaultGroup)
      ..addListener(() => setState(() {}));
    _connection.refreshSelectedNode();
  }

  @override
  void dispose() {
    _connection.dispose();
    super.dispose();
  }

  Future<void> _openSheet(Widget child) {
    final surfaces = context.surfaces;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaces.card,
      barrierColor: Colors.black54,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final availableHeight = MediaQuery.of(context).size.height - _kSidebarHeaderHeight;
        return SizedBox(
          height: availableHeight,
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
        );
      },
    );
  }

  void _openSubscriptions() => _openSheet(
        SubscriptionsScreen(
          service: widget.subscriptionsService,
          onClose: () => Navigator.of(context).pop(),
          onActivated: () {
            setState(() => _refreshTick++);
            _connection.refreshSelectedNode();
          },
        ),
      );

  void _openLogs() => _openSheet(
        LogsScreen(
          controller: widget.logsController,
          onClose: () => Navigator.of(context).pop(),
        ),
      );

  void _openSettings() => _openSheet(
        SettingsScreen(
          service: widget.settingsService,
          onClose: () => Navigator.of(context).pop(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Scaffold(
      body: Row(
        children: [
          _LocationsSidebar(
            key: ValueKey(_refreshTick),
            mihomo: widget.mihomo,
            onChanged: _connection.refreshSelectedNode,
          ),
          Container(width: 1, color: surfaces.border),
          Expanded(
            child: _MainArea(
              key: ValueKey(_refreshTick),
              connection: _connection,
              subscriptionsService: widget.subscriptionsService,
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

/// Сайдбар — ровно то, чем он является в макете: список локаций с
/// поиском и избранным, а не общая навигация по разделам приложения.
class _LocationsSidebar extends StatefulWidget {
  const _LocationsSidebar({super.key, required this.mihomo, required this.onChanged});

  final MihomoService mihomo;
  final VoidCallback onChanged;

  @override
  State<_LocationsSidebar> createState() => _LocationsSidebarState();
}

class _LocationsSidebarState extends State<_LocationsSidebar> {
  ProxySnapshot? _snapshot;
  String? _effectiveGroup; // может отличаться от _defaultGroup для сторонних импортированных конфигов
  final _favorites = <String>{};
  final _searchController = TextEditingController();
  String _query = '';
  bool _testingAll = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  Future<void> _load() async {
    try {
      final snapshot = await widget.mihomo.getSnapshot();
      if (!mounted) return;
      String? group;
      if (snapshot.groups.containsKey(_defaultGroup)) {
        group = _defaultGroup;
      } else {
        // Профиль сторонний (или полный конфиг подписки со своими
        // группами) — берём первую группу-селектор, какая найдётся.
        final selector = snapshot.groups.values.where((g) => g.isSelectable);
        group = selector.isNotEmpty ? selector.first.name : null;
      }
      setState(() {
        _snapshot = snapshot;
        _effectiveGroup = group;
      });
    } catch (_) {
      // Тихо — сайдбар просто останется с прошлым списком/пустым
    }
  }

  Future<void> _select(ProxyNode node) async {
    final group = _effectiveGroup;
    if (group == null) return;
    try {
      await widget.mihomo.selectProxy(group: group, nodeName: node.name);
      await _load();
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось переключиться: $e')),
      );
    }
  }

  Future<void> _testAll() async {
    final group = _effectiveGroup;
    if (group == null) return;
    setState(() => _testingAll = true);
    try {
      await widget.mihomo.testGroupDelay(group);
      await _load();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _testingAll = false);
    }
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (_favorites.contains(name)) {
        _favorites.remove(name);
      } else {
        _favorites.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    final group = _effectiveGroup == null ? null : _snapshot?.groups[_effectiveGroup];
    var nodes = _effectiveGroup == null ? <ProxyNode>[] : (_snapshot?.nodesInGroup(_effectiveGroup!) ?? []);
    if (_query.isNotEmpty) {
      nodes = nodes.where((n) => n.name.toLowerCase().contains(_query)).toList();
    }
    // Избранное — наверх списка, порядок внутри групп сохраняем как есть.
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
            child: Row(
              children: [
                Text(
                  'ЛОКАЦИИ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: surfaces.text3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Проверить задержку всех серверов',
                  icon: _testingAll
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.speed, size: 18),
                  onPressed: _testingAll ? null : _testAll,
                ),
              ],
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
            child: _snapshot == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isSelected = node.name == group?.now;
                      final isFav = _favorites.contains(node.name);
                      return _LocationTile(
                        node: node,
                        isSelected: isSelected,
                        isFavorite: isFav,
                        onTap: () => _select(node),
                        onFavoriteTap: () => _toggleFavorite(node.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.node,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final ProxyNode node;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    Color pingColor() {
      if (!node.alive || node.delayMs == null) return semantic.danger;
      final d = node.delayMs!;
      if (d < 150) return semantic.on;
      if (d < 350) return semantic.connecting;
      return semantic.danger;
    }

    return Material(
      color: isSelected ? surfaces.card2 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: AppSpace.s2),
          child: Row(
            children: [
              // Протокол вместо флага страны — реальной геопривязки к
              // серверу у нас пока нет (см. пояснение в чате).
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaces.card2,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  node.type.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: surfaces.text2,
                  ),
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
                    Text(
                      node.type,
                      style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
                    ),
                  ],
                ),
              ),
              Text(
                node.alive && node.delayMs != null ? '${node.delayMs} мс' : 'н/д',
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

/// Правая часть окна — power-button по центру, иконки Логи/Настройки
/// в верхнем правом углу, карточка подписки внизу (клик открывает шторку).
class _MainArea extends StatelessWidget {
  const _MainArea({
    super.key,
    required this.connection,
    required this.subscriptionsService,
    required this.onOpenLogs,
    required this.onOpenSettings,
    required this.onOpenSubscriptions,
  });

  final ConnectionController connection;
  final SubscriptionsService subscriptionsService;
  final VoidCallback onOpenLogs;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSubscriptions;

  String _statusLabel() {
    switch (connection.status) {
      case ConnectionStatus.on:
        return 'Подключено';
      case ConnectionStatus.connecting:
        return 'Подключение...';
      case ConnectionStatus.error:
        return 'Ошибка';
      case ConnectionStatus.idle:
        return 'Отключено';
    }
  }

  String _statusSub() {
    final node = connection.selectedNode;
    switch (connection.status) {
      case ConnectionStatus.on:
        return node != null ? '${node.name} · ${node.delayMs ?? '—'} ms' : '';
      case ConnectionStatus.connecting:
        return 'Проверка сервера...';
      case ConnectionStatus.error:
        return connection.errorMessage ?? 'Не удалось подключиться';
      case ConnectionStatus.idle:
        return 'Нажмите, чтобы подключиться';
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final isOn = connection.status == ConnectionStatus.on;
    final isError = connection.status == ConnectionStatus.error;

    Color statusColor() {
      if (isOn) return semantic.on;
      if (connection.status == ConnectionStatus.connecting) return semantic.connecting;
      if (isError) return semantic.danger;
      return surfaces.text1;
    }

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
          PowerButton(status: connection.status, onTap: connection.toggle),
          const SizedBox(height: AppSpace.s6),
          Text(
            _statusLabel(),
            style: TextStyle(
              fontSize: AppFontSize.xl,
              fontWeight: FontWeight.w600,
              color: statusColor(),
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            _statusSub(),
            style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.sm, fontFamily: 'monospace'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, 0, AppSpace.s4, AppSpace.s3),
            child: _UsageCard(
              subscriptionsService: subscriptionsService,
              onTap: onOpenSubscriptions,
            ),
          ),
          if (isOn) ...[
            Container(height: 1, color: surfaces.border),
            Padding(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: _StatsRow(connection: connection),
            ),
          ] else
            const SizedBox(height: AppSpace.s2),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.connection});
  final ConnectionController connection;

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final isOn = connection.status == ConnectionStatus.on;

    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Приём', value: '0 KB/s')),
        const SizedBox(width: AppSpace.s2),
        Expanded(child: _StatCard(label: 'Отдача', value: '0 KB/s')),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: _StatCard(
            label: 'Время',
            value: isOn ? _formatDuration(connection.elapsed) : '--:--:--',
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          flex: 2,
          child: _IpCard(ip: connection.publicIp),
        ),
      ],
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
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, color: surfaces.text3, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class _IpCard extends StatelessWidget {
  const _IpCard({required this.ip});
  final String? ip;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: AppSpace.s3),
      decoration: BoxDecoration(
        color: surfaces.card,
        border: Border.all(color: surfaces.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('IP', style: TextStyle(fontSize: 10, color: surfaces.text3, letterSpacing: 0.6)),
          const SizedBox(width: AppSpace.s2),
          Flexible(
            child: Text(
              ip ?? '—',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: AppFontSize.sm,
                color: surfaces.text1,
              ),
            ),
          ),
          if (ip != null) ...[
            const SizedBox(width: AppSpace.s1),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: ip!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('IP скопирован')));
                }
              },
              child: Icon(Icons.copy, size: 14, color: surfaces.text3),
            ),
          ],
        ],
      ),
    );
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

/// Карточка подписки внизу главного экрана. Название и клик — реальные.
/// Цифры расхода трафика — ЗАГЛУШКА: у mihomo нет понятия квоты, это
/// метаданные конкретной панели-провайдера, которые мы ещё не запрашиваем.
class _UsageCard extends StatefulWidget {
  const _UsageCard({required this.subscriptionsService, required this.onTap});

  final SubscriptionsService subscriptionsService;
  final VoidCallback onTap;

  @override
  State<_UsageCard> createState() => _UsageCardState();
}

class _UsageCardState extends State<_UsageCard> {
  String? _activeName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final activeId = await widget.subscriptionsService.loadActiveId();
    if (activeId == null) {
      if (mounted) setState(() => _activeName = 'Основной конфиг');
      return;
    }
    final subs = await widget.subscriptionsService.loadSubscriptions();
    final match = subs.where((s) => s.id == activeId);
    if (mounted) {
      setState(() => _activeName = match.isNotEmpty ? match.first.name : 'Основной конфиг');
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s3),
          child: Row(
            children: [
              Icon(Icons.sim_card_outlined, size: 20, color: surfaces.text2),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Text(
                  _activeName ?? '...',
                  style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
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