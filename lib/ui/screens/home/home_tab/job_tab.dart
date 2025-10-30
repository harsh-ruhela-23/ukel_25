import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/ui/screens/home/invoice/invoice_details_screen.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

class JobTab extends StatefulWidget {
  const JobTab({Key? key, required this.viewModel}) : super(key: key);
  final HomeViewModel viewModel;

  @override
  State<JobTab> createState() => _JobTabState();
}

class _JobTabState extends State<JobTab> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.getJobList();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      widget.viewModel.getAllJobItemList();
      widget.viewModel.getJobList();
    }, context: context);
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewModel.isJobListFetchingData
        ? buildLoadingWidget
        : widget.viewModel.getJobListApiError.isNotEmpty
            ? buildErrorWidget(widget.viewModel.getJobListApiError)
            : widget.viewModel.jobList.isEmpty
                ? buildEmptyDataWidget('No Jobs Available!!')
                : Padding(
                    padding: EdgeInsets.only(top: 18.sp),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await widget.viewModel.getJobList();
                        setState(() {});
                      },
                      child: GroupedListView(
                        // sort: false,
                        // reverse: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        elements: widget.viewModel.jobList,
                        groupBy: (element) => AppUtils.parseDate(
                            element.serviceInvoiceCreatedAtDate
                                .millisecondsSinceEpoch,
                            AppConstant.yMMMMd),
                        groupSeparatorBuilder: (String groupByValue) => Padding(
                          padding: EdgeInsets.only(bottom: 18.sp),
                          child: Text(
                            groupByValue,
                            style: getBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.big),
                          ),
                        ),
                        indexedItemBuilder: (context, element, index) =>
                            InkWell(
                          onTap: () {
                            // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                            if (element.serviceInvoiceStatusValue == -1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceInvoiceScreen(
                                      model: element, isUpdate: true),
                                ),
                              );
                            } else {
                              // navigate to InvoiceDetailScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InvoiceDetailsScreen(model: element),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  widget.viewModel.getJobList();
                                  setState(() {});
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == widget.viewModel.jobList.length - 1
                                        ? 8.sp
                                        : 0),
                            child: DeliveryJobItem(
                                allJobList: widget.viewModel.allJobItemList,
                                serviceInvoiceModel: element),
                          ),
                        ),
                        itemComparator: (item1, item2) => int.parse(item1
                            .serviceInvoiceCode.replaceAll(" ", ""))
                            .compareTo(int.parse(item2.serviceInvoiceCode.replaceAll(" ", ""))),
                        order: GroupedListOrder.DESC,
                      ),
                    ),
                  );
  }
}

// DeliveryJobItem
class DeliveryJobItem extends StatelessWidget {
  const DeliveryJobItem(
      {Key? key, required this.serviceInvoiceModel, required this.allJobList})
      : super(key: key);

  final ServiceInvoiceModel serviceInvoiceModel;
  final List<JobItemModel> allJobList;

  @override
  Widget build(BuildContext context) {
    List<JobItemModel> jobItemList = AppUtils.getJobsListByServiceInvoice(
        allJobsList: allJobList, serviceInvoiceModel: serviceInvoiceModel);

    int percentage = AppUtils.getServiceCompleteStatusPer(jobItemList);
    List<String> imgesUrl = AppUtils.getImagesListtatusPer(jobItemList);
    String invoiceStatus =
        AppUtils.getServiceInvoiceStatusNameByPercent(percentage);

    return Container(
      margin: EdgeInsets.only(bottom: 15.sp),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ColorManager.colorGrey,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  height: 45,
                  width: 50,
                  child: StackedImages(imageUrls: imgesUrl)),
              SizedBox(width: 15.sp),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            serviceInvoiceModel.customerName.isEmpty
                                ? '-'
                                : serviceInvoiceModel.customerName,
                            style: getBoldStyle(
                              color: ColorManager.textColorBlack,
                              fontSize: FontSize.big,
                            ),
                          ),
                        ),
                        Text(
                          '#${serviceInvoiceModel.tag}-${serviceInvoiceModel.sid.toString()}',
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
                            "Job : ${serviceInvoiceModel.jobIdsList.length} Pcs",
                            style: getMediumStyle(
                              color: ColorManager.textColorGrey,
                              fontSize: FontSize.mediumExtra,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.sp, vertical: 10.sp),
                          decoration: BoxDecoration(
                              color: invoiceStatus == 'Pending'
                                  ? const Color(0xFFEE334B)
                                  : invoiceStatus == 'Successful'
                                      ? const Color(0xFF52CC87)
                                      : const Color(0xFF4FCDFF),
                              borderRadius: BorderRadius.circular(10.sp)),
                          child: Text(
                            serviceInvoiceModel.serviceInvoiceStatusValue == -1
                                ? 'InCompleted'
                                : invoiceStatus,
                            style: getMediumStyle(
                              color: ColorManager.textColorWhite,
                              fontSize: FontSize.small,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "     (${imgesUrl.length})",
                    style: getMediumStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.mediumExtra,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2.w),
                    child: Text(
                      " $percentage%",
                      style: getMediumStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.mediumExtra,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: percentage / 100,
                barRadius: const Radius.circular(20),
                progressColor:
                    AppUtils.getProgressIndicatorColor(percentage.toString()),
                backgroundColor: const Color(0xffE1FAEC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StackedImages extends StatelessWidget {
  final List<String> imageUrls;

  StackedImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    int visibleImageCount = 3;
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImageDialog(
              imageUrls: imageUrls,
            );
          },
        );
      },
      child: Stack(
        children: imageUrls
            .asMap()
            .entries
            .map((entry) {
              int index = entry.key;
              String path = entry.value;

              // Set scale and offset for overlap
              double scale = 1.0;
              double offset = index * 10.0;

              // Ensure scale does not go below a minimum value
              scale = scale.clamp(0.5, 1.0);

              return Positioned(
                left: offset / 3,
                top: offset / 8,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 45,
                            height: 45,
                            color: Colors.white,
                          ),
                        ),
                        Image.network(
                          path,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                        if (index == visibleImageCount - 1 &&
                            imageUrls.length > visibleImageCount)
                          Container(
                            width: 45,
                            height: 45,
                            color: Colors.black.withOpacity(0.5),
                            alignment: Alignment.center,
                            child: Text(
                              '+${imageUrls.length - visibleImageCount}',
                              style:
                                  const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .take(visibleImageCount)
            .toList(),
      ),
    );
  }
}

class ImageDialog extends StatefulWidget {
  const ImageDialog({Key? key, required this.imageUrls}) : super(key: key);
  final List<String> imageUrls;
  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  String? selectedImage;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    selectedImage = widget.imageUrls[0];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Products',
                    style:
                        TextStyle(fontSize: 2.h, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close_outlined,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(selectedImage!, fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.white,
                        ),
                      );
                    }
                  })),
            ),
          ),
          Container(
            height: 78,
            child: Scrollbar(
              thumbVisibility: true,
              // thumbColor: Colors.blue,
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = widget.imageUrls[index];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(widget.imageUrls[index],
                              width: 78,
                              height: 70,
                              fit: BoxFit.cover, loadingBuilder:
                                  (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 150,
                                  height: 200,
                                  color: Colors.white,
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
