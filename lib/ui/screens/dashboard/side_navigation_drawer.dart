import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/drawer_item_screens/partys/partys_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/custom_page_transition.dart';
import '../../../model/other/side_nav_drawer_item_model.dart';
import '../../../services/authentication_service.dart';
import '../drawer_item_screens/about_us/about_us_screen.dart';
import '../drawer_item_screens/our_story/our_story_screen.dart';
import '../drawer_item_screens/privacy_policy/privacy_policy_screen.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({Key? key, required this.onClose})
      : super(key: key);

  final Function() onClose;

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  List<SideNavDrawerItemModel> items = [];
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
    setData();
  }

  setData() {
    items.add(
        SideNavDrawerItemModel(IconAssets.iconSideNavDashboard, "Dashboard"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideParty, "Party"));
    items.add(
        SideNavDrawerItemModel(IconAssets.iconSideNavPP, "Privacy Policy"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavStory, "Our Story"));
    // items.add(SideNavDrawerItemModel(IconAssets.iconSideNavCall, "Call to head office"));
    // items.add(SideNavDrawerItemModel(IconAssets.iconSideNavWhatsApp, "Whatsapp to head office"));
    // items.add(SideNavDrawerItemModel(IconAssets.iconSideTellUs, "Tell Us"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavLogout, "Log out"));
    setState(() {});
  }

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  navigateToScreens(int index) {
    switch (index) {
      case 0:
        widget.onClose();
        break;
      case 1:
        //  PartysScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PartyScreen(1),
          ),
        );
        widget.onClose();
        break;
      case 2:
        AppUtils.navigateTo(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            PrivacyPolicyScreen.routeName,
          ),
        );
        widget.onClose();
        break;
      case 3:
        AppUtils.navigateTo(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            OurStoryScreen.routeName,
          ),
        );
        widget.onClose();
        break;
      case 6:
        AppUtils.navigateTo(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            AboutUsScreen.routeName,
          ),
        );
        widget.onClose();
        break;
      case 4:
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
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 80.w,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.sp, right: 20.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/ic_logo_dashboard.png',
                        width: 40.sp),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(
                        Icons.close_sharp,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return DrawerItemWidget(
                    model: items[index],
                    isLastItem: index == items.length - 1,
                    onClick: () {
                      navigateToScreens(index);
                    },
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.sp),
                child: Text(
                  packageInfo?.version ?? "",
                  style: getMediumStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: 16.sp,
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

class DrawerItemWidget extends StatelessWidget {
  const DrawerItemWidget(
      {Key? key,
      required this.model,
      required this.isLastItem,
      required this.onClick})
      : super(key: key);

  final SideNavDrawerItemModel model;
  final bool isLastItem;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.only(top: 16.sp),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 19.sp),
              child: Row(
                children: [
                  SvgPicture.asset(
                    model.icon,
                    height: model.icon == IconAssets.iconSideNavWhatsApp
                        ? 19.sp
                        : model.icon == IconAssets.iconSideParty
                            ? 16.sp
                            : 17.sp,
                  ),
                  SizedBox(
                      width: model.icon == IconAssets.iconSideNavWhatsApp
                          ? 15.sp
                          : 18.sp),
                  Expanded(
                    child: Text(
                      model.title,
                      style: getMediumStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.sp),
            !isLastItem
                ? Container(
                    height: 4.sp,
                    color: ColorManager.colorLightGrey,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
