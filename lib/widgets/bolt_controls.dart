import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// `.switch` из мокапа: 40x24, track card-2 (выкл) / --on (вкл),
/// thumb 20 круглый светлый, без обводки. Анимация 0.2s AppMotion.ease.
class BoltSwitch extends StatelessWidget {
  const BoltSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: AppMotion.ease,
          width: 40,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? semantic.on : surfaces.card2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: AppMotion.ease,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2F3F6),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoltSegmentedOption<T> {
  const BoltSegmentedOption(this.value, this.label);

  final T value;
  final String label;
}

/// `.segmented` из мокапа: контейнер card-2, радиус 10, padding 3;
/// активный сегмент — поверхность card, радиус 8, текст text-1
/// (без цветной заливки!), неактивные — text-2.
class BoltSegmented<T> extends StatelessWidget {
  const BoltSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expanded = false,
  });

  final List<BoltSegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// Растягивать сегменты на всю доступную ширину (как вкладки-категории).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      decoration: BoxDecoration(
        color: surfaces.card2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final option in options) ...[
            if (option != options.first) const SizedBox(width: 2),
            if (expanded)
              Expanded(
                child: _segment(
                  context,
                  label: option.label,
                  active: option.value == value,
                  onTap: () => onChanged(option.value),
                ),
              )
            else
              _segment(
                context,
                label: option.label,
                active: option.value == value,
                onTap: () => onChanged(option.value),
              ),
          ],
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final surfaces = context.surfaces;
    return Material(
      color: active ? surfaces.card : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3 - 2,
            vertical: AppSpace.s2 - 2,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSize.sm,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? surfaces.text1 : surfaces.text2,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.stepper` из мокапа: кнопки 24x24, радиус 7, card-2 + border;
/// значение JetBrains Mono 13, min-width 38. Кнопка disabled, когда
/// её колбэк — null.
class BoltStepper extends StatelessWidget {
  const BoltStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    Widget button(String symbol, VoidCallback? onTap) {
      final enabled = onTap != null;
      return Material(
        color: surfaces.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          side: BorderSide(color: surfaces.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: AppFontSize.md,
                  height: 1,
                  color: enabled ? surfaces.text1 : surfaces.text3,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button('–', onDecrement),
        Container(
          width: 38,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontFamily: AppTheme.monoFontFamily,
              fontSize: 13,
              color: surfaces.text1,
            ),
          ),
        ),
        button('+', onIncrement),
      ],
    );
  }
}

/// `.form-field input` из мокапа: фон card, рамка border (0.07),
/// радиус sm, padding 11x12, фокус -> рамка --on. Метка 12/text-2/500,
/// хинт `.field-hint` 11/text-3.
class BoltTextField extends StatelessWidget {
  const BoltTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helper,
    this.keyboardType,
    this.onSubmitted,
    this.expands = false,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.fontFamily,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final bool expands;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final bool autofocus;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final field = TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      expands: expands,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        color: surfaces.text1,
        fontSize: AppFontSize.md,
        fontFamily: fontFamily,
      ),
      cursorColor: semantic.on,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: surfaces.text3, fontSize: AppFontSize.md),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: surfaces.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: semantic.on),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label!,
              style: TextStyle(
                color: surfaces.text2,
                fontSize: AppFontSize.sm,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s2 - 2),
        ],
        field,
        if (helper != null) ...[
          const SizedBox(height: AppSpace.s1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              helper!,
              style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
            ),
          ),
        ],
      ],
    );
  }
}
