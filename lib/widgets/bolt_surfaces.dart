import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Шторка-шит из мокапа: фон bg-soft, верхние углы 26, handle 36x4,
/// шапка с заголовком Space Grotesk 16/600 + border-bottom soft,
/// барьер rgba(8,9,13,0.55). Если title == null — шапка не рисуется
/// (экран сам рисует свой заголовок).
Future<T?> showBoltSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  List<Widget>? actions,
  double heightFactor = 0.8,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheetTop),
      ),
    ),
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (context) {
      final surfaces = context.surfaces;
      return FractionallySizedBox(
        heightFactor: heightFactor,
        widthFactor: 1,
        child: Column(
          children: [
            const SizedBox(height: AppSpace.s3),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: surfaces.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.s5,
                  AppSpace.s3 - 2,
                  AppSpace.s5,
                  AppSpace.s4 - 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: surfaces.borderSoft),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppFontFamily.display,
                          fontSize: AppFontSize.lg,
                          fontWeight: FontWeight.w600,
                          color: surfaces.text1,
                        ),
                      ),
                    ),
                    if (actions != null) ...[
                      const SizedBox(width: AppSpace.s2),
                      Row(mainAxisSize: MainAxisSize.min, children: actions),
                    ],
                  ],
                ),
              ),
            Expanded(child: builder(context)),
          ],
        ),
      );
    },
  );
}

/// Тост из мокапа: пилюля bg-soft + border, текст 12.5 text-1,
/// иконка слева (danger/info/on по смыслу), тень --shadow-toast.
/// Поверхность и форма заданы в snackBarTheme темы.
void showBoltToast(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? iconColor,
  Duration duration = const Duration(milliseconds: 2500),
}) {
  final surfaces = context.surfaces;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: iconColor ?? surfaces.text2),
              const SizedBox(width: AppSpace.s2 - 1),
            ],
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Модальный диалог в стиле мокапа (onboarding-card): bg-soft, радиус
/// lg 28, рамка border. Кнопки — переданные действия (Bolt-кнопки).
Future<T?> showBoltDialog<T>(
  BuildContext context, {
  required String title,
  Widget? content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) =>
        AlertDialog(title: Text(title), content: content, actions: actions),
  );
}
