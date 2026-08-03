import 'package:flutter/material.dart';

import '../common/context.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/bolt_controls.dart';
import '../widgets/bolt_icon_button.dart';
import '../widgets/bolt_list.dart';

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => BoltSectionLabel(text);
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.description,
    this.help,
    required this.trailing,
  });

  final String title;
  final String? description;
  final String? help;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: surfaces.text1,
                          fontSize: AppFontSize.md,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (help != null) ...[
                      const SizedBox(width: AppSpace.s1),
                      Tooltip(
                        message: help!,
                        child: Icon(
                          Icons.help_outline,
                          size: 14,
                          color: surfaces.text3,
                        ),
                      ),
                    ],
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(color: surfaces.text3, fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s3),
          trailing,
        ],
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({super.key, required this.value, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BoltSwitch(value: value, onChanged: onChanged ?? (_) {});
  }
}

class SettingsSegmented<T> extends StatelessWidget {
  const SettingsSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final List<T> options;
  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return BoltSegmented<T>(
      options: [
        for (final option in options)
          BoltSegmentedOption(option, labels[option] ?? option.toString()),
      ],
      value: value,
      onChanged: onChanged,
    );
  }
}

class SettingsStepper extends StatelessWidget {
  const SettingsStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.step = 20,
    this.min = 1000,
    this.max = 9000,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int step;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return BoltStepper(
      value: value,
      onDecrement: onChanged == null || value - step < min
          ? null
          : () => onChanged!(value - step),
      onIncrement: onChanged == null || value + step > max
          ? null
          : () => onChanged!(value + step),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: context.surfaces.borderSoft, height: AppSpace.s5);
  }
}

class SettingsInput extends StatefulWidget {
  const SettingsInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.numeric = false,
    this.width = 120,
    this.hint,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool numeric;
  final double width;
  final String? hint;

  @override
  State<SettingsInput> createState() => _SettingsInputState();
}

class _SettingsInputState extends State<SettingsInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SettingsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onChanged(text);
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        keyboardType: widget.numeric
            ? TextInputType.number
            : TextInputType.text,
        style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
        cursorColor: semantic.on,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintStyle: TextStyle(color: surfaces.text3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: 11,
          ),
          filled: true,
          fillColor: surfaces.card,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: surfaces.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: semantic.on),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

