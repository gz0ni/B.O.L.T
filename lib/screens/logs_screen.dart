import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/theme/app_theme.dart';
import 'package:fl_clash/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final _scrollController = ScrollController();
  LogLevel _minLevel = LogLevel.debug;
  bool _autoscroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Log> _filter(List<Log> logs) {
    if (_minLevel == LogLevel.debug) {
      return logs;
    }
    return logs.where((log) => log.logLevel.index >= _minLevel.index).toList();
  }

  Future<void> _copyAll(List<Log> logs) async {
    final text = logs
        .map(
          (e) => '${e.dateTime} ${e.logLevel.name.toUpperCase().padRight(7)} ${e.payload}',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Скопировано строк: ${logs.length}')),
    );
  }

  Future<void> _exportLogs() async {
    final saved = await ref.read(logsProvider.notifier).exportLogs();
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Логи экспортированы')),
    );
  }

  void _clearLogs() {
    final logsState = ref.read(logsProvider);
    ref
        .read(logsProvider.notifier)
        .value = FixedList(logsState.maxLength);
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
      case LogLevel.silent:
        return surfaces.text3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final logs = ref.watch(logsProvider).list;
    final filtered = _filter(logs);

    if (_autoscroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

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
                const Spacer(),
                _LevelFilter(
                  value: _minLevel,
                  onChanged: (level) => setState(() => _minLevel = level),
                ),
                const SizedBox(width: AppSpace.s2),
                IconButton(
                  tooltip: 'Скопировать всё',
                  icon: const Icon(Icons.copy_all_outlined),
                  onPressed: filtered.isEmpty ? null : () => _copyAll(filtered),
                ),
                IconButton(
                  tooltip: 'Экспорт логов',
                  icon: const Icon(Icons.save_alt),
                  onPressed: filtered.isEmpty ? null : _exportLogs,
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
                  tooltip: 'Очистить',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearLogs,
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Логов пока нет',
                      style: TextStyle(color: surfaces.text3),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final log = filtered[index];
                      final color = _levelColor(log.logLevel, semantic, surfaces);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            children: [
                              TextSpan(
                                text: '${log.dateTime}  ',
                                style: TextStyle(color: surfaces.text3),
                              ),
                              TextSpan(
                                text: '${log.logLevel.name.toUpperCase().padRight(7)}  ',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: log.payload,
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
        children: LogLevel.values
            .where((level) => level != LogLevel.silent)
            .map((level) {
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
