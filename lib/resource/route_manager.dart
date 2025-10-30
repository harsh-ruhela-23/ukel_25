import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukel/craftsman_app/ui/screens/craftsman_home_screen.dart';
import 'package:ukel/ui/screens/francis_management/order/order_screen.dart';
import 'package:ukel/ui/screens/francis_management/training/training_screen.dart';
import '../AddNewServicesPage.dart';
import '../admin_app/admin_ui/admin_home/admin_home_screen.dart';
import '../ui/screens/branch_management/widgets/add_craftman_screen.dart';
import '../ui/screens/branch_management/widgets/add_employee_screen.dart';
import '../ui/screens/branch_management/widgets/emp_attendance_screen.dart';
import '../ui/screens/drawer_item_screens/about_us/about_us_screen.dart';
import '../ui/screens/drawer_item_screens/our_story/our_story_screen.dart';
import '../ui/screens/drawer_item_screens/privacy_policy/privacy_policy_screen.dart';
import '../ui/screens/francis_management/note/note_screen.dart';
import '../ui/screens/francis_management/tell_us/tell_us_screen.dart';
import 'package:ukel/ui/screens/login/login_screen.dart';
import '../ui/screens/francis_management/training/tabs/training_item_details_screen.dart';
import '../ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/login/login_controller.dart';
import '../ui/screens/notification/notification_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  // Main app
  SplashScreen.routeName: (context) => const SplashScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  AddNewCustomerScreen.routeName: (context) => const AddNewCustomerScreen(),
  AboutUsScreen.routeName: (context) => const AboutUsScreen(),
  LoginScreen.routeName: (context) => ChangeNotifierProvider(
        create: (context) => LoginController(),
        child: const LoginScreen(),
      ),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  OurStoryScreen.routeName: (context) => const OurStoryScreen(),
  PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
  TrainingScreen.routeName: (context) => const TrainingScreen(),
  TrainingItemDetailsScreen.routeName: (context) =>
      const TrainingItemDetailsScreen(),
  TellUsScreen.routeName: (context) => const TellUsScreen(),
  OrderScreen.routeName: (context) => const OrderScreen(),
  NoteScreen.routeName: (context) => const NoteScreen(),
  AddCraftsManScreen.routeName: (context) => const AddCraftsManScreen(),
  AddEmployeeScreen.routeName: (context) => const AddEmployeeScreen(),
  EmpAttendanceScreen.routeName: (context) => const EmpAttendanceScreen(),
  AddNewServicesPage.routeName: (context) => const AddNewServicesPage(),

  // Admin app route
  AdminHomeScreen.routeName: (context) => const AdminHomeScreen(),
  CraftsmanHomeScreen.routeName: (context) => const CraftsmanHomeScreen(),
};

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
