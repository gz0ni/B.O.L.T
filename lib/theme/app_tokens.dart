import 'package:flutter/material.dart';

/// Дизайн-токены, перенесённые 1:1 из CSS-переменных мокапа
/// (vpn-app-mockup.html, блок :root). Источник правды для всех
/// цветов/радиусов/отступов в приложении — не хардкодить значения
/// в виджетах напрямую, всегда брать отсюда.
class AppRadius {
  AppRadius._();

  static const double lg = 28;
  static const double md = 16;
  static const double sm = 10;
  static const double xs = 7;
  static const double pill = 999;
}

class AppSpace {
  AppSpace._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 22;
  static const double s6 = 28;
}

class AppFontSize {
  AppFontSize._();

  static const double xs = 11;
  static const double sm = 12.5;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 22;
}

class AppMotion {
  AppMotion._();

  // cubic-bezier(.22,1,.36,1) из мокапа — мягкий overshoot на выходе
  static const Curve ease = Cubic(0.22, 1, 0.36, 1);

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Семантические цвета состояний подключения — одинаковые имена
/// что в мокапе (idle/connecting/on/danger/info), чтобы не было
/// рассинхрона терминологии между дизайном и кодом.
class AppSemanticColors {
  const AppSemanticColors({
    required this.idle,
    required this.idleDim,
    required this.connecting,
    required this.connectingDim,
    required this.on,
    required this.onDim,
    required this.danger,
    required this.dangerDim,
    required this.info,
    required this.infoDim,
  });

  final Color idle;
  final Color idleDim;
  final Color connecting;
  final Color connectingDim;
  final Color on;
  final Color onDim;
  final Color danger;
  final Color dangerDim;
  final Color info;
  final Color infoDim;

  static const dark = AppSemanticColors(
    idle: Color(0xFF4B4E5F),
    idleDim: Color(0x2E4B4E5F),
    connecting: Color(0xFFE8A857),
    connectingDim: Color(0x28E8A857),
    on: Color(0xFF4FE0B0),
    onDim: Color(0x244FE0B0),
    danger: Color(0xFFFF6B6B),
    dangerDim: Color(0x28FF6B6B),
    info: Color(0xFF5B9DFF),
    infoDim: Color(0x285B9DFF),
  );

  static const light = AppSemanticColors(
    idle: Color(0xFFAEB1C0),
    idleDim: Color(0x1F5A5D6E),
    connecting: Color(0xFFE8A857),
    connectingDim: Color(0x28D28C32),
    on: Color(0xFF4FE0B0),
    onDim: Color(0x2414B482),
    danger: Color(0xFFFF6B6B),
    dangerDim: Color(0x28FF6B6B),
    info: Color(0xFF5B9DFF),
    infoDim: Color(0x285B9DFF),
  );
}

/// Доступ к семантическим цветам через контекст темы, например:
/// `AppColors.of(context).on` — вместо протаскивания цветов вручную.
extension AppColorsExtension on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColorsThemeExtension>()!.colors;
}

class AppSemanticColorsThemeExtension
    extends ThemeExtension<AppSemanticColorsThemeExtension> {
  const AppSemanticColorsThemeExtension(this.colors);

  final AppSemanticColors colors;

  @override
  AppSemanticColorsThemeExtension copyWith({AppSemanticColors? colors}) {
    return AppSemanticColorsThemeExtension(colors ?? this.colors);
  }

  @override
  AppSemanticColorsThemeExtension lerp(
    ThemeExtension<AppSemanticColorsThemeExtension>? other,
    double t,
  ) {
    if (other is! AppSemanticColorsThemeExtension) return this;
    return AppSemanticColorsThemeExtension(
      AppSemanticColors(
        idle: Color.lerp(colors.idle, other.colors.idle, t)!,
        idleDim: Color.lerp(colors.idleDim, other.colors.idleDim, t)!,
        connecting:
            Color.lerp(colors.connecting, other.colors.connecting, t)!,
        connectingDim: Color.lerp(
          colors.connectingDim,
          other.colors.connectingDim,
          t,
        )!,
        on: Color.lerp(colors.on, other.colors.on, t)!,
        onDim: Color.lerp(colors.onDim, other.colors.onDim, t)!,
        danger: Color.lerp(colors.danger, other.colors.danger, t)!,
        dangerDim:
            Color.lerp(colors.dangerDim, other.colors.dangerDim, t)!,
        info: Color.lerp(colors.info, other.colors.info, t)!,
        infoDim: Color.lerp(colors.infoDim, other.colors.infoDim, t)!,
      ),
    );
  }
}