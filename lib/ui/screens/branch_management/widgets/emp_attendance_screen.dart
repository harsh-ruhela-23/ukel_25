import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

import '../../../../utils/app_utils.dart';
import '../../../../widgets/custom_app_bar.dart';

class EmpAttendanceScreen extends StatelessWidget {
  const EmpAttendanceScreen({Key? key}) : super(key: key);

  static String routeName = "/emp_attendance_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "Attendance",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.sp),

            // Attendance Item card
            attendanceItemCard(
                name: 'Kartik Patel',
                post: 'Manager',
                eID: 'AE03',
                onPressAbout: () {
                  // About Employee Screen
                  // AppUtils.navigateTo(
                  //   context,
                  //   CustomPageTransition(
                  //     MyApp.myAppKey,
                  //     AboutCraftsmanScreen.routeName,
                  //   ),
                  // );
                }),
            SizedBox(height: 15.sp),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'November',
                  style: getBoldStyle(
                    color: ColorManager.primary,
                    fontSize: FontSize.large,
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(IconAssets.iconPrevious, height: 20.sp),
                    SizedBox(width: 10.sp),
                    SvgPicture.asset(IconAssets.iconNext, height: 20.sp)
                  ],
                )
              ],
            ),
            SizedBox(height: 15.sp),

            // days Leave Card
            daysLeaveCard(
                workingDays: '26/30', leave: '4', totalSalary: '₹ 5000'),
            SizedBox(height: 15.sp),

            // Attendance List
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.sp),
                  child: attendanceItemCheckInCheckOutButton(
                      checkInTime1: '08:00',
                      checkInTime2: '14:00',
                      checkOutTime1: '13:00',
                      checkOutTime2: '19:00',
                      date: '1',
                      day: 'Mon'),
                );
              },
            ),
            SizedBox(height: 30.sp),
          ],
        ),
      ),
    );
  }

  Widget attendanceItemCard(
      {required String name,
      required String post,
      required String eID,
      required Function onPressAbout}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.large),
              ),
              SizedBox(height: 14.sp),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Post : ',
                      style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big),
                    ),
                    TextSpan(
                      text: post,
                      style: getBoldStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.mediumExtra),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.sp),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'EID : ',
                      style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big),
                    ),
                    TextSpan(
                      text: eID,
                      style: getBoldStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.mediumExtra),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
              onTap: () => onPressAbout(),
              child: SvgPicture.asset(IconAssets.iconAbout)),
        ],
      ),
    );
  }

  Widget daysLeaveCard(
      {required String workingDays,
      required String leave,
      required String totalSalary}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              color: Colors.grey, blurRadius: 1.0, offset: Offset(0.0, 0.25))
        ],
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        children: [
          // Working Days
          Expanded(
            child: Column(
              children: [
                Text(
                  'Working Days',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  workingDays,
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.large,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Leave',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  leave,
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.large,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Salary Slip',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                SvgPicture.asset(
                  IconAssets.iconWhatsapp,
                  height: 20.sp,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget attendanceItemCheckInCheckOutButton(
      {required String checkInTime1,
      required String checkInTime2,
      required String checkOutTime1,
      required String checkOutTime2,
      required String date,
      required String day}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 15.sp),
            decoration: BoxDecoration(
              color: const Color(0xffE5E9FF),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              children: [
                Text(
                  date,
                  style: getBoldStyle(
                      color: ColorManager.primary, fontSize: FontSize.bigExtra),
                ),
                SizedBox(height: 12.sp),
                Text(
                  day,
                  style: getRegularStyle(
                      color: ColorManager.primary, fontSize: FontSize.medium),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.sp),
          // Container(
          //   height: 30.sp,
          //   width: 5.sp,
          //   color: ColorManager.colorLightGrey,
          // ),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Check In',
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime1,
                  style: getRegularStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime2,
                  style: getRegularStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 35.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Check Out',
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime1,
                  style: getRegularStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime2,
                  style: getRegularStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
