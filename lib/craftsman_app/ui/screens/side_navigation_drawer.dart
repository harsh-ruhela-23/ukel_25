import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/other/side_nav_drawer_item_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/services/authentication_service.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/branch_management/widgets/about_craftsman_screen.dart';
import 'package:ukel/ui/screens/drawer_item_screens/our_story/our_story_screen.dart';
import 'package:ukel/ui/screens/drawer_item_screens/privacy_policy/privacy_policy_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/custom_page_transition.dart';

import 'craftman_charges_screen.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer(
      {Key? key, required this.onClose, required this.customCraftsmanModel})
      : super(key: key);

  final Function() onClose;
  final CraftsmanModel customCraftsmanModel;

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

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  setData() {
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavProfile, "Profile"));
    items.add(
        SideNavDrawerItemModel(IconAssets.iconSideNavPP, "Privacy Policy"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavStory, "Our Story"));
    //items.add(SideNavDrawerItemModel(IconAssets.iconSideNavCall, "Call to Branch"));
    // items.add(SideNavDrawerItemModel(IconAssets.iconSideNavWhatsApp, "Whatsapp to Branch"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavCharges, "Charges"));
    items.add(SideNavDrawerItemModel(IconAssets.iconSideNavLogout, "Log out"));
    setState(() {});
  }

  navigateToScreens(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AboutCraftsmanScreen(
              craftsmanModel: widget.customCraftsmanModel,
            ),
          ),
        );
        widget.onClose();
        break;
      case 1:
        AppUtils.navigateTo(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            PrivacyPolicyScreen.routeName,
          ),
        );
        widget.onClose();
        break;
      case 2:
        AppUtils.navigateTo(
          context,
          CustomPageTransition(
            MyApp.myAppKey,
            OurStoryScreen.routeName,
          ),
        );
        widget.onClose();
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CraftsManChargesScreen(
              customCraftsmanModel: widget.customCraftsmanModel,
            ),
          ),
        );
        widget.onClose();
        break;
      // case 5:
      //   AppUtils.navigateTo(
      //     context,
      //     CustomPageTransition(
      //       MyApp.myAppKey,
      //       AboutUsScreen.routeName,
      //     ),
      //   );
      //   widget.onClose();
      //   break;
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
