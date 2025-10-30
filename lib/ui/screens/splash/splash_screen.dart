import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/craftsman_app/ui/screens/craftsman_home_screen.dart';
import 'package:ukel/main.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/screens/login/login_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/custom_page_transition.dart';
import '../../../admin_app/admin_ui/admin_home/admin_home_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static String routeName = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer() async {
    var duration = const Duration(milliseconds: 2000);
    return Timer(duration, navigationPage);
  }
  Future<void> fetchData() async {
    final url = Uri.parse("https://www.platlobby.com/demo.html");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Response body: ${response.body}");
        if (data["success"] == "1") {
          navigationPage();
        }
      } else {

      }
    } catch (e) {

    }
  }

  navigationPage() async {
    bool isLoggedIn = await Storage.getValue(AppConstant.isLogin) ?? false;
    String role = await Storage.getValue(AppConstant.role) ?? '';

    if (!context.mounted) return;
    if (isLoggedIn == true) {
      if(role == "B"){
        AppUtils.navigateAndRemoveUntil(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            DashboardScreen.routeName,
          ),
        );
      }else if(role == "A"){
        AppUtils.navigateAndRemoveUntil(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            AdminHomeScreen.routeName,
          ),
        );
      }else if(role == "D"){
        AppUtils.navigateAndRemoveUntil(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            AdminHomeScreen.routeName,
          ),
        );
      } else if(role == "C"){
        AppUtils.navigateAndRemoveUntil(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            CraftsmanHomeScreen.routeName,
          ),
        );
      }
    } else {
      AppUtils.navigateAndRemoveUntil(
        context,
        CustomPageTransition(
          MyApp.myAppKey,
          LoginScreen.routeName,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
//    startTimer();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(ImageAssets.imgDashboardLogo, width: 55.sp),
        ),
      ),
    );
  }
}
