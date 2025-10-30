import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/branch_management/tabs/craftman_tab.dart';

import 'tabs/employee_tab.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({Key? key}) : super(key: key);

  @override
  BranchManagementScreenState createState() => BranchManagementScreenState();
}

class BranchManagementScreenState extends State<BranchManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 0.sp),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Tabs
            // Container(
            //   height: 30.sp,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: const Color(0xffE4E5E9)),
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(9.sp),
            //   ),
            //   child: TabBar(
            //     controller: _tabController,
            //     indicator: BoxDecoration(
            //       borderRadius: BorderRadius.circular(9.sp),
            //       color: ColorManager.primary,
            //     ),
            //     labelColor: Colors.white,
            //     unselectedLabelColor: ColorManager.primary,
            //     labelStyle: getMediumStyle(
            //       fontSize: FontSize.big,
            //       color: Colors.white,
            //     ),
            //     tabs: const [
            //       // Tab(text: 'Craftsman'),
            //       // Tab(text: 'Employee'),
            //     ],
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    CraftManTab(),
                    // EmployeeTab(),
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
