import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// `.pill-icon` из мокапа: квадрат 30x30 (или 34x34 в списках),
/// радиус 9, фон card-2, текст JetBrains Mono 11/text-2.
class BoltPillIcon extends StatelessWidget {
  const BoltPillIcon({
    super.key,
    this.symbol,
    this.icon,
    this.size = 30,
  }) : assert(symbol != null || icon != null);

  final String? symbol;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: surfaces.card2,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: symbol != null
          ? Text(
              symbol!,
              style: TextStyle(
                fontFamily: AppTheme.monoFontFamily,
                fontSize: size >= 34 ? 11 : 11,
                fontWeight: FontWeight.w500,
                color: surfaces.text2,
                letterSpacing: 0.2,
              ),
            )
          : Icon(icon, size: size * 0.5, color: surfaces.text2),
    );
  }
}

/// `.check` из мокапа: круг 18x18, рамка 1.5 border; активный —
/// заливка --on с внутренней точкой цвета bg.
class BoltCheck extends StatelessWidget {
  const BoltCheck({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.ease,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? semantic.on : Colors.transparent,
        border: Border.all(
          color: active ? semantic.on : surfaces.border,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? surfaces.bg : Colors.transparent,
        ),
      ),
    );
  }
}

/// `.log-filter-chip` из мокапа: пилюля, фон card + border, текст
/// 11/text-2; активный — card-2 + рамка --on, текст text-1.
class BoltChip extends StatelessWidget {
  const BoltChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    return Material(
      color: selected ? surfaces.card2 : surfaces.card,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? semantic.on : surfaces.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: AppSpace.s2 - 3,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFontSize.xs,
              color: selected ? surfaces.text1 : surfaces.text2,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.settings-section-label` из мокапа: 11px, uppercase, letter-spacing
/// 0.06em, text-3; отступы 16/10/6.
class BoltSectionLabel extends StatelessWidget {
  const BoltSectionLabel(this.label, {super.key, this.padding});

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(10, 16, 10, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: AppFontSize.xs,
          letterSpacing: 0.66,
          color: surfaces.text3,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
