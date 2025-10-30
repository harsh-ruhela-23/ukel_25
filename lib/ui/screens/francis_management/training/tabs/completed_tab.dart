import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

import '../../../../../main.dart';
import '../../../../../resource/assets_manager.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../../utils/custom_page_transition.dart';
import 'training_item_details_screen.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 18.sp),
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
                  child: trainingCompletedItemCard(),
                ),
              );
            },
          ),

          // Playlist card
          Container(
            padding: EdgeInsets.all(13.sp),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffE4E5E9)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(9.sp),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 55.sp,
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.sp),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://dpbnri2zg3lc2.cloudfront.net/en/wp-content/uploads/2021/07/UX-design-course.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    height: 55.sp,
                    width: 50.sp,
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '10',
                          style: getSemiBoldStyle(
                            color: ColorManager.white,
                            fontSize: FontSize.large,
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        Icon(
                          Icons.menu,
                          color: ColorManager.white,
                          size: 22.sp,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Applications Computer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getSemiBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize:
                            isTablet ? FontSize.mediumExtra : FontSize.large,
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
                SizedBox(height: 15.sp),
              ],
            ),
          ),
          SizedBox(height: 30.sp)
        ],
      ),
    );
  }

  Widget trainingCompletedItemCard() {
    return Container(
      padding: EdgeInsets.all(13.sp),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE4E5E9)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.sp),
      ),
      child: Row(
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
                    fontSize: isTablet ? FontSize.big : FontSize.bigExtra,
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
      ),
    );
  }
}
