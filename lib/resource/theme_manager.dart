import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: false,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: ColorManager.white,
        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark,
        // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    ),
    scaffoldBackgroundColor: ColorManager.white,
    colorScheme: ColorScheme.fromSwatch(
      backgroundColor: ColorManager.white,
      primarySwatch: MaterialColor(0xff3cb4b4, color),
    ),
  );
}

Map<int, Color> color = {
  50: const Color.fromRGBO(60, 180, 180, .1),
  100: const Color.fromRGBO(60, 180, 180, .2),
  200: const Color.fromRGBO(60, 180, 180, .3),
  300: const Color.fromRGBO(60, 180, 180, .4),
  400: const Color.fromRGBO(60, 180, 180, .5),
  500: const Color.fromRGBO(60, 180, 180, .6),
  600: const Color.fromRGBO(60, 180, 180, .7),
  700: const Color.fromRGBO(60, 180, 180, .8),
  800: const Color.fromRGBO(60, 180, 180, .9),
  900: const Color.fromRGBO(60, 180, 180, 1),
};
