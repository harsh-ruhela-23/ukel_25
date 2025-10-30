import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

import '../../../../../utils/app_utils.dart';
import '../../../../../widgets/custom_app_bar.dart';

class TrainingItemDetailsScreen extends StatelessWidget {
  const TrainingItemDetailsScreen({Key? key}) : super(key: key);

  static String routeName = "/training_item_details_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "How to talk with customer",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffE4E5E9)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Card
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
              ),
              SizedBox(height: 15.sp),
              Text(
                'How to talk with customer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getSemiBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.large,
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
              ),
              SizedBox(height: 18.sp),

              Text(
                'Learnings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getSemiBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.bigExtra,
                ),
              ),
              SizedBox(height: 13.sp),
              Text(
                '1.Greetings \n\n2.Understanding \n\n3.Greetings',
                style: getMediumStyle(
                  color: ColorManager.textColorGrey,
                  fontSize: FontSize.big,
                ),
              ),

              SizedBox(height: 22.sp),
              Text(
                '1.Greetings',
                style: getMediumStyle(
                  color: ColorManager.textColorGrey,
                  fontSize: FontSize.big,
                ),
              ),

              SizedBox(height: 13.sp),
              Text(
                'Qui sint ut doloribus omnis eaque voluptas est. Repellendus impedit rerum sed assumenda. Minus et et voluptatem atque. Fugit numquam nesciunt commodi unde similique autem.',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: ColorManager.textColorGrey,
                  fontSize: FontSize.mediumExtra,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
