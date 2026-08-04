import 'package:bolt/common/common.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/theme/app_theme.dart';
import 'package:bolt/theme/app_tokens.dart';
import 'package:bolt/widgets/bolt_icon_button.dart';
import 'package:bolt/widgets/bolt_list.dart';
import 'package:bolt/widgets/bolt_surfaces.dart';
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

  List<Widget> _buildChips() {
    return LogLevel.values
        .where((level) => level != LogLevel.silent)
        .map(
          (level) => BoltChip(
            label: level.name.toUpperCase(),
            selected: _minLevel == level,
            onTap: () => setState(() => _minLevel = level),
          ),
        )
        .toList();
  }

  List<Widget> _buildButtons(bool hasLogs, List<Log> logs) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return [
      BoltIconButton(
        tooltip: context.appLocalizations.copyAll,
        onTap: !hasLogs ? null : () => _copyAll(logs),
        icon: Icons.copy_all_outlined,
      ),
      const SizedBox(width: AppSpace.s1),
      BoltIconButton(
        tooltip: context.appLocalizations.exportLogs,
        onTap: !hasLogs ? null : _exportLogs,
        icon: Icons.save_alt,
      ),
      const SizedBox(width: AppSpace.s1),
      BoltIconButton(
        tooltip: _autoscroll
            ? context.appLocalizations.autoscrollOn
            : context.appLocalizations.autoscrollOff,
        onTap: () => setState(() => _autoscroll = !_autoscroll),
        icon: Icons.vertical_align_bottom,
        color: _autoscroll ? semantic.on : surfaces.text3,
      ),
      const SizedBox(width: AppSpace.s1),
      BoltIconButton(
        tooltip: context.appLocalizations.clear,
        onTap: _clearLogs,
        icon: Icons.delete_outline,
        danger: true,
      ),
      if (widget.onClose != null) ...[
        const SizedBox(width: AppSpace.s2),
        BoltIconButton(
          tooltip: context.appLocalizations.close,
          onTap: widget.onClose,
          icon: Icons.close,
        ),
      ],
    ];
  }

  Future<void> _copyAll(List<Log> logs) async {
    final text = logs
        .map(
          (e) =>
              '${e.dateTime} ${e.logLevel.name.toUpperCase().padRight(7)} ${e.payload}',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showBoltToast(context, context.appLocalizations.copiedLines(logs.length));
  }

  Future<void> _exportLogs() async {
    final saved = await ref.read(logsProvider.notifier).exportLogs();
    if (!mounted || !saved) return;
    showBoltToast(context, context.appLocalizations.logsExported);
  }

  void _clearLogs() {
    final logsState = ref.read(logsProvider);
    ref.read(logsProvider.notifier).value = FixedList(logsState.maxLength);
  }

  Color _levelColor(
    LogLevel level,
    AppSemanticColors semantic,
    AppSurfaces surfaces,
  ) {
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
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s3,
              AppSpace.s4,
              AppSpace.s3,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.appLocalizations.coreLogs,
                              style: TextStyle(
                                fontSize: AppFontSize.xl,
                                fontWeight: FontWeight.w600,
                                color: surfaces.text1,
                                fontFamily: AppFontFamily.display,
                              ),
                            ),
                          ),
                          ..._buildButtons(filtered.isNotEmpty, filtered),
                        ],
                      ),
                      const SizedBox(height: AppSpace.s2),
                      Wrap(spacing: 4, children: _buildChips()),
                    ],
                  );
                }
                return Row(
                  children: [
                    Text(
                      context.appLocalizations.coreLogs,
                      style: TextStyle(
                        fontSize: AppFontSize.xl,
                        fontWeight: FontWeight.w600,
                        color: surfaces.text1,
                        fontFamily: AppFontFamily.display,
                      ),
                    ),
                    const Spacer(),
                    Wrap(spacing: 4, children: _buildChips()),
                    const SizedBox(width: AppSpace.s2),
                    ..._buildButtons(filtered.isNotEmpty, filtered),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s4,
                0,
                AppSpace.s4,
                AppSpace.s4,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaces.card,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: surfaces.border),
                ),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.appLocalizations.noLogs,
                          style: TextStyle(color: surfaces.text3),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpace.s4),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final log = filtered[index];
                          final color = _levelColor(
                            log.logLevel,
                            semantic,
                            surfaces,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: AppTheme.monoFontFamily,
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${log.dateTime}  ',
                                    style: TextStyle(color: surfaces.text3),
                                  ),
                                  TextSpan(
                                    text:
                                        '${log.logLevel.name.toUpperCase().padRight(7)}  ',
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
            ),
          ),
        ],
      ),
    );
  }
}
