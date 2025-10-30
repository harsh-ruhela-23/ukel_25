import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_craftman_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_delivery_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_employee_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_job_tab.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/tabs/admin_overview_tab.dart';
import 'package:ukel/model/branch_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class BranchDetailsScreen extends StatefulWidget {
  const BranchDetailsScreen({Key? key, required this.branchModel})
      : super(key: key);
  final BranchModel branchModel;

  @override
  State<BranchDetailsScreen> createState() => _BranchDetailsScreenState();
}

class _BranchDetailsScreenState extends State<BranchDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          title: widget.branchModel.branchDetailsModel!.ownerAddress,
          onBackClick: () {
            Navigator.pop(context);
          },
        ),
        body: Column(
          children: [
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
                  tabs: const [
                    Tab(text: "OverView"),
                    Tab(text: "Delivery"),
                    Tab(text: "Job"),
                    Tab(text: "Employee"),
                    Tab(text: "Craftsman"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AdminOverViewTab(branchId: widget.branchModel.id!),
                    AdminDeliveryTab(branchId: widget.branchModel.id!),
                    AdminJobTab(branchId: widget.branchModel.id!),
                    AdminEmployeeTab(branchId: widget.branchModel.id!),
                    AdminCraftManTab(branchId: widget.branchModel.id!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
