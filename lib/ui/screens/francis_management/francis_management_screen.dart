import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/ui/screens/francis_management/note/note_screen.dart';
import 'package:ukel/ui/screens/francis_management/order/order_screen.dart';
import 'package:ukel/ui/screens/francis_management/tell_us/tell_us_screen.dart';
import 'package:ukel/ui/screens/francis_management/training/training_screen.dart';

import '../../../main.dart';
import '../../../resource/assets_manager.dart';
import '../../../resource/color_manager.dart';
import '../../../resource/styles_manager.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/custom_page_transition.dart';

class FrancisManagementScreen extends StatefulWidget {
  const FrancisManagementScreen({Key? key}) : super(key: key);

  @override
  State<FrancisManagementScreen> createState() =>
      _FrancisManagementScreenState();
}

class _FrancisManagementScreenState extends State<FrancisManagementScreen> {
  List<FrancisItemModel> francisList = [];
  @override
  void initState() {
    super.initState();

    francisList = [
      FrancisItemModel(
          title: 'Training',
          icon: IconAssets.iconFrancisTraining,
          bgColor: ColorManager.colorFrancisYellow),
      FrancisItemModel(
          title: 'Product',
          icon: IconAssets.iconFrancisProduct,
          bgColor: ColorManager.colorFrancisCyan),
      FrancisItemModel(
          title: 'Order',
          icon: IconAssets.iconFrancisOrder,
          bgColor: ColorManager.colorFrancisLightPink),
      FrancisItemModel(
          title: 'Tell us',
          icon: IconAssets.iconFrancisTellUs,
          bgColor: ColorManager.colorFrancisPurple),
      FrancisItemModel(
          title: 'Note',
          icon: IconAssets.iconFrancisNote,
          bgColor: ColorManager.colorFrancisLightGreen),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: francisList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 14.0,
                  mainAxisSpacing: 20.0),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      if (index == 0) {
                        // Training Screen
                        AppUtils.navigateTo(
                          context,
                          CustomPageTransition(
                            MyApp.myAppKey,
                            TrainingScreen.routeName,
                          ),
                        );
                      } else if (index == 2) {
                        // Order Screen
                        AppUtils.navigateTo(
                          context,
                          CustomPageTransition(
                            MyApp.myAppKey,
                            OrderScreen.routeName,
                          ),
                        );
                      } else if (index == 3) {
                        // Tell Us Screen
                        AppUtils.navigateTo(
                          context,
                          CustomPageTransition(
                            MyApp.myAppKey,
                            TellUsScreen.routeName,
                          ),
                        );
                      } else if (index == 4) {
                        // Note Screen
                        AppUtils.navigateTo(
                          context,
                          CustomPageTransition(
                            MyApp.myAppKey,
                            NoteScreen.routeName,
                          ),
                        );
                      }
                    },
                    child: francisItemCard(francisList[index]));
              },
            )),
      ),
    );
  }

  Widget francisItemCard(FrancisItemModel item) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: item.bgColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        children: [
          SizedBox(height: 17.sp),
          SvgPicture.asset(
            item.icon,
            height: 25.sp,
          ),
          SizedBox(height: 12.sp),
          Text(
            item.title,
            style: getSemiBoldStyle(
                color: ColorManager.textColorBlack, fontSize: 18.sp),
          )
        ],
      ),
    );
  }
}

class FrancisItemModel {
  String title;
  String icon;
  Color bgColor;

  FrancisItemModel(
      {required this.title, required this.icon, required this.bgColor});
}
