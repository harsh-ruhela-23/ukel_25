import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/francis_management/training/tabs/training_item_details_screen.dart';

import '../../../../../main.dart';
import '../../../../../resource/assets_manager.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../../utils/custom_page_transition.dart';

class ToLearnTab extends StatelessWidget {
  const ToLearnTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.sp),
          child: InkWell(
              onTap: () {
                // navigate to training item details screen
                AppUtils.navigateTo(
                  context,
                  CustomPageTransition(
                    MyApp.myAppKey,
                    TrainingItemDetailsScreen.routeName,
                  ),
                );
              },
              child: trainingToLearnItemCard()),
        );
      },
    );
  }

  Widget trainingToLearnItemCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38.sp,
          width: 48.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.sp),
            image: const DecorationImage(
              image: NetworkImage(
                'https://dpbnri2zg3lc2.cloudfront.net/en/wp-content/uploads/2021/07/UX-design-course.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: SvgPicture.asset(
            IconAssets.iconVideoPlay,
            height: 23.sp,
            width: 23.sp,
          ),
        ),
        SizedBox(width: 13.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Applications Computer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getSemiBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: isTablet ? FontSize.mediumExtra : FontSize.bigExtra,
                ),
              ),
              SizedBox(height: 13.sp),
              Text(
                'Omnis provident maxime sit. In est nihil assumenda commodi aliquid.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  color: ColorManager.textColorGrey,
                  fontSize: FontSize.mediumExtra,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
