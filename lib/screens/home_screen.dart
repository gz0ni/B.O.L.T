import 'package:flutter/material.dart';

import '../core/connection_controller.dart';
import '../core/mihomo_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import 'power_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.mihomo,
    this.groupName = '🌍 VPN',
  });

  final MihomoService mihomo;
  final String groupName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ConnectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConnectionController(
      mihomo: widget.mihomo,
      groupName: widget.groupName,
    )..addListener(_onChange);
    _controller.refreshSelectedNode();
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  String _statusLabel() {
    switch (_controller.status) {
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
    final node = _controller.selectedNode;
    switch (_controller.status) {
      case ConnectionStatus.on:
        return node != null
            ? '${node.name} · ${node.delayMs ?? '—'} ms'
            : '';
      case ConnectionStatus.connecting:
        return 'Проверка сервера...';
      case ConnectionStatus.error:
        return _controller.errorMessage ?? 'Не удалось подключиться';
      case ConnectionStatus.idle:
        return 'Нажмите, чтобы подключиться';
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final node = _controller.selectedNode;
    final isOn = _controller.status == ConnectionStatus.on;
    final isError = _controller.status == ConnectionStatus.error;

    Color statusColor() {
      if (isOn) return semantic.on;
      if (_controller.status == ConnectionStatus.connecting) {
        return semantic.connecting;
      }
      if (isError) return semantic.danger;
      return surfaces.text1;
    }

    return Container(
      color: surfaces.bg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s5,
        vertical: AppSpace.s6,
      ),
      child: Column(
        children: [
          // info-pill — текущая выбранная локация
          if (node != null) _LocationPill(name: node.name, pingMs: node.delayMs),

          const Spacer(),

          PowerButton(
            status: _controller.status,
            onTap: _controller.toggle,
          ),
          const SizedBox(height: AppSpace.s6),
          AnimatedDefaultTextStyle(
            duration: AppMotion.base,
            curve: AppMotion.ease,
            style: TextStyle(
              fontSize: AppFontSize.xl,
              fontWeight: FontWeight.w600,
              color: statusColor(),
            ),
            child: Text(_statusLabel()),
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            _statusSub(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: AppFontSize.sm,
              color: surfaces.text3,
            ),
          ),
          if (isError) ...[
            const SizedBox(height: AppSpace.s3),
            TextButton(
              onPressed: _controller.toggle,
              child: const Text('Повторить'),
            ),
          ],

          const Spacer(),

          // stats-row — появляется только в состоянии "on"
          AnimatedOpacity(
            duration: AppMotion.base,
            opacity: isOn ? 1 : 0,
            child: Row(
              children: [
                Expanded(child: _StatCard(label: 'Приём', value: '0 KB/s')),
                const SizedBox(width: AppSpace.s2),
                Expanded(child: _StatCard(label: 'Отдача', value: '0 KB/s')),
                const SizedBox(width: AppSpace.s2),
                Expanded(
                  child: _StatCard(
                    label: 'Время',
                    value: _formatDuration(_controller.elapsed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.name, required this.pingMs});

  final String name;
  final int? pingMs;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s3,
        vertical: AppSpace.s2,
      ),
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: surfaces.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: semantic.on),
          ),
          const SizedBox(width: AppSpace.s2),
          Text(
            name,
            style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md),
          ),
          const SizedBox(width: AppSpace.s1),
          if (pingMs != null)
            Text(
              '$pingMs ms',
              style: TextStyle(color: surfaces.text2, fontSize: AppFontSize.sm),
            ),
        ],
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
          const SizedBox(height: AppSpace.s1),
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
  }
}