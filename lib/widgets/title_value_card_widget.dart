import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/fonts_manager.dart';

import '../resource/color_manager.dart';
import '../resource/styles_manager.dart';

class TitleValueCardWidget extends StatelessWidget {
  const TitleValueCardWidget(
      {Key? key, required this.title, required this.value})
      : super(key: key);
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 17.sp),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorManager.colorLightGrey,
          style: BorderStyle.solid,
          width: 1.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: getMediumStyle(
              color: ColorManager.btnColorDarkBlue,
              fontSize: FontSize.large,
            ),
          ),
          SizedBox(height: 10.sp),
          Text(
            value,
            style: getMediumStyle(
              color: ColorManager.textColorGrey,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      ),
    );
  }
}
