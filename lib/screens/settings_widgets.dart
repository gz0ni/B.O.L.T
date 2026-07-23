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
  const SettingsSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

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
    required this.onChanged,
    this.step = 20,
    this.min = 1000,
    this.max = 9000,
  });

  final int value;
  final ValueChanged<int> onChanged;
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
            onPressed: value - step >= min ? () => onChanged(value - step) : null,
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
            onPressed: value + step <= max ? () => onChanged(value + step) : null,
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