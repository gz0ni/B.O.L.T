import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Иконка-кнопка по спеке мокапа:
/// `.icon-btn` — 34x34, радиус 10, card + border, иконка text-2,
/// hover -> card-2/text-1.
/// Compact-вариант повторяет `.item-action-btn` — 26x26, радиус 7,
/// фон card-2 + border.
class BoltIconButton extends StatelessWidget {
  const BoltIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.compact = false,
    this.size,
    this.boxSize,
    this.color,
    this.danger = false,
    this.semanticsLabel,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool compact;
  final double? size;
  final double? boxSize;
  final Color? color;

  /// Красная hover-подсветка для кнопок удаления.
  final bool danger;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final isCompact = compact;
    final dimension = boxSize ?? (isCompact ? 26.0 : 34.0);
    final radius = isCompact ? AppRadius.xs : AppRadius.sm;
    final iconSize = size ?? (isCompact ? 13 : boxSize != null ? 18 : 16);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: semanticsLabel ?? tooltip,
        button: true,
        enabled: onTap != null,
        child: Material(
          color: isCompact ? surfaces.card2 : surfaces.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: surfaces.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            hoverColor: danger
                ? semantic.danger.withValues(alpha: 0.12)
                : isCompact
                    ? Color.alphaBlend(
                        surfaces.text1.withValues(alpha: 0.07),
                        surfaces.card2,
                      )
                    : surfaces.card2,
            child: SizedBox(
              width: dimension,
              height: dimension,
              child: Icon(
                icon,
                size: iconSize,
                color: color ?? surfaces.text2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `.mini-btn` — компактная акцентная кнопка: фон on-dim, рамка on,
/// текст on, 12/600. Используется для действий «применить» и т.п.
class BoltMiniButton extends StatelessWidget {
  const BoltMiniButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: semantic.onDim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: semantic.on),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          hoverColor: semantic.onDim.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s3,
              vertical: AppSpace.s2 - 2,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: semantic.on,
                fontSize: AppFontSize.sm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
