import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/ui/screens/home/invoice/pdf_viewer.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/other_widgets.dart';
import 'package:flutter/material.dart' hide CarouselController;
import '../../../../services/get_storage.dart';
import '../../../../widgets/full_screen_image.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  static String routeName = "/invoice_details_screen";

  const InvoiceDetailsScreen({Key? key, required this.model}) : super(key: key);
  final ServiceInvoiceModel model;

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  late StreamController _dotController;
  bool isInfoExpanded = false;
  final CarouselSliderController _carouselController = CarouselSliderController();

  // List<JobItemModel> invoiceJobList = [];
  // bool isInvoiceJobListFetchingData = false;
  // String error = '';

  @override
  void initState() {
    super.initState();
    _dotController = StreamController.broadcast();
    // getInvoiceJobList()

    Provider.of<ServiceViewModel>(context, listen: false).getServicesList();
    Provider.of<ServiceViewModel>(context, listen: false)
        .getJobItemList(widget.model.serviceInvoiceId);

    calculateSubTotal();
    calculateDiscount();
  }

  void confirmationForChangeStatus(ServiceViewModel viewModel) {
    String title = "Are you sure want to\ndeliver all jobs?";
    String negativeLabel = "Cancel";
    String positiveLabel = "Yes";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          negativeLabel: negativeLabel,
          positiveLabel: positiveLabel,
          negativeButtonBorder: Border.all(
            color: ColorManager.colorDarkBlue,
          ),
          onNegativeClick: () {
            Navigator.pop(context);
          },
          onPositiveClick: () async {
            Navigator.pop(context);
            completeAllJobItems(viewModel);
          },
          negativeButtonColor: ColorManager.white,
          negativeTextColor: ColorManager.colorDarkBlue,
          positiveButtonColor: ColorManager.colorDarkBlue,
          positiveTextColor: ColorManager.textColorWhite,
        );
      },
    );
  }

  void completeAllJobItems(ServiceViewModel viewModel) async {
    for (int i = 0; i < viewModel.jobItemList.length; i++) {
      JobItemModel jobItemModel = viewModel.jobItemList[i];
      if (jobItemModel.timelineStatusObj != null) {
        AddJobTimeLineModel timeLineModel = jobItemModel
            .timelineStatusObj![jobItemModel.timelineStatusObj!.length - 1];
        if (!timeLineModel.isComplete) {
          timeLineModel.isComplete = true;
          timeLineModel.completedDate = DateTime.now().millisecondsSinceEpoch;
          jobItemModel.jobItemPercentage = JobPercentConstant.percent100;
          await viewModel.updateJobItem(jobItemModel);
        }
      }
    }
    FBroadcast.instance().broadcast(BroadCastConstant.homeScreenUpdate);
    setState(() {});
  }

  // // getInvoiceJobList
  // Future getInvoiceJobList() async {
  //   try {
  //     invoiceJobList.clear();
  //     if (!isInvoiceJobListFetchingData) {
  //       isInvoiceJobListFetchingData = true;
  //
  //       await homeRepository
  //           .getJobListByServiceInvoiceId(widget.model.serviceInvoiceId)
  //           .then((list) {
  //         if (list.isNotEmpty) {
  //           invoiceJobList.addAll(list);
  //         }
  //       });
  //
  //       isInvoiceJobListFetchingData = false;
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     isInvoiceJobListFetchingData = false;
  //     error = e.toString();
  //     setState(() {});
  //   }
  // }

  @override
  void dispose() {
    _dotController.close();
    super.dispose();
  }

  void printInvoice(ServiceViewModel viewModel) async {
    await AppUtils.generateInvoicePdf(widget.model, viewModel).then((path) {
      if (path.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(path: path),
          ),
        );
      }
    });
  }

  num discount = 0;
  num totalQty = 0;
  num subTotal = 0;

  calculateDiscount() {
    if (widget.model.couponModel != null) {
      if (widget.model.serviceInvoiceTotalAmount >
          num.parse(widget.model.couponModel!.amount!)) {
        discount = num.parse(widget.model.couponModel!.amount!);
      } else {
        discount = widget.model.serviceInvoiceTotalAmount;
      }
    } else {
      discount = 0;
    }
    setState(() {});
  }

  calculateSubTotal() {
    totalQty = 0;
    subTotal = 0;
    widget.model.priceModel?.forEach((element) {
      totalQty += element.qty;
      subTotal += (element.amount);
      print("total: $subTotal");
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    Future<void> deleteJobItems(ServiceViewModel viewModel) async {
      if (viewModel.jobItemList.isNotEmpty) {
        print("joblist: ${viewModel.jobItemList..length}");
        for (int i = 0; i < viewModel.jobItemList.length; i++) {
          await viewModel.deleteJobItem(viewModel.jobItemList[i].jobId);
        }
      }
    }

    void handleClick(int item, ServiceViewModel viewModel) {
      switch (item) {
        case 0:
          printInvoice(viewModel);
          break;
        case 1:
          break;
        case 2:
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationDialog(
                title: "Are you sure want to delete item!",
                negativeLabel: "Cancel",
                positiveLabel: "Delete",
                onNegativeClick: () => Navigator.pop(context),
                onPositiveClick: () async {
                  await deleteJobItems(viewModel);
                  viewModel
                      .deleteServiceInvoiceItem(widget.model.serviceInvoiceId);
                  AppUtils.navigateUp(context);
                  AppUtils.navigateUp(context, argument: true);
                },
              );
            },
          );
          break;
        case 3:
          break;
      }
    }

    return SafeArea(
      child: Consumer<ServiceViewModel>(
        builder: (context, viewModel, child) {
          List<String> jobItemImageUrlList = [];
          bool isDeleteEnable = true;

          if (viewModel.jobItemList.isNotEmpty) {
            for (var element in viewModel.jobItemList) {
              jobItemImageUrlList.add(element.jobItemImageUrl);
              print(element.jobItemImageUrl);
              print("jobItemImageUrl");
            }
          }

          if (viewModel.jobItemList.isNotEmpty) {
            for (var element in viewModel.jobItemList) {
              if (element.selectedCraftsmanId.isNotEmpty) {
                isDeleteEnable = false;
              }
            }
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorManager.white,
              toolbarHeight: 32.sp,
              titleTextStyle: getBoldStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.large,
              ),
              centerTitle: false,
              elevation: 0,
              title: Text(
                'Invoice Details',
                style: getBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.large,
                ),
              ),
              leading: Padding(
                padding: EdgeInsets.only(left: 15.sp),
                child: GestureDetector(
                  onTap: () => AppUtils.navigateUp(context),
                  child: SvgPicture.asset(
                    IconAssets.iconBack,
                    height: 10.sp,
                    width: 10.sp,
                  ),
                ),
              ),
              actions: [
                // Padding(
                //   padding: EdgeInsets.only(right: 15.sp),
                //   child: Row(
                //     children: [
                //       GestureDetector(
                //         onTap: () {},
                //         child: SvgPicture.asset(IconAssets.iconPrint),
                //       ),
                //       SizedBox(width: 15.sp),
                //       GestureDetector(
                //         onTap: () {
                //           showDialog(
                //             context: context,
                //             builder: (BuildContext context) {
                //               return ConfirmationDialog(
                //                 title: "Are you sure want to delete item!",
                //                 negativeLabel: "Cancel",
                //                 positiveLabel: "Delete",
                //                 onNegativeClick: () => Navigator.pop(context),
                //                 onPositiveClick: () {
                //                   viewModel.deleteServiceInvoiceItem(
                //                       widget.model.serviceInvoiceId);
                //                   AppUtils.navigateUp(context);
                //                   AppUtils.navigateUp(context, argument: true);
                //                 },
                //               );
                //             },
                //           );
                //         },
                //         child: const Icon(Icons.more_vert_sharp),
                //       ),
                //     ],
                //   ),
                // )
                if (Storage.getValue(AppConstant.role) == "B")
                  PopupMenuButton<int>(
                    offset: const Offset(-33, 30),
                    onSelected: (item) => handleClick(item, viewModel),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            SvgPicture.asset(IconAssets.iconPrint,
                                height: 18.sp),
                            SizedBox(width: 15.sp),
                            Text(
                              'Print Invoice',
                              style: getMediumStyle(
                                  fontSize: 16.sp,
                                  color: ColorManager.colorBlack),
                            ),
                          ],
                        ),
                      ),
                      // PopupMenuItem<int>(
                      //   value: 1,
                      //   child: Row(
                      //     children: [
                      //       SvgPicture.asset(IconAssets.iconPrint, height: 18.sp),
                      //       SizedBox(width: 15.sp),
                      //       Text(
                      //         'Print worksheet',
                      //         style: getMediumStyle(
                      //             fontSize: 16.sp,
                      //             color: ColorManager.colorBlack),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      if (isDeleteEnable)
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: [
                              SvgPicture.asset(IconAssets.iconDelete,
                                  color: Colors.black, height: 18.sp),
                              SizedBox(width: 15.sp),
                              Text(
                                'Delete',
                                style: getMediumStyle(
                                    fontSize: 16.sp,
                                    color: ColorManager.colorBlack),
                              ),
                            ],
                          ),
                        ),
                      // PopupMenuItem<int>(
                      //     value: 3,
                      //     child: Row(
                      //       children: [
                      //         SvgPicture.asset(IconAssets.iconPrint,
                      //             height: 18.sp),
                      //         SizedBox(width: 15.sp),
                      //         Text(
                      //           'Edit',
                      //           style: getMediumStyle(
                      //               fontSize: 16.sp,
                      //               color: ColorManager.colorBlack),
                      //         ),
                      //       ],
                      //     )),
                    ],
                  ),
              ],
              leadingWidth: 26.sp,
            ),
            body: viewModel.isJobListFetchingData
                ? buildLoadingWidget
                : SingleChildScrollView(
              child: Column(
                children: [
                  if (jobItemImageUrlList.isNotEmpty)
                    jobItemImageUrlList.length == 1
                        ? Padding(
                      padding: EdgeInsets.only(
                          right: 15.sp, left: 15.sp, top: 13.sp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.sp),
                        child: InkWell(
                          onTap: () {
                            openFullScreenImage(
                                jobItemImageUrlList[0], context);
                          },
                          child: CachedNetworkImage(
                            imageUrl: jobItemImageUrlList[0],
                            width: 100.w,
                            height: 55.sp,
                            fadeInCurve: Curves.easeIn,
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) =>
                                Image.asset(ImageAssets
                                    .jobItemImagePlaceholder),
                            fadeInDuration:
                            const Duration(seconds: 1),
                          ),
                        ),
                      ),
                    )
                        : Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 15.sp),
                      margin: EdgeInsets.all(15.sp),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorManager.colorGrey,
                          width: 3.sp,
                        ),
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: jobItemImageUrlList.length,
                            itemBuilder:
                                (context, index, realIndex) {
                              return InkWell(
                                onTap: () {
                                  openFullScreenImage(
                                      jobItemImageUrlList[index],
                                      context);
                                },
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(10.sp),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    jobItemImageUrlList[index],
                                    width: 100.w,
                                    height: 100.h,
                                    fadeInCurve: Curves.easeIn,
                                    fit: BoxFit.fill,
                                    errorWidget: (context, url,
                                        error) =>
                                        Image.asset(ImageAssets
                                            .jobItemImagePlaceholder),
                                    fadeInDuration:
                                    const Duration(seconds: 1),
                                  ),
                                ),
                              );
                            },
                            options: CarouselOptions(
                              autoPlay: true,
                              viewportFraction: 0.7,
                              aspectRatio: isTablet ? 4 : 1.9,
                              reverse: false,
                              enlargeCenterPage: true,
                              enlargeStrategy:
                              CenterPageEnlargeStrategy.scale,
                              enlargeFactor: 0.35,
                              onPageChanged: (value, _) {
                                _dotController.add(value);
                              },
                            ),
                          ),
                          SizedBox(height: 15.sp),
                          StreamBuilder(
                            stream: _dotController.stream,
                            initialData: "0",
                            builder: (context, snapshot) {
                              return buildScrollIndicator(
                                  jobItemImageUrlList,
                                  _carouselController,
                                  int.parse(
                                      snapshot.data!.toString()));
                            },
                          ),
                        ],
                      ),
                    ),

                  // Job Detail Data
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15.sp),
                    margin: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorManager.colorGrey,
                        width: 3.sp,
                      ),
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: ExpansionPanelList(
                      elevation: 0,
                      expansionCallback: (panelIndex, isExpanded) {
                        isInfoExpanded = !isInfoExpanded;
                        setState(() {});
                      },
                      children: [
                        ExpansionPanel(
                          isExpanded: isInfoExpanded,
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 15.sp),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.model.customerName,
                                      style: getBoldStyle(
                                        color:
                                        ColorManager.textColorBlack,
                                        fontSize: FontSize.large,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.sp),
                                  Text(
                                    "#${widget.model.tag} - ${widget.model.sid}",
                                    style: getBoldStyle(
                                      color: ColorManager.textColorBlack,
                                      fontSize: FontSize.big,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          body: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 15.sp),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Number :",
                                      style: getRegularStyle(
                                        color:
                                        ColorManager.textColorBlack,
                                        fontSize: FontSize.mediumExtra,
                                      ),
                                    ),
                                    SizedBox(width: 10.sp),
                                    InkWell(
                                      onTap: () {
                                        makePhoneCall(
                                            widget.model.customerPhoneNo);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.model.customerPhoneNo
                                                .toString(),
                                            style: getRegularStyle(
                                              color: ColorManager
                                                  .textColorGrey,
                                              fontSize:
                                              FontSize.mediumExtra,
                                            ),
                                          ),
                                          SizedBox(width: 8.sp),
                                          SvgPicture.asset(
                                              IconAssets.iconCall)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                    txtKey: "Village",
                                    txtValue:
                                    widget.model.customerVillage),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                    txtKey: "QTY",
                                    txtValue: totalQty.toString()),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                    txtKey: "Due Date",
                                    txtValue: AppUtils.parseDate(
                                        widget.model.serviceInvoiceDueDate
                                            .millisecondsSinceEpoch,
                                        AppConstant.yMMMMd)),
                                SizedBox(height: 15.sp),
                                Container(
                                  height: 3.sp,
                                  decoration: BoxDecoration(
                                      color: ColorManager.colorGrey),
                                ),
                                SizedBox(height: 15.sp),
                                TextViewKeyValueVertically(
                                    txtKey: "Date & Time",
                                    txtValue: AppUtils.parseDate(
                                        widget
                                            .model
                                            .serviceInvoiceCreatedAtDate
                                            .millisecondsSinceEpoch,
                                        AppConstant.yMMMMd)),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueVertically(
                                    txtKey: "Note",
                                    txtValue: widget.model
                                        .serviceInvoiceNotes.isEmpty
                                        ? '-'
                                        : widget
                                        .model.serviceInvoiceNotes),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueVertically(
                                    txtKey: "Payment",
                                    txtValue: widget
                                        .model.serviceInvoicePaymentMode),
                                SizedBox(height: 15.sp),
                                TextViewKeyValueHorizontally(
                                    txtKey: "Due Payment",
                                    txtValue:
                                    "₹ ${widget.model.serviceInvoiceDueAmount}"),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueHorizontally(
                                    txtKey: "Total Bill",
                                    txtValue: "₹ ${subTotal}"),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueHorizontally(
                                    txtKey: "Discount",
                                    txtValue: "₹ $discount"),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueHorizontally(
                                    txtKey: "Final Amount",
                                    txtValue:
                                    "₹ ${(subTotal) - discount}"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  // Job Status & listing
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Status",
                                      style: getRegularStyle(
                                        color:
                                        ColorManager.textColorBlack,
                                        fontSize: FontSize.mediumExtra,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${AppUtils.getServiceCompleteStatusPer(viewModel.jobItemList)}%",
                                    style: getRegularStyle(
                                      color: ColorManager.textColorGrey,
                                      fontSize: FontSize.mediumExtra,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                lineHeight: 10.sp,
                                percent:
                                AppUtils.getServiceCompleteStatusPer(
                                    viewModel.jobItemList) /
                                    100,
                                backgroundColor:
                                ColorManager.colorLightWhite,
                                progressColor: ColorManager.colorBlack,
                                barRadius: Radius.circular(10.sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        GestureDetector(
                          onTap: () {
                            if (AppUtils.getServiceCompleteStatusPer(
                                viewModel.jobItemList) ==
                                100) {
                              AppUtils.showToast(
                                  'Job is already Completed');
                            } else {
                              if (AppUtils.getServiceCompleteStatusPer(
                                  viewModel.jobItemList) >=
                                  99) {
                                confirmationForChangeStatus(viewModel);
                              }
                            }
                          },
                          child: AppUtils.getServiceCompleteStatusPer(
                              viewModel.jobItemList) ==
                              100
                              ? Container(
                            height: 20.sp,
                            width: 20.sp,
                            decoration: BoxDecoration(
                              color: ColorManager.colorGreen,
                              borderRadius:
                              BorderRadius.circular(20.sp),
                            ),
                            child: Icon(
                              Icons.check,
                              color: ColorManager.white,
                              size: 16.sp,
                            ),
                          )
                              : Container(
                            height: 20.sp,
                            width: 20.sp,
                            decoration: BoxDecoration(
                              color: ColorManager.colorLightGrey,
                              borderRadius:
                              BorderRadius.circular(20.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.jobItemList.length,
                      itemBuilder: (context, index) {
                        return JobItems(
                          jobItemModel: viewModel.jobItemList[index],
                          onClick: () async {
                            var data = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobStatusScreen(
                                    jobItemModel:
                                    viewModel.jobItemList[index]),
                              ),
                            );
                            if (data != null) {
                              Provider.of<ServiceViewModel>(context,
                                  listen: false)
                                  .getServicesList();
                              Provider.of<ServiceViewModel>(context,
                                  listen: false)
                                  .getJobItemList(
                                  widget.model.serviceInvoiceId);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
buildScrollIndicator(List<String> imgList,
    CarouselSliderController carouselController, int current) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: imgList.asMap().entries.map((entry) {
      return GestureDetector(
        onTap: () => carouselController.animateToPage(entry.key),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.sp),
          width: current == entry.key ? 17.sp : 11.sp,
          height: 11.sp,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.sp),
              color: current == entry.key
                  ? ColorManager.colorBlack
                  : ColorManager.colorGrey),
        ),
      );
    }).toList(),
  );
}
class TextViewKeyValue extends StatelessWidget {
  const TextViewKeyValue(
      {Key? key, required this.txtKey, required this.txtValue})
      : super(key: key);

  final String txtKey, txtValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$txtKey :",
          style: getRegularStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Text(
            txtValue,
            style: getRegularStyle(
              color: ColorManager.textColorGrey,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ),
      ],
    );
  }
}

class TextViewKeyValueVertically extends StatelessWidget {
  const TextViewKeyValueVertically(
      {Key? key, required this.txtKey, required this.txtValue})
      : super(key: key);

  final String txtKey, txtValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          txtKey,
          style: getRegularStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          txtValue,
          style: getRegularStyle(
            color: ColorManager.textColorGrey,
            fontSize: FontSize.mediumExtra,
          ),
        ),
      ],
    );
  }
}

