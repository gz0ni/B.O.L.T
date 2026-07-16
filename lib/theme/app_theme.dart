import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Поверхности и текст — цвета из блока "Color / Surface" и
/// "Color / Text" в :root мокапа.
class _Surfaces {
  const _Surfaces({
    required this.bg,
    required this.bgSoft,
    required this.card,
    required this.card2,
    required this.border,
    required this.borderSoft,
    required this.text1,
    required this.text2,
    required this.text3,
  });

  final Color bg;
  final Color bgSoft;
  final Color card;
  final Color card2;
  final Color border;
  final Color borderSoft;
  final Color text1;
  final Color text2;
  final Color text3;

  static const dark = _Surfaces(
    bg: Color(0xFF121319),
    bgSoft: Color(0xFF181A22),
    card: Color(0xFF1F2129),
    card2: Color(0xFF252732),
    border: Color(0x12FFFFFF), // rgba(255,255,255,0.07)
    borderSoft: Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
    text1: Color(0xFFF0F1F4),
    text2: Color(0xFF8D90A3),
    text3: Color(0xFF565968),
  );

  static const light = _Surfaces(
    bg: Color(0xFFF3F4F7),
    bgSoft: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    card2: Color(0xFFEEF0F4),
    border: Color(0x170F1117), // rgba(15,17,23,0.09)
    borderSoft: Color(0x0D0F1117), // rgba(15,17,23,0.05)
    text1: Color(0xFF15161C),
    text2: Color(0xFF5B5F72),
    text3: Color(0xFF9A9DB0),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(
        surfaces: _Surfaces.dark,
        semantic: AppSemanticColors.dark,
        brightness: Brightness.dark,
      );

  static ThemeData light() => _build(
        surfaces: _Surfaces.light,
        semantic: AppSemanticColors.light,
        brightness: Brightness.light,
      );

  static ThemeData _build({
    required _Surfaces surfaces,
    required AppSemanticColors semantic,
    required Brightness brightness,
  }) {
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    // --font-ui: 'Inter' — основной интерфейсный шрифт
    final uiText = GoogleFonts.interTextTheme(baseTextTheme).apply(
      bodyColor: surfaces.text1,
      displayColor: surfaces.text1,
    );

    // --font-display: 'Space Grotesk' — заголовки/titlebar/крупные цифры
    final displayFont = GoogleFonts.spaceGrotesk(
      color: surfaces.text1,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surfaces.bg,
      canvasColor: surfaces.bg,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: uiText.copyWith(
        headlineSmall: displayFont.copyWith(fontSize: AppFontSize.xl),
        titleMedium: displayFont.copyWith(fontSize: AppFontSize.lg),
        titleSmall: displayFont.copyWith(fontSize: AppFontSize.sm),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: semantic.on,
        onPrimary: brightness == Brightness.dark
            ? const Color(0xFF0A130F)
            : Colors.white,
        secondary: semantic.info,
        onSecondary: Colors.white,
        error: semantic.danger,
        onError: Colors.white,
        surface: surfaces.card,
        onSurface: surfaces.text1,
      ),
      cardTheme: CardThemeData(
        color: surfaces.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: surfaces.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaces.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: surfaces.text2),
      extensions: [
        AppSemanticColorsThemeExtension(semantic),
        AppSurfacesThemeExtension(surfaces.toPublic()),
      ],
    );
  }
}

/// Публичный набор поверхностных цветов, доступный из виджетов через
/// `context.surfaces.card`, аналогично семантическим цветам.
class AppSurfaces {
  const AppSurfaces({
    required this.bg,
    required this.bgSoft,
    required this.card,
    required this.card2,
    required this.border,
    required this.borderSoft,
    required this.text1,
    required this.text2,
    required this.text3,
  });

  final Color bg;
  final Color bgSoft;
  final Color card;
  final Color card2;
  final Color border;
  final Color borderSoft;
  final Color text1;
  final Color text2;
  final Color text3;
}

extension on _Surfaces {
  AppSurfaces toPublic() => AppSurfaces(
        bg: bg,
        bgSoft: bgSoft,
        card: card,
        card2: card2,
        border: border,
        borderSoft: borderSoft,
        text1: text1,
        text2: text2,
        text3: text3,
      );
}

class AppSurfacesThemeExtension
    extends ThemeExtension<AppSurfacesThemeExtension> {
  const AppSurfacesThemeExtension(this.surfaces);

  final AppSurfaces surfaces;

  @override
  AppSurfacesThemeExtension copyWith({AppSurfaces? surfaces}) {
    return AppSurfacesThemeExtension(surfaces ?? this.surfaces);
  }

  @override
  AppSurfacesThemeExtension lerp(
    ThemeExtension<AppSurfacesThemeExtension>? other,
    double t,
  ) {
    if (other is! AppSurfacesThemeExtension) return this;
    return this; // без анимированного перехода между темами пока не нужно
  }
}

extension AppSurfacesExtension on BuildContext {
  AppSurfaces get surfaces =>
      Theme.of(this).extension<AppSurfacesThemeExtension>()!.surfaces;
}