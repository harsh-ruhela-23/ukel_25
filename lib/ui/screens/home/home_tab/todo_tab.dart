import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

class ToDoTab extends StatefulWidget {
  const ToDoTab({Key? key, required this.homeViewModel}) : super(key: key);
  final HomeViewModel homeViewModel;

  @override
  State<ToDoTab> createState() => _ToDoTabState();
}

class _ToDoTabState extends State<ToDoTab> {
  @override
  Widget build(BuildContext context) {
    widget.homeViewModel.todoList
        .sort((a, b) => b.jobItemDueDate.compareTo(a.jobItemDueDate));

    return widget.homeViewModel.isAllJobListFetchingData
        ? buildLoadingWidget
        : widget.homeViewModel.todoList.isEmpty
            ? Center(
                child: Text(
                  'No TODO Available!!',
                  style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.bigExtra),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await widget.homeViewModel.getAllJobItemList();
                  setState(() {});
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.homeViewModel.todoList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: index ==
                                        widget.homeViewModel.todoList.length - 1
                                    ? 40.sp
                                    : 0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobStatusScreen(
                                      jobItemModel:
                                          widget.homeViewModel.todoList[index],
                                    ),
                                  ),
                                );
                              },
                              child: ToDoItems(
                                  item: widget.homeViewModel.todoList[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
  }
}

// Job Item
class ToDoItems extends StatelessWidget {
  const ToDoItems({Key? key, required this.item}) : super(key: key);
  final JobItemModel item;

  int getPercentage(double value) {
    return (value * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15.sp),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ColorManager.colorGrey,
          width: 2.sp,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
          
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.sp),
                child: CachedNetworkImage(
                  imageUrl: item.jobItemImageUrl,
                  width: 15.w,
                  height: 15.w,
                  fadeInCurve: Curves.easeIn,
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) =>
                      Image.asset(ImageAssets.jobItemImagePlaceholder),
                  fadeInDuration: const Duration(seconds: 1),
                ),
              ),
              // CircularPercentIndicator(
              //   radius: 22.sp,
              //   lineWidth: 5.0,
              //   percent: AppUtils.getPercentageForIndicator(item.jobItemPercentage),
              //   center: Text(
              //     "${item.jobItemPercentage}%",
              //     style: getMediumStyle(
              //       color: ColorManager.textColorBlack,
              //       fontSize: FontSize.small,
              //     ),
              //   ),
              //   progressColor:
              //       AppUtils.getProgressIndicatorColor(item.jobItemPercentage),
              //   backgroundColor:
              //       AppUtils.getProgressIndicatorColor(item.jobItemPercentage)
              //           .withOpacity(0.3),
              // ),
              SizedBox(width: 15.sp),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.customerModel.name,
                            style: getBoldStyle(
                              color: ColorManager.textColorBlack,
                              fontSize: FontSize.big,
                            ),
                          ),
                        ),
                        Text(
                          '#${item.jobItemCode}',
                          style: getMediumStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.medium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.selectedCraftsmanName.isEmpty
                                ? '-'
                                : item.selectedCraftsmanName,
                            style: getMediumStyle(
                              color: ColorManager.textColorGrey,
                              fontSize: FontSize.medium,
                            ),
                          ),
                        ),
                        Text(
                          AppUtils.getJobStatusName(item.jobItemPercentage),
                          style: getMediumStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.medium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "Due: ",
                                style: getMediumStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.medium,
                                ),
                              ),
                              Text(
                                AppUtils.parseDate(
                                    item.jobItemDueDate, AppConstant.dd_mm_yyyy),
                                style: getMediumStyle(
                                  color: ColorManager.textColorGrey,
                                  fontSize: FontSize.medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppUtils.parseDate(
                              item.jobItemCreatedAtDate, AppConstant.dd_mm_yyyy),
                          style: getMediumStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
           const SizedBox(height: 10,),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.jobItemPercentage}%",
                    style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
              ),
               const SizedBox(height: 2,),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent:
                    AppUtils.getPercentageForIndicator(item.jobItemPercentage),
                    barRadius: const Radius.circular(20),
                progressColor: const Color(0xff877EFD),
                backgroundColor: const Color(0xffE1FAEC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
