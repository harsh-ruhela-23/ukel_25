import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukel/bloc/bottom_navbar_bloc.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/screens/branch_management/branch_management_screen.dart';
import 'package:ukel/ui/screens/dashboard/search_screen_view.dart';
import 'package:ukel/ui/screens/francis_management/training/training_screen.dart';
import 'package:ukel/ui/screens/home/home_screen.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_screen.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/notification/notification_screen.dart';
import 'package:ukel/ui/screens/profile/profile_screen.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import '../branch_management/widgets/scan_qr_screen.dart';
import '../drawer_item_screens/partys/partys_screen.dart';
import 'side_navigation_drawer.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/custom_page_transition.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static String routeName = "/dashboard_screen";

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late BottomNavBarBloc _bottomNavBarBloc;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isHomeScreenUpdate = false;

  @override
  void initState() {
    super.initState();
    _bottomNavBarBloc = BottomNavBarBloc();

    AppUtils().getAndSetGlobalServiceList();
  }

  refreshScreen() {}

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: StreamBuilder(
            stream: _bottomNavBarBloc.itemStream,
            initialData: _bottomNavBarBloc.defaultItem,
            builder:
                (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
              return DashboardAppBar(
                isToShowRefreshedIcon:
                    _bottomNavBarBloc.navBarIndex == 0 ? true : false,
                onMenuClick: () => scaffoldKey.currentState!.openDrawer(),
                onNotificationClick: () {
                  AppUtils.navigateTo(
                    context,
                    CustomPageTransition(
                      MyApp.myAppKey,
                      NotificationScreen.routeName,
                    ),
                  );
                },
                onRefreshClick: () {
                  isHomeScreenUpdate = true;
                  setState(() {});
                },
                onScannerClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerView(),
                    ),
                  );
                },
                onSearchClick: () {
                  showSearch(
                      context: context, delegate: SearchScreenView(context));
                },
              );
            },
          ),
        ),
        drawer: SideNavigationDrawer(
          onClose: () {
            scaffoldKey.currentState!.closeDrawer();
          },
        ),
        body: StreamBuilder<NavBarItem>(
          stream: _bottomNavBarBloc.itemStream,
          initialData: _bottomNavBarBloc.defaultItem,
          builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
            switch (snapshot.data) {
              case NavBarItem.HOME:
                return HomeScreen(
                  isHomeScreenRefreshed: isHomeScreenUpdate,
                );
              case NavBarItem.BRANCH:
                return const BranchManagementScreen();
              case NavBarItem.PARTY:
                return const PartyScreen(0);
              default:
                return const ProfileScreen();
            }
          },
        ),
        bottomNavigationBar: StreamBuilder(
          stream: _bottomNavBarBloc.itemStream,
          initialData: _bottomNavBarBloc.defaultItem,
          builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
            return buildBottomNavBar();
          },
        ),
        floatingActionButton: Visibility(
          visible: !isKeyboardOpen,
          child: StreamBuilder(
            stream: _bottomNavBarBloc.itemStream,
            initialData: _bottomNavBarBloc.defaultItem,
            builder:
                (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
              return buildFloatingActionButton();
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  buildBottomNavBar() {
    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        height: 34.sp,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 5.0,
                offset: const Offset(0.0, 0.5))
          ],
          color: Colors.transparent,
          image: const DecorationImage(
            image: AssetImage(ImageAssets.imgBottomNavBG),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBottomNavBarItem(
              0,
              IconAssets.iconBottomNavHome,
              _bottomNavBarBloc.navBarIndex == 0,
            ),
            buildBottomNavBarItem(
              1,
              IconAssets.iconBottomNavBranch,
              _bottomNavBarBloc.navBarIndex == 1,
            ),
            SizedBox(width: 35.sp),
            buildBottomNavBarItem(
              2,
              IconAssets.iconBottomNavFrancis,
              _bottomNavBarBloc.navBarIndex == 2,
            ),
            buildBottomNavBarItem(
              3,
              IconAssets.iconBottomNavProfile,
              _bottomNavBarBloc.navBarIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  buildBottomNavBarItem(int index, String icon, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => _bottomNavBarBloc.pickItem(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.sp),
          child: Stack(
            children: [
              isSelected
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SvgPicture.asset(
                        IconAssets.iconSelectedBottomNavTab,
                      ),
                    )
                  : const SizedBox(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      width: 20.sp,
                      height: 20.sp,
                      color: isSelected
                          ? ColorManager.colorDarkBlue
                          : ColorManager.colorDisable,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return (timestamp ~/ 1000).toString();
  }
  buildFloatingActionButton() {
    return GestureDetector(
      onTap: () async {
        print("serviceInvoiceModel");
        // create default ServiceInvoice Model
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String tag = prefs.getString('tagId') ?? ''; // load saved tag
        print("SharedPreferences $tag");
        ServiceInvoiceModel serviceInvoiceModel = ServiceInvoiceModel(
            branchId: Storage.getValue(FbConstant.uid),
            serviceInvoiceCreatedAtDate: Timestamp.now(),
            serviceInvoiceDueDate: Timestamp.now(),
            serviceInvoiceId: generateRandomId(),
            serviceInvoicePaymentMode: '',
            serviceInvoiceReceivedAmount: 0,
            serviceInvoiceDueAmount: 0,
            serviceInvoiceTotalAmount: 0,
            serviceInvoiceTotalQty: 0,
            serviceInvoiceCode: generateUniqueId(),
            serviceInvoiceCustomerId: '',
            serviceInvoiceNotes: '',
            customerName: '',
            customerPhoneNo: '',
            customerVillage: '',
            sid: '',
            jobIdsList: [],
            serviceInvoiceStatusValue: -1,
            tag: tag,
            couponModel: null);
        log(serviceInvoiceModel.branchId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceInvoiceScreen(
              model: serviceInvoiceModel,
              isNew: true,
            ),
          ),
        );

        // ServiceViewModel()
        //     .createUpdateServiceInvoice(
        //         serviceInvoiceModel: serviceInvoiceModel)
        //     .then((status) {
        //   if (status == AppConstant.success) {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ServiceInvoiceScreen(
        //           model: serviceInvoiceModel,
        //           isNew: true,
        //         ),
        //       ),
        //     );
        //   }
        // });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.sp),
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: ColorManager.colorDarkBlue,
          borderRadius: BorderRadius.circular(40.sp),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              IconAssets.iconPlus,
              height: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
