import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/logs_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key, required this.controller, this.onClose});

  final LogsController controller;
  final VoidCallback? onClose;

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _scrollController = ScrollController();
  bool _autoscroll = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    if (!widget.controller.connected) {
      widget.controller.connect();
    }
  }

  void _onUpdate() {
    setState(() {});
    if (_autoscroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    // Соединение НЕ закрываем здесь намеренно, если LogsController
    // передаётся сверху и переиспользуется между заходами на экран —
    // владелец жизненного цикла явно решает через disconnect().
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyAll() async {
    final c = widget.controller;
    final text = c.filtered
        .map((e) {
          final time =
              '${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}:${e.time.second.toString().padLeft(2, '0')}';
          return '$time ${_levelLabel(e.level)} ${e.message}';
        })
        .join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Скопировано строк: ${c.filtered.length}')),
    );
  }

  Color _levelColor(LogLevel level, AppSemanticColors semantic, AppSurfaces surfaces) {
    switch (level) {
      case LogLevel.error:
        return semantic.danger;
      case LogLevel.warning:
        return semantic.connecting;
      case LogLevel.info:
        return semantic.info;
      case LogLevel.debug:
        return surfaces.text3;
    }
  }

  String _levelLabel(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DEBUG';
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final c = widget.controller;

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
                  'Логи ядра',
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    color: surfaces.text1,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                _ConnectionDot(connected: c.connected, semantic: semantic),
                const Spacer(),
                _LevelFilter(
                  value: c.minLevel,
                  onChanged: c.setMinLevel,
                ),
                const SizedBox(width: AppSpace.s2),
                IconButton(
                  tooltip: 'Скопировать всё',
                  icon: const Icon(Icons.copy_all_outlined),
                  onPressed: c.filtered.isEmpty ? null : _copyAll,
                ),
                IconButton(
                  tooltip: _autoscroll ? 'Автоскролл: вкл' : 'Автоскролл: выкл',
                  icon: Icon(
                    Icons.vertical_align_bottom,
                    color: _autoscroll ? semantic.on : surfaces.text3,
                  ),
                  onPressed: () => setState(() => _autoscroll = !_autoscroll),
                ),
                IconButton(
                  tooltip: c.paused ? 'Возобновить' : 'Пауза',
                  icon: Icon(c.paused ? Icons.play_arrow : Icons.pause),
                  onPressed: () => setState(c.togglePause),
                ),
                IconButton(
                  tooltip: 'Очистить',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(c.clear),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
          if (c.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              child: Text(
                'Нет соединения с ядром: ${c.error}',
                style: TextStyle(color: semantic.danger, fontSize: AppFontSize.sm),
              ),
            ),
          Expanded(
            child: c.filtered.isEmpty
                ? Center(
                    child: Text(
                      c.connected ? 'Логов пока нет' : 'Подключение...',
                      style: TextStyle(color: surfaces.text3),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    itemCount: c.filtered.length,
                    itemBuilder: (context, index) {
                      final e = c.filtered[index];
                      final color = _levelColor(e.level, semantic, surfaces);
                      final time =
                          '${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}:${e.time.second.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            children: [
                              TextSpan(
                                text: '$time  ',
                                style: TextStyle(color: surfaces.text3),
                              ),
                              TextSpan(
                                text: '${_levelLabel(e.level).padRight(5)}  ',
                                style: TextStyle(color: color, fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: e.message,
                                style: TextStyle(color: surfaces.text1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  const _ConnectionDot({required this.connected, required this.semantic});
  final bool connected;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? semantic.on : semantic.danger,
      ),
    );
  }
}

class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.value, required this.onChanged});
  final LogLevel value;
  final ValueChanged<LogLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: surfaces.card2,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: LogLevel.values.map((level) {
          final selected = level == value;
          return GestureDetector(
            onTap: () => onChanged(level),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? semantic.on : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.xs - 2),
              ),
              child: Text(
                level.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? const Color(0xFF0A130F) : surfaces.text2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}