/// `.mini-btn` из мокапа: фон on-dim, рамка --on, текст --on.
/// Здесь — кнопка-редактор со счётчиком текущих значений.
class _EditorButton extends StatelessWidget {
  const _EditorButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Tooltip(
      message: context.appLocalizations.edit,
      child: Material(
        color: semantic.onDim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: semantic.on),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: semantic.onDim.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s3,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 14, color: semantic.on),
                const SizedBox(width: AppSpace.s1),
                Text(
                  '$count',
                  style: TextStyle(
                    color: semantic.on,
                    fontSize: AppFontSize.sm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsListEditor extends StatelessWidget {
  const SettingsListEditor({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String title;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _EditorButton(
      count: value.length,
      onTap: () => _showListEditor(context),
    );
  }

  void _showListEditor(BuildContext context) {
    final items = List<String>.from(value);
    final controller = TextEditingController();
    final local = context.appLocalizations;
    final hintText = hint ?? local.value;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            void add() {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              items.add(text);
              controller.clear();
              setState(() {});
            }

            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final item in items)
                            _dialogListItem(
                              context,
                              key: item,
                              trailing: BoltIconButton(
                                icon: Icons.close,
                                tooltip: context.appLocalizations.delete,
                                compact: true,
                                color: context.semanticColors.danger,
                                danger: true,
                                onTap: () {
                                  items.remove(item);
                                  setState(() {});
                                },
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: context.surfaces.text1,
                                  fontSize: AppFontSize.sm,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    _dialogTextField(
                      context,
                      controller: controller,
                      hint: hintText,
                      onSubmitted: (_) => add(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onChanged(items);
                  },
                  child: Text(context.appLocalizations.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SettingsMapEditor extends StatelessWidget {
  const SettingsMapEditor({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.keyHint,
    this.valueHint,
  });

  final String title;
  final Map<String, String> value;
  final ValueChanged<Map<String, String>> onChanged;
  final String? keyHint;
  final String? valueHint;

  @override
  Widget build(BuildContext context) {
    return _EditorButton(
      count: value.length,
      onTap: () => _showMapEditor(context),
    );
  }

  void _showMapEditor(BuildContext context) {
    final items = Map<String, String>.from(value);
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    final local = context.appLocalizations;
    final keyHintText = keyHint ?? local.key;
    final valueHintText = valueHint ?? local.value;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            void add() {
              final key = keyController.text.trim();
              final val = valueController.text.trim();
              if (key.isEmpty || val.isEmpty) return;
              items[key] = val;
              keyController.clear();
              valueController.clear();
              setState(() {});
            }

            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final entry in items.entries)
                            _dialogListItem(
                              context,
                              key: entry.key,
                              trailing: BoltIconButton(
                                icon: Icons.close,
                                tooltip: context.appLocalizations.delete,
                                compact: true,
                                color: context.semanticColors.danger,
                                onTap: () {
                                  items.remove(entry.key);
                                  setState(() {});
                                },
                              ),
                              child: Text(
                                '${entry.key} → ${entry.value}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.surfaces.text1,
                                  fontSize: AppFontSize.sm,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    Row(
                      children: [
                        Expanded(
                          child: _dialogTextField(
                            context,
                            controller: keyController,
                            hint: keyHintText,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s2),
                        Expanded(
                          child: _dialogTextField(
                            context,
                            controller: valueController,
                            hint: valueHintText,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s1),
                        BoltIconButton(
                          icon: Icons.add,
                          tooltip: context.appLocalizations.add,
                          compact: true,
                          onTap: add,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onChanged(items);
                  },
                  child: Text(context.appLocalizations.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SettingsPortsEditor extends StatelessWidget {
  const SettingsPortsEditor({
    super.key,
    required this.mixedPort,
    required this.socksPort,
    required this.port,
    required this.redirPort,
    required this.tproxyPort,
    required this.onChanged,
  });

  final int mixedPort;
  final int socksPort;
  final int port;
  final int redirPort;
  final int tproxyPort;
  final void Function(int mixed, int socks, int port, int redir, int tproxy)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditorButton(
      count: [
        mixedPort,
        socksPort,
        port,
        redirPort,
        tproxyPort,
      ].where((v) => v > 0).length,
      onTap: () => _showPortsDialog(context),
    );
  }

  void _showPortsDialog(BuildContext context) {
    final mixed = TextEditingController(text: '$mixedPort');
    final socks = TextEditingController(text: '$socksPort');
    final portCtrl = TextEditingController(text: '$port');
    final redir = TextEditingController(text: '$redirPort');
    final tproxy = TextEditingController(text: '$tproxyPort');
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        Widget field(String label, TextEditingController controller) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.s2),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: TextStyle(color: context.surfaces.text2),
                  ),
                ),
                Expanded(
                  child: _dialogTextField(
                    context,
                    controller: controller,
                    numeric: true,
                  ),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          title: Text(context.appLocalizations.ports),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field('Mixed port', mixed),
              field('SOCKS', socks),
              field('HTTP', portCtrl),
              field('Redir', redir),
              field('TProxy', tproxy),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.appLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onChanged(
                  int.tryParse(mixed.text.trim()) ?? 0,
                  int.tryParse(socks.text.trim()) ?? 0,
                  int.tryParse(portCtrl.text.trim()) ?? 0,
                  int.tryParse(redir.text.trim()) ?? 0,
                  int.tryParse(tproxy.text.trim()) ?? 0,
                );
              },
              child: Text(context.appLocalizations.save),
            ),
          ],
        );
      },
    );
  }
}

/// Строка списка в диалогах-редакторах (list-item из мокапа:
/// padding 11x10, радиус sm, hover -> card).
Widget _dialogListItem(
  BuildContext context, {
  required String key,
  required Widget child,
  required Widget trailing,
}) {
  final surfaces = context.surfaces;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: AppSpace.s2),
          trailing,
        ],
      ),
    ),
  );
}

/// Инпут в стиле form-field мокапа внутри диалогов.
Widget _dialogTextField(
  BuildContext context, {
  required TextEditingController controller,
  String? hint,
  bool numeric = false,
  ValueChanged<String>? onSubmitted,
}) {
  final surfaces = context.surfaces;
  final semantic = context.semanticColors;
  return TextField(
    controller: controller,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md),
    cursorColor: semantic.on,
    decoration: InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(color: surfaces.text3),
      filled: true,
      fillColor: surfaces.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s3,
        vertical: 11,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: surfaces.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: semantic.on),
      ),
    ),
    onSubmitted: onSubmitted,
  );
}
