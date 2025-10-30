import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  CustomPageTransition(
      GlobalKey materialAppKey,
      String routeName, {
        Object? arguments,
      }) : super(
    settings: RouteSettings(
      arguments: arguments,
      name: routeName,
    ),
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) {
      assert(materialAppKey.currentWidget != null);
      assert(materialAppKey.currentWidget is MaterialApp);
      var myapp = materialAppKey.currentWidget as MaterialApp;
      var routes = myapp.routes;
      assert(routes!.containsKey(routeName));
      return routes![routeName]!(context);
    },
    transitionDuration : const Duration(milliseconds: 300),
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: child,
        ),
  );
}