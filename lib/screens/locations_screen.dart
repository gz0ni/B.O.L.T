import 'package:flutter/material.dart';

import '../core/mihomo_service.dart';
import '../core/proxy_models.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Первый реальный экран — список локаций, подключённый к живым данным
/// mihomo вместо статики. Группа "🌍 VPN" — та, что пользователь
/// переключает руками, ровно как в макете.
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({
    super.key,
    required this.mihomo,
    this.groupName = '🌍 VPN',
  });

  final MihomoService mihomo;
  final String groupName;

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  ProxySnapshot? _snapshot;
  String? _error;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot = await widget.mihomo.getSnapshot();
      if (!mounted) return;
      setState(() => _snapshot = snapshot);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _select(ProxyNode node) async {
    setState(() => _switching = true);
    try {
      await widget.mihomo.selectProxy(
        group: widget.groupName,
        nodeName: node.name,
      );
      await _load(); // подтягиваем актуальный `now` после переключения
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось переключиться: $e')),
      );
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    if (_error != null) {
      return Center(
        child: Text(
          'Ошибка загрузки: $_error',
          style: TextStyle(color: context.semanticColors.danger),
        ),
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final group = snapshot.groups[widget.groupName];
    final nodes = snapshot.nodesInGroup(widget.groupName);

    return Container(
      color: surfaces.bg,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpace.s4),
        itemCount: nodes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s2),
        itemBuilder: (context, index) {
          final node = nodes[index];
          final isSelected = node.name == group?.now;
          return _LocationTile(
            node: node,
            isSelected: isSelected,
            isBusy: _switching,
            onTap: () => _select(node),
          );
        },
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.node,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
  });

  final ProxyNode node;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    return Material(
      color: isSelected ? surfaces.card2 : surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: isBusy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          child: Row(
            children: [
              _StatusDot(alive: node.alive, semantic: semantic),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Text(
                  node.name,
                  style: TextStyle(
                    color: surfaces.text1,
                    fontSize: AppFontSize.md,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              _DelayLabel(node: node, semantic: semantic),
              if (isSelected) ...[
                const SizedBox(width: AppSpace.s2),
                Icon(Icons.check_circle, size: 18, color: semantic.on),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.alive, required this.semantic});

  final bool alive;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: alive ? semantic.on : semantic.text3Fallback,
      ),
    );
  }
}

// Небольшой хелпер: у AppSemanticColors нет text3 (это surfaces-токен),
// поэтому для "мёртвой" точки берём idle-цвет — семантически он и
// означает "неактивно".
extension on AppSemanticColors {
  Color get text3Fallback => idle;
}

class _DelayLabel extends StatelessWidget {
  const _DelayLabel({required this.node, required this.semantic});

  final ProxyNode node;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    if (!node.alive || node.delayMs == null) {
      return Text(
        'н/д',
        style: TextStyle(color: semantic.danger, fontSize: AppFontSize.sm),
      );
    }
    final delay = node.delayMs!;
    final color = delay < 150
        ? semantic.on
        : delay < 350
            ? semantic.connecting
            : semantic.danger;
    return Text(
      '$delay ms',
      style: TextStyle(color: color, fontSize: AppFontSize.sm),
    );
  }
}