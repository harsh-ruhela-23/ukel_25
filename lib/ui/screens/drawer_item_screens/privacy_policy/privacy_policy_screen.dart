import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/string_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  static String routeName = "/privacy_policy_screen";

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () {
            AppUtils.navigateUp(context);
          },
          title: "Privacy Policy",
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15.sp),
                margin: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorManager.colorGrey,
                    width: 3.sp,
                  ),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Privacy",
                      style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.big,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      StringManager.ppText,
                      style: getRegularStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.big,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Text(
                      "Policy",
                      style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.big,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      StringManager.ppText,
                      style: getRegularStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.big,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
