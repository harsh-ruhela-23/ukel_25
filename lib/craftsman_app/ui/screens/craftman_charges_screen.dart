import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/invoice/invoice_details_screen.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/other_widgets.dart';

import '../../../model/crafsman_model.dart';


class CraftsManChargesScreen extends StatefulWidget {
  const CraftsManChargesScreen({Key? key, required this.customCraftsmanModel})
      : super(key: key);
  final CraftsmanModel customCraftsmanModel;

  @override
  State<CraftsManChargesScreen> createState() => _CraftsManChargesScreenState();
}

class _CraftsManChargesScreenState extends State<CraftsManChargesScreen> {
  // for craftsman
  List<JobItemModel> jobItemList = [];
  List<JobItemModel> allJobItemList = [];
  bool isJobListFetchingData = false;
  bool isCraftsmanFetchingData = false;
  final homeRepository = HomeRepository();
  String error = '';
  num totalPayment = 0;

  @override
  void initState() {
    super.initState();
    getJobListByCraftsmanId();
    totalPayment = widget.customCraftsmanModel.qtPassed *
        widget.customCraftsmanModel.serviceInfoModel.serviceCharges;
  }

  void getJobListByCraftsmanId() async {
    jobItemList.clear();
    allJobItemList.clear();
    try {
      if (!isJobListFetchingData) {
        isJobListFetchingData = true;

        await homeRepository
            .fetchJobListByCraftsmanId(widget.customCraftsmanModel.id)
            .then((list) {
          if (list.isNotEmpty) {
            jobItemList.addAll(list);
            allJobItemList.addAll(list);
          }
        });
        error = '';
        isJobListFetchingData = false;
      }
    } catch (e) {
      isJobListFetchingData = false;
      error = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    filterJobListByStatus({required String inOutValue}) {
      if (inOutValue == 'OUT') {
        if (widget.customCraftsmanModel.outJobIdsList.isNotEmpty) {
          if (allJobItemList.isNotEmpty) {
            jobItemList.clear();
            for (var element in widget.customCraftsmanModel.outJobIdsList) {
              for (var allJobItem in allJobItemList) {
                if (allJobItem.jobId == element.toString()) {
                  jobItemList.add(allJobItem);
                }
              }
            }
          }
        } else {
          jobItemList.clear();
        }
      }
      setState(() {});
    }

    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () => AppUtils.navigateUp(context),
        title: "Charges",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.sp, vertical: 2.sp),
          decoration: BoxDecoration(
            color: const Color(0xffE4E5E9),
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your ${AppUtils.parseDate(DateTime.now().millisecondsSinceEpoch, 'MMMM')} month Charges',
                  style: getBoldStyle(
                    color: ColorManager.primary,
                    fontSize: FontSize.big,
                  ),
                ),
                Text(
                  '₹ $totalPayment',
                  style: getBoldStyle(
                    color: ColorManager.primary,
                    fontSize: FontSize.large,
                  ),
                ),
              ],
            ),
            children: <Widget>[
              isJobListFetchingData
                  ? buildLoadingWidget
                  : error.isNotEmpty
                      ? Center(
                          child: Text(error.toString()),
                        )
                      : jobItemList.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 35.sp),
                              child: const Center(
                                child: Text('No Jobs Available Currently'),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: jobItemList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 15.sp),
                                    child: JobItems(
                                      onClick: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                JobStatusScreen(
                                                    jobItemModel:
                                                        jobItemList[index]),
                                          ),
                                        );
                                      },
                                      jobItemModel: jobItemList[index],
                                    ),
                                  );
                                },
                              ),
                            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statusCard({required String key, required String value}) {
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
            key,
            style: getBoldStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.medium,
            ),
          ),
          SizedBox(height: 10.sp),
          Text(
            value,
            style: getBoldStyle(
              color: ColorManager.colorGrey,
              fontSize: FontSize.large,
            ),
          ),
        ],
      ),
    );
  }

  Widget workHistoryCard(
      {required String name,
      required String location,
      required String phoneNo,
      required String mobileNo,
      required String service,
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
              Row(
                children: [
                  Text(
                    name,
                    style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.large),
                  ),
                  SizedBox(width: 15.sp),
                  SvgPicture.asset(IconAssets.iconWorkHistory, height: 18.sp)
                ],
              ),
              SizedBox(height: 14.sp),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Location : ',
                      style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra),
                    ),
                    TextSpan(
                      text: location,
                      style: getBoldStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.mediumExtra),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.sp),
              InkWell(
                onTap: () => makePhoneCall(mobileNo),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mobile Number : ',
                        style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.mediumExtra),
                      ),
                      TextSpan(
                        text: mobileNo,
                        style: getBoldStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.mediumExtra),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.sp),
              InkWell(
                onTap: () => makePhoneCall(phoneNo),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Phone Number : ',
                        style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.mediumExtra),
                      ),
                      TextSpan(
                        text: phoneNo,
                        style: getBoldStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.mediumExtra),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.sp),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Service : ',
                      style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra),
                    ),
                    TextSpan(
                      text: service,
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

  Widget runningDoneCard(
      {required String runningValue,
      required String doneValue,
      required String qTValue,
      required Function onTapAppointed,
      required Function onTapRunning,
      required Function onTapDone,
      required Function onTapQT,
      required String appointedValue}) {
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
          // Appointed
          Expanded(
            child: InkWell(
              onTap: () => onTapAppointed(),
              child: Column(
                children: [
                  Text(
                    'Appointed',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    appointedValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Running
          Expanded(
            child: InkWell(
              onTap: () => onTapRunning(),
              child: Column(
                children: [
                  Text(
                    'Running',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    runningValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Done
          Expanded(
            child: InkWell(
              onTap: () => onTapDone(),
              child: Column(
                children: [
                  Text(
                    'Done',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    doneValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),

          // QT
          Expanded(
            child: InkWell(
              onTap: () => onTapQT(),
              child: Column(
                children: [
                  Text(
                    'QT',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    qTValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rowCard(
      {required String workCapacityValue,
      required String remainingDaysValue,
      required String totalSalary}) {
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
          // Work capacity
          Expanded(
            child: Column(
              children: [
                Text(
                  'Work capacity',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  workCapacityValue,
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
          SizedBox(width: 15.sp),

          // Remaining Days
          Expanded(
            child: Column(
              children: [
                Text(
                  'Remaining Days',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  remainingDaysValue,
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

          // Total Salary
          Expanded(
            child: Column(
              children: [
                Text(
                  'Total Salary',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  totalSalary.toString(),
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.large,
                  ),
                ),
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
                      color: ColorManager.primary, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  day,
                  style: getRegularStyle(
                      color: ColorManager.primary, fontSize: 16.sp),
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
                      color: ColorManager.colorGrey, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime1,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime2,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
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
                      color: ColorManager.colorGrey, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime1,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime2,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
