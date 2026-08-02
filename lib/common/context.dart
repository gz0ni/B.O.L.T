import 'package:bolt/l10n/l10n.dart';
import 'package:bolt/manager/manager.dart';
import 'package:bolt/models/state.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  void showNotifier(String text, {MessageActionState? actionState}) {
    return findAncestorStateOfType<StatusManagerState>()?.message(
      text,
      actionState: actionState,
    );
  }

  Size get appSize {
    return MediaQuery.of(this).size;
  }

  double get viewWidth {
    return appSize.width;
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get appLocalizations => AppLocalizations.of(this);

  T? findLastStateOfType<T extends State>() {
    T? state;

    void visitor(Element element) {
      if (!element.mounted) {
        return;
      }
      if (element is StatefulElement) {
        if (element.state is T) {
          state = element.state as T;
        }
      }
      element.visitChildren(visitor);
    }

    visitor(this as Element);
    return state;
  }
}

class BackHandleInherited extends InheritedWidget {
  final Function handleBack;

  const BackHandleInherited({
    super.key,
    required this.handleBack,
    required super.child,
  });

  static BackHandleInherited? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackHandleInherited>();

  @override
  bool updateShouldNotify(BackHandleInherited oldWidget) {
    return handleBack != oldWidget.handleBack;
  }
}
