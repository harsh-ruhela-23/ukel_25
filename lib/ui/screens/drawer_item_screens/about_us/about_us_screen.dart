import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/string_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  static String routeName = "/about_us_screen";

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () {
            AppUtils.navigateUp(context);
          },
          title: "About us",
        ),
        body: SingleChildScrollView(
          child: Card(
            elevation: 5.sp,
            child: Container(
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
                    StringManager.ppText,
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.big,
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.sp),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://images.unsplash.com/2/04.jpg?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
                      width: 100.w,
                      height: 55.sp,
                      fadeInCurve: Curves.easeIn,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) => const SizedBox(),
                      fadeInDuration: const Duration(seconds: 1),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Text(
                    StringManager.ppText,
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.big,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
