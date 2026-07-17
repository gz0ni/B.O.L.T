import 'package:flutter/material.dart';

import '../core/subscriptions_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, required this.service});

  final SubscriptionsService service;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subs = [];
  bool _loading = true;
  String? _busyId; // id подписки, которая сейчас обновляется/удаляется

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subs = await widget.service.loadSubscriptions();
    if (!mounted) return;
    setState(() {
      _subs = subs;
      _loading = false;
    });
  }

  Future<void> _openAddDialog() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить подписку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: AppSpace.s3),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Ссылка подписки'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (nameController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
      return;
    }

    await _addOrRefresh(
      name: nameController.text.trim(),
      url: urlController.text.trim(),
    );
  }

  Future<void> _addOrRefresh({required String name, required String url}) async {
    setState(() => _busyId = name);
    try {
      final count = await widget.service.addOrRefresh(name: name, url: url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Подписка "$name": добавлено серверов — $count')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(Subscription sub) async {
    setState(() => _busyId = sub.id);
    try {
      await widget.service.remove(sub);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось удалить: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Container(
      color: surfaces.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Row(
              children: [
                Text(
                  'Подписки',
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    color: surfaces.text1,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _subs.isEmpty
                    ? _EmptyState(onAdd: _openAddDialog)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                        itemCount: _subs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s2),
                        itemBuilder: (context, index) {
                          final sub = _subs[index];
                          final busy = _busyId == sub.id || _busyId == sub.name;
                          return _SubscriptionTile(
                            subscription: sub,
                            busy: busy,
                            onRefresh: () => _addOrRefresh(name: sub.name, url: sub.url),
                            onDelete: () => _remove(sub),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.subscription,
    required this.busy,
    required this.onRefresh,
    required this.onDelete,
  });

  final Subscription subscription;
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s3),
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: surfaces.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md),
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: onRefresh,
              tooltip: 'Обновить',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: context.semanticColors.danger),
              onPressed: onDelete,
              tooltip: 'Удалить',
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: surfaces.text3),
          const SizedBox(height: AppSpace.s3),
          Text(
            'Нет добавленных подписок',
            style: TextStyle(color: surfaces.text2, fontSize: AppFontSize.md),
          ),
          const SizedBox(height: AppSpace.s3),
          FilledButton(onPressed: onAdd, child: const Text('Добавить первую')),
        ],
      ),
    );
  }
}