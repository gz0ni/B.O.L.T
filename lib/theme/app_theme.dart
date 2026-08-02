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

  /// --font-mono: 'JetBrains Mono' — мета/статистика/редакторы. Вместо
  /// хардкода 'monospace' в виджетах используйте AppTheme.monoFontFamily.
  static final String? monoFontFamily = GoogleFonts.jetBrainsMono().fontFamily;

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
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark
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

    // Цвет тёмного текста на сплошной заливке --on (primary-btn,
    // switch/check) — из мокапа #0C1310, одинаков в обеих темах.
    const onAccentText = primaryOnText;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: semantic.on,
      onPrimary: onAccentText,
      primaryContainer: surfaces.card2,
      onPrimaryContainer: surfaces.text1,
      secondary: semantic.info,
      onSecondary: onAccentText,
      secondaryContainer: surfaces.card2,
      onSecondaryContainer: surfaces.text1,
      tertiary: semantic.connecting,
      onTertiary: onAccentText,
      tertiaryContainer: surfaces.card2,
      onTertiaryContainer: surfaces.text1,
      error: semantic.danger,
      onError: Colors.white,
      errorContainer: semantic.dangerDim,
      onErrorContainer: semantic.danger,
      surface: surfaces.card,
      onSurface: surfaces.text1,
      surfaceContainer: surfaces.bgSoft,
      surfaceContainerLow: surfaces.bg,
      surfaceContainerHigh: surfaces.card,
      surfaceContainerHighest: surfaces.card2,
      onSurfaceVariant: surfaces.text2,
      outline: surfaces.text3,
      outlineVariant: surfaces.border,
      inverseSurface: surfaces.card2,
      onInverseSurface: surfaces.text1,
      inversePrimary: semantic.on,
      shadow: Colors.black,
      scrim: modalBarrierColor,
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
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        color: surfaces.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: surfaces.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaces.borderSoft,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: surfaces.text2),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaces.bgSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: surfaces.border),
        ),
        titleTextStyle: displayFont.copyWith(
          fontSize: AppFontSize.lg,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: surfaces.text2,
          fontSize: AppFontSize.sm,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaces.bgSoft,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: surfaces.border),
        ),
        contentTextStyle: TextStyle(
          color: surfaces.text1,
          fontSize: AppFontSize.sm,
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s2,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaces.bgSoft,
        modalBackgroundColor: surfaces.bgSoft,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: modalBarrierColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheetTop),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaces.bgSoft,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: surfaces.border),
        ),
        textStyle: TextStyle(
          color: surfaces.text1,
          fontSize: AppFontSize.sm,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaces.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: surfaces.border),
        ),
        textStyle: TextStyle(
          color: surfaces.text1,
          fontSize: AppFontSize.xs,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: semantic.on,
          foregroundColor: onAccentText,
          disabledBackgroundColor: surfaces.card2,
          disabledForegroundColor: surfaces.text3,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppFontSize.md,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surfaces.card,
          foregroundColor: surfaces.text1,
          disabledBackgroundColor: surfaces.card2,
          disabledForegroundColor: surfaces.text3,
          side: BorderSide(color: surfaces.border),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: surfaces.text2,
          disabledForegroundColor: surfaces.text3,
          textStyle: const TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? semantic.on
              : surfaces.card2,
        ),
        thumbColor: const WidgetStatePropertyAll(Color(0xFFF2F3F6)),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: semantic.on,
        linearTrackColor: surfaces.card2,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => surfaces.card2,
        ),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(3),
      ),
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
