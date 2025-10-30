import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/string_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/ui/screens/splash/splash_screen.dart';
import 'package:ukel/utils/default_button.dart';

import 'resource/route_manager.dart';
import 'resource/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static GlobalKey myAppKey = GlobalKey();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  String responseText = "Loading...";
  @override

  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorKey: globalKey,
          key: MyApp.myAppKey,
          onGenerateTitle: (context) => StringManager.appName,
          debugShowCheckedModeBanner: false,
          theme: getApplicationTheme(),
          initialRoute: SplashScreen.routeName,
          routes: routes,
          builder: (context, child) {
            // ✅ Force status bar text color white
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // or any bg color
                statusBarIconBrightness: Brightness.light, // Android → white
                statusBarBrightness: Brightness.dark,      // iOS → white
              ),
            );
            return child!;
          },
        );
      },
    );
  }
}

bool isTablet = Device.screenType == ScreenType.tablet;
