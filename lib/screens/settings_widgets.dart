import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.s3, AppSpace.s4, AppSpace.s3, AppSpace.s2),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          color: context.surfaces.text3,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.description,
    required this.trailing,
  });

  final String title;
  final String? description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: AppSpace.s3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md)),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
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
    final semantic = context.semanticColors;
    final surfaces = context.surfaces;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: semantic.on,
      inactiveTrackColor: semantic.idle,
      inactiveThumbColor: Colors.white,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : surfaces.border,
      ),
    );
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
        children: options.map((option) {
          final selected = option == value;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? semantic.on : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.xs - 2),
              ),
              child: Text(
                labels[option] ?? option.toString(),
                style: TextStyle(
                  fontSize: AppFontSize.sm,
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
    final surfaces = context.surfaces;
    return Container(
      decoration: BoxDecoration(
        color: surfaces.card2,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: onChanged == null || value - step < min
                ? null
                : () => onChanged!(value - step),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: onChanged == null || value + step > max
                ? null
                : () => onChanged!(value + step),
          ),
        ],
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: context.surfaces.border, height: AppSpace.s5);
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
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        keyboardType: widget.numeric
            ? TextInputType.number
            : TextInputType.text,
        style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintStyle: TextStyle(color: surfaces.text3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: 8,
          ),
          filled: true,
          fillColor: surfaces.card2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

class _EditorButton extends StatelessWidget {
  const _EditorButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Tooltip(
      message: 'Изменить',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: surfaces.card2,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(color: surfaces.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 14, color: surfaces.text2),
              const SizedBox(width: AppSpace.s1),
              Text(
                '$count',
                style: TextStyle(
                  color: surfaces.text2,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ],
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
    this.hint = 'Значение',
  });

  final String title;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return _EditorButton(
      count: value.length,
      onTap: () => _showListEditor(context),
    );
  }

  void _showListEditor(BuildContext context) {
    final surfaces = context.surfaces;
    final items = List<String>.from(value);
    final controller = TextEditingController();
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
              backgroundColor: surfaces.card,
              title: Text(
                title,
                style: TextStyle(color: surfaces.text1),
              ),
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
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item,
                                style: TextStyle(
                                  color: surfaces.text1,
                                  fontSize: AppFontSize.sm,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: context.semanticColors.danger,
                                ),
                                onPressed: () {
                                  items.remove(item);
                                  setState(() {});
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: surfaces.text1),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hint,
                        hintStyle: TextStyle(color: surfaces.text3),
                        filled: true,
                        fillColor: surfaces.card2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => add(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onChanged(items);
                  },
                  child: const Text('Сохранить'),
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
    this.keyHint = 'Ключ',
    this.valueHint = 'Значение',
  });

  final String title;
  final Map<String, String> value;
  final ValueChanged<Map<String, String>> onChanged;
  final String keyHint;
  final String valueHint;

  @override
  Widget build(BuildContext context) {
    return _EditorButton(
      count: value.length,
      onTap: () => _showMapEditor(context),
    );
  }

  void _showMapEditor(BuildContext context) {
    final surfaces = context.surfaces;
    final items = Map<String, String>.from(value);
    final keyController = TextEditingController();
    final valueController = TextEditingController();
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
              backgroundColor: surfaces.card,
              title: Text(
                title,
                style: TextStyle(color: surfaces.text1),
              ),
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
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${entry.key} → ${entry.value}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: surfaces.text1,
                                  fontSize: AppFontSize.sm,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: context.semanticColors.danger,
                                ),
                                onPressed: () {
                                  items.remove(entry.key);
                                  setState(() {});
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: keyController,
                            style: TextStyle(color: surfaces.text1),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: keyHint,
                              hintStyle: TextStyle(color: surfaces.text3),
                              filled: true,
                              fillColor: surfaces.card2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.s2),
                        Expanded(
                          child: TextField(
                            controller: valueController,
                            style: TextStyle(color: surfaces.text1),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: valueHint,
                              hintStyle: TextStyle(color: surfaces.text3),
                              filled: true,
                              fillColor: surfaces.card2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.s1),
                        _SquareAddButton(onTap: add),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onChanged(items);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SquareAddButton extends StatelessWidget {
  const _SquareAddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: surfaces.card2,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: surfaces.border),
        ),
        child: Icon(Icons.add, size: 16, color: surfaces.text2),
      ),
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
      count: [mixedPort, socksPort, port, redirPort, tproxyPort]
          .where((v) => v > 0)
          .length,
      onTap: () => _showPortsDialog(context),
    );
  }

  void _showPortsDialog(BuildContext context) {
    final surfaces = context.surfaces;
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
                    style: TextStyle(color: surfaces.text2),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: surfaces.text1),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: surfaces.card2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            'Порты',
            style: TextStyle(color: surfaces.text1),
          ),
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
              child: const Text('Отмена'),
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
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}