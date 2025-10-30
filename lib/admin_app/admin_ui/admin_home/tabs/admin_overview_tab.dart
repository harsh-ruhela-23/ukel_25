import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';

import '../../../../resource/color_manager.dart';
import '../../../../resource/fonts_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../ui/screens/home/home_screen.dart';
import '../../../../ui/screens/home/home_view_model.dart';
import '../../../../ui/screens/home/job_list_by_status/job_list_by_status.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/common_widget.dart';
import '../../../../utils/constants.dart';

class AdminOverViewTab extends StatefulWidget {
  const AdminOverViewTab({super.key, this.branchId});

  final String? branchId;

  @override
  State<AdminOverViewTab> createState() => _AdminOverViewTabState();
}

class _AdminOverViewTabState extends State<AdminOverViewTab> {
  List<StatusItemModel> statusList = [];

  @override
  void initState() {
    super.initState();
    Provider.of<HomeViewModel>(context, listen: false)
        .getAllJobItemList(branchId: widget.branchId);
    setData();
  }

  setData() {
    statusList.clear();
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent0,
        title: AppConstant.inShop,
        color: const Color(0xFFFFD54F)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent16,
        title: AppConstant.shipment,
        color: const Color(0xFF4FCDFF)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent34,
        title: AppConstant.inProcess,
        color: const Color(0xFF4FCDFF)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent50,
        title: AppConstant.pickUp,
        color: const Color(0xFFA3B0C3)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent84,
        title: AppConstant.packingQt,
        color: const Color(0xFF877EFD)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent99,
        title: AppConstant.tobeDeliver,
        color: const Color(0xFF79CB9D)));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: viewModel.isAllJobListFetchingData
                ? buildLoadingWidget
                : viewModel.getAllJobItemListError.isNotEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(top: 15.sp, bottom: 15.sp),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: statusList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobListByStatus(
                                      appBarTitle: statusList[index].title,
                                      statusValue:
                                          statusList[index].jobStatusValue,
                                      branchId: widget.branchId,
                                    ),
                                  ),
                                );
                              },
                              child: AdminStatusItemCard(
                                  allJobItemList: viewModel.allJobItemList,
                                  index: index,
                                  data: statusList[index]),
                            );
                          },
                        ),
                      ),
          ),
        );
      },
    );
  }
}

class AdminStatusItemCard extends StatelessWidget {
  const AdminStatusItemCard(
      {Key? key,
      required this.index,
      required this.data,
      required this.allJobItemList})
      : super(key: key);

  final int index;
  final StatusItemModel data;
  final List<JobItemModel> allJobItemList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.sp),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            decoration: BoxDecoration(
                color: data.color, borderRadius: BorderRadius.circular(15.sp)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15.sp),
                Text(
                  data.title,
                  style: getBoldStyle(
                    color: ColorManager.textColorWhite,
                    fontSize: FontSize.large,
                  ),
                ),
                SizedBox(height: 19.sp),
                Row(
                  children: [
                    Text(
                      //data.subTitle,
                      allJobItemList.isNotEmpty
                          ? data.title == AppConstant.inShop
                              ? AppUtils.getTotalInShopJobs(
                                  allJobList: allJobItemList)
                              : data.title == AppConstant.inProcess
                                  ? AppUtils.getTotalInProcessJobs(
                                      allJobList: allJobItemList)
                                  : data.title == AppConstant.shipment
                                      ? AppUtils.getTotalShipmentJobs(
                                          allJobList: allJobItemList)
                                      : data.title == AppConstant.pickUp
                                          ? AppUtils.getTotalPickUpJobs(
                                              allJobList: allJobItemList)
                                          : data.title == AppConstant.packingQt
                                              ? AppUtils.getTotalPackingQtJobs(
                                                  allJobList: allJobItemList)
                                              : data.title ==
                                                      AppConstant.tobeDeliver
                                                  ? AppUtils
                                                      .getTotalToBeDeliveredJobs(
                                                          allJobList:
                                                              allJobItemList)
                                                  : '0 Job'
                          : '0 Job',
                      style: getBoldStyle(
                        color: ColorManager.textColorWhite,
                        fontSize: FontSize.bigExtra,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Go >",
                      style: getBoldStyle(
                        color: ColorManager.textColorWhite,
                        fontSize: FontSize.bigExtra,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
              ],
            ),
          ),
          Positioned(
            top: -18.sp,
            right: -18.sp,
            child: Container(
              height: 33.sp,
              width: 33.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 8,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
