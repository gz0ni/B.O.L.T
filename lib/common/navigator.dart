import 'package:animations/animations.dart';
import 'package:bolt/common/common.dart';
import 'package:bolt/providers/app.dart';
import 'package:bolt/state.dart';
import 'package:flutter/material.dart';

class BaseNavigator {
  static Future<T?> push<T>(BuildContext context, Widget child) async {
    if (!globalState.container.read(isMobileViewProvider)) {
      return Navigator.of(
        context,
      ).push<T>(CommonDesktopRoute(builder: (context) => child));
    }
    return Navigator.of(
      context,
    ).push<T>(CommonRoute(builder: (context) => child));
  }

  // static Future<T?> modal<T>(BuildContext context, Widget child) async {
  //   if (globalState.appState.viewMode != ViewMode.mobile) {
  //     return await globalState.showCommonDialog<T>(
  //       child: CommonModal(
  //         child: child,
  //       ),
  //     );
  //   }
  //   return await Navigator.of(context).push<T>(
  //     CommonRoute(
  //       builder: (context) => child,
  //     ),
  //   );
  // }
}

const commonSharedXPageTransitions = SharedAxisPageTransitionsBuilder(
  transitionType: SharedAxisTransitionType.horizontal,
  fillColor: Colors.transparent,
);

class CommonDesktopRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext context) builder;

  CommonDesktopRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FadeTransition(opacity: animation, child: result),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);
}

class CommonRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext context) builder;

  CommonRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        fillColor: context.colorScheme.surface,
        child: result,
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}

