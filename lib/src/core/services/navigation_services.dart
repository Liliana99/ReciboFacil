import 'package:flutter/material.dart';
import 'package:recibo_facil/src/features/home/presentation/routes/with_extra.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<void> navigateToPage<T extends WithExtra>(
      Widget Function({dynamic extra}) pageBuilder,
      {dynamic extra}) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => pageBuilder(extra: extra),
      ),
    );
  }

  void goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }
}
