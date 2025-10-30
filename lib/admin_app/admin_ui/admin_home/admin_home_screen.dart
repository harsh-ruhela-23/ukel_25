import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/SubAdminPage.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_branches_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_color_list_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_coupon_list_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_craftman_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_delivery_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_employee_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_job_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_overview_tab.dart';

import '../../../resource/assets_manager.dart';
import '../../../resource/color_manager.dart';
import '../../../resource/fonts_manager.dart';
import '../../../resource/styles_manager.dart';
import '../../../services/authentication_service.dart';
import '../../../services/get_storage.dart';
import '../../../ui/dialogs/confirmation_dialog.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/constants.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  static String routeName = "/admin_home_screen";

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  PackageInfo? packageInfo;
  late final bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = Storage.getValue(AppConstant.role) == "A";
    _tabController = TabController(length: _isAdmin ? 1 : 8, vsync: this);
    getPackageInfo();
    AppUtils().getAndSetGlobalServiceList();
  }

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchId = _isAdmin ? null : Storage.getValue(FbConstant.uid);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: ColorManager.white,
          toolbarHeight: 32.sp,
          titleTextStyle: getBoldStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
          title: Text(
            'UkelApp - ${_isAdmin ? "Admin" : "Sub Admin"}',
            style: getMediumStyle(
              color: ColorManager.textColorBlack,
              fontSize: 18.sp,
            ),
          ),
          elevation: 0,
          leadingWidth: 26.sp,
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            title: "Are you sure want to\nLog out!",
                            negativeLabel: "Cancel",
                            positiveLabel: "Yes",
                            negativeButtonBorder: Border.all(
                              color: ColorManager.colorDarkBlue,
                            ),
                            onNegativeClick: () {
                              Navigator.pop(context);
                            },
                            onPositiveClick: () {
                              AuthenticationService().logOut(context);
                            },
                            negativeButtonColor: ColorManager.white,
                            negativeTextColor: ColorManager.colorDarkBlue,
                            positiveButtonColor: ColorManager.colorDarkBlue,
                            positiveTextColor: ColorManager.textColorWhite,
                          );
                        });
                  },
                  child: SvgPicture.asset(
                    IconAssets.iconSideNavLogout,
                    height: 19.sp,
                    width: 19.sp,
                  ),
                ),
                SizedBox(width: 18.sp),
              ],
            )
          ],
        ),
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap back again to leave'),
          ),
          child: Column(
            children: [
              // Tab Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.3), width: 2.7),
                    ),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          color: ColorManager.textColorBlack, width: 6.sp),
                    ),
                    labelColor: ColorManager.textColorBlack,
                    unselectedLabelColor: ColorManager.textColorGrey,
                    labelStyle: getSemiBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.bigExtra),
                    unselectedLabelStyle: getSemiBoldStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.bigExtra),
                    tabs: _isAdmin
                        ? const [
                            Tab(text: "Sub Admin"),
                          ]
                        : const [
                            Tab(text: "Branches"),
                            Tab(text: "OverView"),
                            Tab(text: "Delivery"),
                            Tab(text: "Job"),
                            Tab(text: "Employee"),
                            Tab(text: "Craftsman"),
                            Tab(text: "Color"),
                            Tab(text: "Coupon"),
                          ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child: TabBarView(
                    controller: _tabController,
                    children: _isAdmin
                        ? const [
                            SubAdminPage(),
                          ]
                        : [
                            const AdminBranchesTab(),
                            AdminOverViewTab(
                              branchId: branchId,
                            ),
                            AdminDeliveryTab(branchId: branchId),
                            AdminJobTab(
                              branchId: branchId,
                            ),
                            AdminEmployeeTab(
                              branchId: branchId,
                            ),
                            AdminCraftManTab(
                              branchId: branchId,
                            ),
                            const AdminColorListTab(),
                            const AdminCouponListTab(),
                          ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