class TextViewKeyValueHorizontally extends StatelessWidget {
  const TextViewKeyValueHorizontally(
      {Key? key, required this.txtKey, required this.txtValue})
      : super(key: key);

  final String txtKey, txtValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            txtKey,
            style: getRegularStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ),
        SizedBox(height: 10.sp),
        Text(
          txtValue,
          style: getRegularStyle(
            color: ColorManager.textColorGrey,
            fontSize: FontSize.mediumExtra,
          ),
        ),
      ],
    );
  }
}

// JobItems
class JobItems extends StatefulWidget {
  const JobItems({Key? key, required this.onClick, required this.jobItemModel})
      : super(key: key);
  final JobItemModel jobItemModel;
  final Function() onClick;

  @override
  State<JobItems> createState() => _JobItemsState();
}

class _JobItemsState extends State<JobItems> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClick,
      child: Container(
        margin: EdgeInsets.only(top: 15.sp),
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            color: ColorManager.colorGrey,
            width: 2.sp,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularPercentIndicator(
              radius: 22.sp,
              lineWidth: 5.0,
              percent: AppUtils.getPercentageForIndicator(
                  widget.jobItemModel.jobItemPercentage),
              center: Text(
                "${widget.jobItemModel.jobItemPercentage}%",
                style: getMediumStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.small,
                ),
              ),
              progressColor: AppUtils.getProgressIndicatorColor(
                  widget.jobItemModel.jobItemPercentage),
              backgroundColor: AppUtils.getProgressIndicatorColor(
                  widget.jobItemModel.jobItemPercentage)
                  .withOpacity(0.3),
            ),
            SizedBox(width: 15.sp),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "#${widget.jobItemModel.jobItemCode}",
                          style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.big,
                          ),
                        ),
                      ),
                      Text(
                        AppUtils.parseDate(widget.jobItemModel.jobItemDueDate,
                            AppConstant.dd_mm_yyyy),
                        style: getMediumStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13.sp),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.jobItemModel.customerModel.name,
                          style: getRegularStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.mediumExtra,
                          ),
                        ),
                      ),
                      Text(
                        "${widget.jobItemModel.jobItemQty.toString()} X ${(widget.jobItemModel.jobItemTotalCharge / widget.jobItemModel.jobItemQty).toString()}",
                        style: getMediumStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.medium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13.sp),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppUtils().getServiceNameById(
                              serviceId: widget.jobItemModel.jobItemServiceId),
                          style: getMediumStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.mediumExtra,
                          ),
                        ),
                      ),
                      Text(
                        "Total : ${widget.jobItemModel.jobItemTotalCharge}",
                        style: getMediumStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13.sp),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Color: ${widget.jobItemModel.colorName ?? ''}",
                              style: getMediumStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            SizedBox(width: 7.sp),
                            BuildColorDot(
                                color: Color(widget.jobItemModel.jobItemColor),
                                size: 15.sp),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.sp, vertical: 10.sp),
                        decoration: BoxDecoration(
                            color: AppUtils.getProgressIndicatorColor(
                                widget.jobItemModel.jobItemPercentage)
                                .withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10.sp)),
                        child: Text(
                          AppUtils.getJobStatusName(
                              widget.jobItemModel.jobItemPercentage),
                          style: getMediumStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.medium,
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
      ),
    );
  }
}
