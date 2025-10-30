import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/ui/screens/francis_management/training/tabs/completed_tab.dart';
import 'package:ukel/ui/screens/francis_management/training/tabs/to_learn_tab.dart';

import '../../../../resource/assets_manager.dart';
import '../../../../resource/color_manager.dart';
import '../../../../resource/styles_manager.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  static String routeName = "/training_screen";

  @override
  TrainingScreenState createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen>
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
    return Scaffold(
      // appBar: OtherScreenAppBar(
      //   onBackClick: () {
      //     AppUtils.navigateUp(context);
      //   },
      //   title: "Training",
      // ),
      body: Padding(
        padding: EdgeInsets.all(18.sp),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Search
              buildSearch(),
              SizedBox(height: isTablet ? 15.sp : 20.sp),

              // Tabs
              Container(
                height: isTablet ? 26.sp : 30.sp,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffE4E5E9)),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9.sp),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.sp),
                    color: ColorManager.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ColorManager.primary,
                  labelStyle: getMediumStyle(
                    fontSize: FontSize.big,
                    color: Colors.white,
                  ),
                  tabs: const [
                    Tab(text: 'To Learn'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      ToLearnTab(),
                      CompletedTab(),
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

  Widget buildSearch() {
    return TextField(
      decoration: InputDecoration(
        contentPadding: isTablet ? EdgeInsets.all(14.sp) : EdgeInsets.zero,
        prefixIcon: Padding(
          padding: EdgeInsets.fromLTRB(10.sp, 15.sp, 0, 15.sp),
          child: SvgPicture.asset(
            IconAssets.iconSearch,
            height: 5.sp,
            color: ColorManager.colorGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            width: 4.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            width: 4.sp,
            color: const Color(0xffE4E5E9), 
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            width: 4.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            width: 4.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        hintText: 'Search Craftman',
        hintStyle: getRegularStyle(
          color: ColorManager.colorGrey,
          fontSize: FontSize.mediumExtra,
        ),
      ),
    );
  }
}
