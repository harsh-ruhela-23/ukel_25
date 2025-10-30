import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/custom_craftman_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/home/craftsman/select_craftsman_screen.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/invoice/pdf_viewer.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_button_widgets.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import 'package:ukel/widgets/other_widgets.dart';
import '../../../../services/get_storage.dart';
import '../../../../widgets/full_screen_image.dart';
import '../../branch_management/widgets/craftman_work_history_screen.dart';
import 'invoice_details_screen.dart';

class JobStatusScreen extends StatefulWidget {
  JobStatusScreen({Key? key, required this.jobItemModel}) : super(key: key);
  JobItemModel jobItemModel;

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen> {
  bool isInfoExpanded = false;

  // for craftsman
  List<CraftsmanModel> craftsmanList = [];
  bool isCraftsmanListFetchingData = false;
  final homeRepository = HomeRepository();
  String error = '';

  CraftsmanModel? selectedCraftsmanModel;
  String selectedCraftsmanName = '';

  ServiceInvoiceRepository serviceRepository = ServiceInvoiceRepository();

  @override
  void initState() {
    super.initState();
    _initializeScreenData();
  }

  Future<void> _initializeScreenData() async {
    await getServiceInfo();
    await getCraftsmanList();
  }
  List<Widget> orderStatusTimelines = [];

  void addTimeline(AddJobTimeLineModel data) {
    Widget timelineData = TimelineTile(
      alignment: TimelineAlign.start,
      indicatorStyle: IndicatorStyle(
        color: Color(data.indicatorColor),
        indicatorXY: 0.0,
        indicator: BuildColorDot(color: Color(data.indicatorColor)),
      ),
      isFirst: data.isFirst,
      isLast: data.isLast,
      beforeLineStyle: LineStyle(
        color: Color(data.indicatorColor),
      ),
      afterLineStyle: LineStyle(
        color: Color(data.indicatorColor),
      ),
      endChild: Container(
        padding: EdgeInsets.all(15.sp),
        margin: EdgeInsets.only(left: 15.sp, bottom: 15.sp),
        decoration: BoxDecoration(
            color: Color(data.bgColor),
            borderRadius: BorderRadius.circular(10.sp)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.title,
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                SizedBox(width: 20.sp),
                data.subTitle != null
                    ? Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RotatedBox(
                              quarterTurns: 2,
                              child: SvgPicture.asset(IconAssets.iconBack),
                            ),
                            Text(
                              data.subTitle!,
                              textAlign: TextAlign.right,
                              style: getMediumStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                (data.statusPer == "99" && data.isReject)
                    ? Row(
                        children: [
                          SizedBox(width: 20.sp),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Dialog(
                                        insetPadding: EdgeInsets.all(15.sp),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.sp),
                                        ),
                                        elevation: 10,
                                        backgroundColor: ColorManager.white,
                                        child: Padding(
                                          padding: EdgeInsets.all(15.sp),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Quality issue",
                                                      style: getRegularStyle(
                                                        color: ColorManager
                                                            .textColorGrey,
                                                        fontSize: FontSize
                                                            .mediumExtra,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 20.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.sp),
                                              Flexible(
                                                child: Text(
                                                  widget
                                                          .jobItemModel
                                                          .jobStatusObj!
                                                          .rejectReason[
                                                      data.rejectCount],
                                                  style: getRegularStyle(
                                                    color: ColorManager
                                                        .textColorGrey,
                                                    fontSize:
                                                        FontSize.mediumExtra,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Icon(
                              Icons.info_outline,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.completedDate != null
                        ? AppUtils.parseDate(
                            data.completedDate!, "dd-MM-yyyy HH:mm")
                        : "",
                    style: getMediumStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.mediumExtra,
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                StatusIndicatorWidget(
                  title: data.title,
                  timeLineModel: data,
                  craftsmanModel: selectedCraftsmanModel,
                  jobItemModel: widget.jobItemModel,
                  status: data.statusPer,
                  color: Color(data.indicatorColor),
                  isReject: data.isReject,
                  onStatusChange: (data) {
                    setTimeLineWidgets();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
    orderStatusTimelines.add(timelineData);
    setState(() {});
  }

  Future<void> getCraftsmanList() async {
    craftsmanList.clear();
    try {
      if (!isCraftsmanListFetchingData) {
        isCraftsmanListFetchingData = true;
        await AppUtils().getAndSetGlobalServiceList();
        final String serviceName = AppUtils().getServiceNameById(
            serviceId: widget.jobItemModel.jobItemServiceId);
        final List<String> serviceFilters =
            _buildCraftsmanServiceFilters(serviceName);
        final bool enforceOptionFilters = _hasServiceOptionSelection();
        await homeRepository
            .fetchCraftsmanList(
          isByServiceType: serviceName,
          branchId: widget.jobItemModel.branchId,
          selectedServiceFilters: serviceFilters,
          enforceServiceNameFilters: enforceOptionFilters,
        )
            .then((list) {
          if (list.isNotEmpty) {
            for (var element in list) {
              if (element.id == widget.jobItemModel.selectedCraftsmanId) {
                selectedCraftsmanModel = element;
              }
            }
            craftsmanList.addAll(list);
          }
        });
        setTimeLineWidgets();
        error = '';
        isCraftsmanListFetchingData = false;
      }
    } catch (e) {
      isCraftsmanListFetchingData = false;
      error = e.toString();
    }
    setState(() {});
  }

  List<String> _buildCraftsmanServiceFilters(String serviceName) {
    final String trimmedServiceName = serviceName.trim();
    if (trimmedServiceName.isEmpty) {
      return [];
    }

    final List<String> optionSelections = serviceTypeList
        .where((serviceType) =>
            serviceType.type == "radio" &&
            (serviceType.value ?? '').trim().isNotEmpty)
        .map((serviceType) => serviceType.value!.trim())
        .toList();

    if (optionSelections.isNotEmpty) {
      return optionSelections
          .map((option) => "$trimmedServiceName - $option")
          .toList();
    }

    return [trimmedServiceName];
  }

  bool _hasServiceOptionSelection() {
    return serviceTypeList.any((serviceType) =>
        serviceType.type == "radio" &&
        (serviceType.value ?? '').trim().isNotEmpty);
  }

  void setTimeLineWidgets() async {
    orderStatusTimelines = [];
    if (widget.jobItemModel.timelineStatusObj != null) {
      List<AddJobTimeLineModel> list = AppUtils.timelineStatusList(
          widget.jobItemModel.timelineStatusObj!,
          widget.jobItemModel.jobStatusObj!.rejectCount);
      ServiceViewModel viewModel =
          Provider.of<ServiceViewModel>(context, listen: false);
      widget.jobItemModel.timelineStatusObj = list;
      await viewModel.updateJobItem(widget.jobItemModel);
      for (int i = 0; i < list.length; i++) {
        addTimeline(list[i]);
      }
    }
  }

  String getCraftsmanNameByCraftsmanId(String craftsmanId) {
    String name = '';

    if (craftsmanList.isNotEmpty && craftsmanId.isNotEmpty) {
      for (var element in craftsmanList) {
        if (element.id == craftsmanId) {
          name = element.personalDetailsModel.name;
        }
      }
    }
    return name;
  }

  updateCraftsmanWorkStatus(CraftsmanModel craftsmanModel) async {
    await FirebaseFirestore.instance
        .collection(FbConstant.craftsman)
        .doc(craftsmanModel.id)
        .set(craftsmanModel.toJson());
  }

  refreshScreen() {
    getCraftsmanList();
  }

  void printInvoice() async {
    await AppUtils.generateInvoicePdfJobItem(widget.jobItemModel).then((path) {
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

  List<ServiceType> serviceTypeList = [];

  Future<void> getServiceInfo() async {
    Map<String, dynamic> result = await serviceRepository
        .fetchServiceById(widget.jobItemModel.jobItemServiceId);

    ServicesListModel servicesListModel = result[FbConstant.service];

    final List<ServiceType> resolvedTypes =
        await serviceRepository.resolveServiceTypes(servicesListModel);
    serviceTypeList.addAll(resolvedTypes);

    for (int i = 0; i < widget.jobItemModel.jobItemServiceValue!.length; i++) {
      String? id = widget.jobItemModel.jobItemServiceValue![i].id;
      print("id: ${widget.jobItemModel.jobItemServiceValue![i].id}");
      int serviceIndex = serviceTypeList.indexWhere((obj) => obj.id == id);
      print("serviceIndex: $serviceIndex");
      if (serviceIndex != -1) {
        serviceTypeList[serviceIndex].value =
            widget.jobItemModel.jobItemServiceValue![i].value;
        print("value: ${widget.jobItemModel.jobItemServiceValue![i].value}");
      }
    }

    setState(() {});
  }

  List<Widget> measurementsWidget() {
    final List<Widget> measurementWidgets = [];
    final List<Widget> optionWidgets = [];

    for (int i = 0; i < serviceTypeList.length; i++) {
      if (serviceTypeList[i].type == "radio") {
        final List<ServiceOptionModel>? radioOptions = serviceTypeList[i].option;

        if (radioOptions != null) {
          final int radioIndex = radioOptions
              .indexWhere((obj) => obj.label == serviceTypeList[i].value);

          if (radioIndex != -1) {
            optionWidgets.add(
              Column(
                children: [
                  TextViewKeyValue(
                      txtKey: radioOptions[radioIndex].name, txtValue: ""),
                  SizedBox(height: 10.sp),
                ],
              ),
            );
          }
        }
      } else {
        measurementWidgets.add(
          Column(
            children: [
              TextViewKeyValue(
                  txtKey: serviceTypeList[i].name ?? "",
                  txtValue: "${serviceTypeList[i].value ?? ""} inch"),
              SizedBox(height: 10.sp),
            ],
          ),
        );
      }
    }

    return [...measurementWidgets, ...optionWidgets];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppUtils.navigateUp(context, argument: true);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: OtherScreenAppBar(
            onBackClick: () => AppUtils.navigateUp(context, argument: true),
            title: "Job Status ",
            actionIcon: IconAssets.iconPrint,
            onActionIconClick: () {
              printInvoice();
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              refreshScreen();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      openFullScreenImage(
                          widget.jobItemModel.jobItemImageUrl, context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.sp, horizontal: 15.sp),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: CachedNetworkImage(
                              imageUrl: widget.jobItemModel.jobItemImageUrl,
                              width: 100.w,
                              height: 55.sp,
                              fadeInCurve: Curves.easeIn,
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) => Image.asset(
                                  ImageAssets.jobItemImagePlaceholder),
                              fadeInDuration: const Duration(seconds: 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                              padding: EdgeInsets.symmetric(horizontal: 15.sp),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.jobItemModel.customerModel.name,
                                      style: getBoldStyle(
                                        color: ColorManager.textColorBlack,
                                        fontSize: FontSize.large,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.sp),
                                  Text(
                                    "#${widget.jobItemModel.jobItemCode}",
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
                            padding: EdgeInsets.symmetric(horizontal: 15.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Number :",
                                      style: getRegularStyle(
                                        color: ColorManager.textColorBlack,
                                        fontSize: FontSize.mediumExtra,
                                      ),
                                    ),
                                    SizedBox(width: 10.sp),
                                    InkWell(
                                      onTap: () {
                                        makePhoneCall(widget
                                            .jobItemModel.customerModel.phone);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.jobItemModel.customerModel
                                                .phone
                                                .toString(),
                                            style: getRegularStyle(
                                              color: ColorManager.textColorGrey,
                                              fontSize: FontSize.mediumExtra,
                                            ),
                                          ),
                                          SizedBox(width: 8.sp),
                                          SvgPicture.asset(IconAssets.iconCall)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                    txtKey: "Village",
                                    txtValue: widget
                                        .jobItemModel.customerModel.village),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                    txtKey: "QTY",
                                    txtValue: widget.jobItemModel.jobItemQty
                                        .toString()),
                                SizedBox(height: 10.sp),
                                Row(
                                  children: [
                                    Text(
                                      "Color : ",
                                      style: getMediumStyle(
                                        color: ColorManager.textColorBlack,
                                        fontSize: FontSize.mediumExtra,
                                      ),
                                    ),
                                    Text(
                                      widget.jobItemModel.colorName ?? '',
                                      style: getRegularStyle(
                                        color: ColorManager.textColorGrey,
                                        fontSize: FontSize.mediumExtra,
                                      ),
                                    ),
                                    SizedBox(width: 10.sp),
                                    BuildColorDot(
                                        color: Color(
                                            widget.jobItemModel.jobItemColor),
                                        size: 15.sp),
                                  ],
                                ),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                  txtKey: "Due Date",
                                  txtValue: AppUtils.parseDate(
                                      widget.jobItemModel.jobItemDueDate,
                                      AppConstant.yMMMMd),
                                ),
                                SizedBox(height: 10.sp),
                                TextViewKeyValue(
                                  txtKey: "Service",
                                  txtValue: AppUtils().getServiceNameById(
                                      serviceId:
                                          widget.jobItemModel.jobItemServiceId),
                                ),
                                SizedBox(height: 20.sp),
                                Text(
                                  "Measurements : ",
                                  style: getMediumStyle(
                                    color: ColorManager.textColorBlack,
                                    fontSize: FontSize.mediumExtra,
                                  ),
                                ),
                                SizedBox(height: 10.sp),
                                ...measurementsWidget(),
                                Container(
                                  height: 3.sp,
                                  decoration: BoxDecoration(
                                      color: ColorManager.colorGrey),
                                ),
                                SizedBox(height: 15.sp),
                                TextViewKeyValueVertically(
                                  txtKey: "Date & Time",
                                  txtValue: AppUtils.parseDate(
                                      widget.jobItemModel.jobItemCreatedAtDate,
                                      AppConstant.yMMMMd),
                                ),
                                SizedBox(height: 10.sp),
                                TextViewKeyValueVertically(
                                  txtKey: "Note",
                                  txtValue:
                                      widget.jobItemModel.jobItemNotes.isEmpty
                                          ? '-'
                                          : widget.jobItemModel.jobItemNotes,
                                ),
                                // SizedBox(height: 10.sp),
                                // TextViewKeyValueVertically(
                                //     txtKey: "Payment",
                                //     txtValue:
                                //         widget.model.serviceInvoicePaymentMode),
                                // SizedBox(height: 15.sp),
                                // TextViewKeyValueHorizontally(
                                //     txtKey: "Due Payment",
                                //     txtValue:
                                //         "₹ ${widget.model.serviceInvoiceDueAmount}"),
                                // SizedBox(height: 10.sp),
                                // TextViewKeyValueHorizontally(
                                //     txtKey: "Total Bill",
                                //     txtValue:
                                //         "₹ ${widget.model.serviceInvoiceTotalAmount}"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.sp),

                  // Craftsman
                  isCraftsmanListFetchingData
                      ? buildLoadingWidget
                      : error.isNotEmpty
                          ? Center(
                              child: Text(error.toString()),
                            )
                          : craftsmanList.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 15.sp),
                                  child: const Center(
                                    child: Text('No Craftsman Available'),
                                  ),
                                )
                              : Column(
                                  children: [
                                    // selectedCraftsmanContainer
                                    widget.jobItemModel.selectedCraftsmanId
                                            .isEmpty
                                        ? const SizedBox()
                                        : selectedCraftsmanContainer(
                                            widget.jobItemModel, ''),
                                    widget.jobItemModel.selectedCraftsmanId
                                            .isEmpty
                                        ? const SizedBox()
                                        : SizedBox(height: 15.sp),

                                    // Select/Change Craftsman button
                                    if (int.parse(widget
                                            .jobItemModel.jobItemPercentage) <
                                        50)
                                      Storage.getValue(AppConstant.role) == "B"
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15.sp),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Craftsman",
                                                          style: getBoldStyle(
                                                            color: ColorManager
                                                                .textColorBlack,
                                                            fontSize:
                                                                FontSize.large,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 53.sp,
                                                        child: ButtonWidget(
                                                          onPressed: () {
                                                            CraftsmanModel?
                                                                model =
                                                                selectedCraftsmanModel;
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SelectCraftsmanScreen(
                                                                  jobItemModel:
                                                                      widget
                                                                          .jobItemModel,
                                                                  craftsmanList:
                                                                      craftsmanList,
                                                                  currentCraftsman:
                                                                      model,
                                                                  isChange: widget
                                                                      .jobItemModel
                                                                      .selectedCraftsmanId
                                                                      .isNotEmpty,
                                                                ),
                                                              ),
                                                            ).then(
                                                                (craftsmanModel) {
                                                              if (craftsmanModel !=
                                                                  null) {
                                                                // if (model !=
                                                                //     null) {
                                                                //   if (widget.jobItemModel
                                                                //               .jobItemPercentage ==
                                                                //           "0" ||
                                                                //       widget.jobItemModel
                                                                //               .jobItemPercentage ==
                                                                //           "16") {
                                                                //     model.appointed =
                                                                //         model.appointed -
                                                                //             1;
                                                                //   } else if (widget
                                                                //           .jobItemModel
                                                                //           .jobItemPercentage ==
                                                                //       "34") {
                                                                //     model.running =
                                                                //         model.running -
                                                                //             1;
                                                                //     model
                                                                //         .inJobIdsList
                                                                //         .remove(widget
                                                                //             .jobItemModel
                                                                //             .jobId);
                                                                //   }
                                                                //   updateCraftsmanWorkStatus(
                                                                //       model);
                                                                // }
                                                                selectedCraftsmanModel =
                                                                    craftsmanModel;
                                                                setState(() {});
                                                              }
                                                            });
                                                          },
                                                          title: widget
                                                                  .jobItemModel
                                                                  .selectedCraftsmanId
                                                                  .isNotEmpty
                                                              ? 'Change Craftsman'
                                                              : "Select Craftsman",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 15.sp),
                                              ],
                                            )
                                          : const SizedBox(),

                                    // JobItem Timeline
                                    widget.jobItemModel.selectedCraftsmanId
                                            .isEmpty
                                        ? const SizedBox()
                                        : Container(
                                            padding: EdgeInsets.all(15.sp),
                                            margin: EdgeInsets.all(15.sp),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: ColorManager.colorGrey,
                                                width: 3.sp,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.sp),
                                            ),
                                            child: Column(
                                              children: [
                                                ...orderStatusTimelines,
                                              ],
                                            ),
                                          ),
                                    SizedBox(height: 25.sp),
                                  ],
                                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isCraftsmanFetchingData = false;
  CustomCraftsmanModel? customCraftsmanModel;
  double workLoad = 0;

  void getCraftsmanDetail(String id) async {
    try {
      if (!isCraftsmanFetchingData) {
        isCraftsmanFetchingData = true;

        await homeRepository.fetchCraftsmanDetail(id: id).then((data) {
          if (data != null) {
            customCraftsmanModel = CustomCraftsmanModel(
              model: data,
              remainingDays: AppUtils.calculateCraftsmanIndividualRemainingDays(
                          data) ==
                      null
                  ? 0
                  : AppUtils.calculateCraftsmanIndividualRemainingDays(data)!,
            );
            workLoad = AppUtils.getCraftsmanWorkLoad(
                [customCraftsmanModel!],
                customCraftsmanModel!.remainingDays,
                customCraftsmanModel!.model.serviceInfoModel.serviceType);
          }
        });
        isCraftsmanFetchingData = false;
      }
    } catch (e) {
      isCraftsmanFetchingData = false;
    }
    setState(() {});
  }

  Widget selectedCraftsmanContainer(
      JobItemModel jobItemModel, String craftsmanName) {
    getCraftsmanDetail(widget.jobItemModel.selectedCraftsmanId);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CraftManWorkHistoryScreen(
              customCraftsmanModel: customCraftsmanModel!,
              workLoad: workLoad,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
        margin: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: ColorManager.colorDisable,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 24.sp,
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
                  .withOpacity(0.2),
            ),
            SizedBox(width: 20.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.jobItemModel.selectedCraftsmanId.isEmpty
                      ? '-'
                      : getCraftsmanNameByCraftsmanId(
                          widget.jobItemModel.selectedCraftsmanId),
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.bigExtra,
                  ),
                ),
                SizedBox(height: 10.sp),
                Text(
                  "Craftsman Received Work",
                  style: getRegularStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class StatusIndicatorWidget extends StatefulWidget {
  const StatusIndicatorWidget(
      {Key? key,
      required this.status,
      required this.timeLineModel,
      required this.jobItemModel,
      required this.color,
      required this.onStatusChange,
      this.craftsmanModel,
      required this.title,
      this.isReject})
      : super(key: key);

  final String status;
  final AddJobTimeLineModel timeLineModel;
  final Color color;
  final String title;
  final JobItemModel jobItemModel;
  final Function(JobItemModel) onStatusChange;
  final CraftsmanModel? craftsmanModel;
  final bool? isReject;

  @override
  State<StatusIndicatorWidget> createState() => _StatusIndicatorWidgetState();
}

class _StatusIndicatorWidgetState extends State<StatusIndicatorWidget> {
  bool isCompleted = false;

  Widget getJobCompleteStatusWidget() {
    Widget statusWidget = const SizedBox();
    if (AppUtils.isJobStatusCompleted(
        widget.timeLineModel,
        widget.jobItemModel.jobItemPercentage,
        widget.jobItemModel.jobStatusObj!.rejectCount)) {
      isCompleted = true;
      if (widget.isReject != null && widget.isReject!) {
        statusWidget = Container(
          padding: EdgeInsets.all(5.sp),
          height: 20.sp,
          width: 20.sp,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(
              20.sp,
            ),
          ),
          child: Icon(
            Icons.close,
            color: ColorManager.white,
            size: 16.sp,
          ),
        );
      } else {
        statusWidget = Container(
          padding: EdgeInsets.all(5.sp),
          height: 20.sp,
          width: 20.sp,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(
              20.sp,
            ),
          ),
          child: Icon(
            Icons.check,
            color: ColorManager.white,
            size: 16.sp,
          ),
        );
      }
    } else {
      isCompleted = false;
      if (widget.isReject != null && widget.isReject!) {
        statusWidget = Container(
          padding: EdgeInsets.all(5.sp),
          height: 20.sp,
          width: 20.sp,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(
              20.sp,
            ),
          ),
          child: Icon(
            Icons.close,
            color: ColorManager.white,
            size: 16.sp,
          ),
        );
      } else {
        statusWidget = Container(
          height: 20.sp,
          width: 20.sp,
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(
              20.sp,
            ),
          ),
        );
      }
    }
    setState(() {});
    return statusWidget;
  }

  void confirmationForChangeStatus() {
    String title = "Are you sure want to\nchange the status?";
    String negativeLabel = "Cancel";
    String positiveLabel = "Yes";
    if (widget.status == JobPercentConstant.percent99) {
      title = "Does job quality passed?";
      negativeLabel = "No";
      positiveLabel = "Yes";
    }

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
            if (widget.status == JobPercentConstant.percent99) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return QualityRejectDialog(onSubmit: (issue) async {
                    ServiceViewModel viewModel =
                        Provider.of<ServiceViewModel>(context, listen: false);

                    if (widget.jobItemModel.timelineStatusObj != null) {
                      int? pos;
                      for (int i = 0;
                          i < widget.jobItemModel.timelineStatusObj!.length;
                          i++) {
                        if (widget.jobItemModel.timelineStatusObj![i]
                                .rejectCount ==
                            widget.jobItemModel.jobStatusObj!.rejectCount) {
                          if (widget.jobItemModel.timelineStatusObj![i]
                                  .statusPer ==
                              JobPercentConstant.percent99) {
                            pos = i;
                          }
                        }
                      }
                      if (pos != null) {
                        widget.jobItemModel.timelineStatusObj![pos]
                                .completedDate =
                            DateTime.now().millisecondsSinceEpoch;
                        widget.jobItemModel.timelineStatusObj![pos].isComplete =
                            false;
                        widget.jobItemModel.timelineStatusObj![pos].isReject =
                            true;
                      }
                    }

                    widget.jobItemModel.jobItemPercentage =
                        JobPercentConstant.percent0;

                    List<String> reasons =
                        widget.jobItemModel.jobStatusObj!.rejectReason;
                    reasons.add(issue);
                    widget.jobItemModel.jobStatusObj!.rejectCount =
                        widget.jobItemModel.jobStatusObj!.rejectCount + 1;
                    widget.jobItemModel.jobStatusObj!.rejectReason = reasons;

                    widget.craftsmanModel!.appointed =
                        widget.craftsmanModel!.appointed + 1;
                    widget.craftsmanModel!.done =
                        widget.craftsmanModel!.done - 1;

                    widget.craftsmanModel!.inJobIdsList
                        .remove(widget.jobItemModel.jobId);
                    widget.craftsmanModel!.outJobIdsList
                        .remove(widget.jobItemModel.jobId);

                    updateCraftsmanWorkStatus(widget.craftsmanModel!);

                    String apiStatus =
                        await viewModel.updateJobItem(widget.jobItemModel);
                    if (apiStatus == AppConstant.success) {
                      widget.onStatusChange(widget.jobItemModel);
                      FBroadcast.instance()
                          .broadcast(BroadCastConstant.homeScreenUpdate);
                    }
                    Navigator.pop(context);
                  });
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          onPositiveClick: () async {
            Navigator.pop(context);
            await changeStatus();
          },
          negativeButtonColor: ColorManager.white,
          negativeTextColor: ColorManager.colorDarkBlue,
          positiveButtonColor: ColorManager.colorDarkBlue,
          positiveTextColor: ColorManager.textColorWhite,
        );
      },
    );
  }

  changeStatus() async {
    String changeStatus = widget.jobItemModel.jobItemPercentage;
    ServiceViewModel viewModel =
        Provider.of<ServiceViewModel>(context, listen: false);
    if (!isCompleted == false) {
      int statusIndex = AppUtils.jobStatusListInOrder().indexOf(widget.status);
      changeStatus = AppUtils.jobStatusListInOrder()[statusIndex - 1];
    } else {
      changeStatus = widget.status;
    }

    print('changeStatus ${widget.timeLineModel.statusPer}');
    print('isCompleted ${!isCompleted}');

    if (widget.craftsmanModel != null) {
      if (widget.timeLineModel.statusPer == JobPercentConstant.percent34) {
        // Craftsman Received Work
        print("JobPercentConstant.percent34");
        if (!isCompleted) {
          // Add status
          print(
              "appointed: ${widget.craftsmanModel!.appointed}, running: ${widget.craftsmanModel!.running} => 1");
          widget.craftsmanModel!.appointed =
              widget.craftsmanModel!.appointed - 1;
          widget.craftsmanModel!.running = widget.craftsmanModel!.running + 1;
          List<String> jobIds = widget.craftsmanModel!.inJobIdsList;
          jobIds.add(widget.jobItemModel.jobId);
          widget.craftsmanModel!.inJobIdsList = jobIds;
          print(
              "After appointed: ${widget.craftsmanModel!.appointed}, running: ${widget.craftsmanModel!.running}");
          await updateCraftsmanWorkStatus(widget.craftsmanModel!);
        } else {
          // Remove status
          print(
              "appointed: ${widget.craftsmanModel!.appointed}, running: ${widget.craftsmanModel!.running} => 2");
          widget.craftsmanModel!.appointed =
              widget.craftsmanModel!.appointed + 1;
          widget.craftsmanModel!.running = widget.craftsmanModel!.running - 1;
          widget.craftsmanModel!.inJobIdsList.remove(widget.jobItemModel.jobId);
          print(
              "After appointed: ${widget.craftsmanModel!.appointed}, running: ${widget.craftsmanModel!.running}");
          await updateCraftsmanWorkStatus(widget.craftsmanModel!);
        }
      } else if (widget.timeLineModel.statusPer ==
          JobPercentConstant.percent50) {
        // Job Done
        print("JobPercentConstant.percent50");
        if (!isCompleted) {
          // Add status
          print(
              "done: ${widget.craftsmanModel!.done}, running: ${widget.craftsmanModel!.running}");
          widget.craftsmanModel!.running = widget.craftsmanModel!.running - 1;
          widget.craftsmanModel!.done = widget.craftsmanModel!.done + 1;
          print(
              "After done: ${widget.craftsmanModel!.done}, running: ${widget.craftsmanModel!.running}");
          await updateCraftsmanWorkStatus(widget.craftsmanModel!);
        } else {
          // Remove status
          print(
              "done: ${widget.craftsmanModel!.done}, running: ${widget.craftsmanModel!.running}");
          widget.craftsmanModel!.running = widget.craftsmanModel!.running + 1;
          widget.craftsmanModel!.done = widget.craftsmanModel!.done - 1;
          print(
              "After done: ${widget.craftsmanModel!.done}, running: ${widget.craftsmanModel!.running}");
          await updateCraftsmanWorkStatus(widget.craftsmanModel!);
        }
      } else if (widget.timeLineModel.statusPer ==
          JobPercentConstant.percent68) {
        // Out From Craftsman
        print("JobPercentConstant.percent68");
        List<String> jobIds = widget.craftsmanModel!.outJobIdsList;
        jobIds.add(widget.jobItemModel.jobId);
        widget.craftsmanModel!.outJobIdsList = jobIds;
        await updateCraftsmanWorkStatus(widget.craftsmanModel!);
      } else if (widget.timeLineModel.statusPer ==
          JobPercentConstant.percent99) {
        // Add status
        print("JobPercentConstant.percent99");
        widget.craftsmanModel!.qtPassed = widget.craftsmanModel!.qtPassed + 1;
        await updateCraftsmanWorkStatus(widget.craftsmanModel!);
      }
    }

    widget.jobItemModel.jobItemPercentage = changeStatus;

    if (widget.jobItemModel.timelineStatusObj != null) {
      int? pos;
      for (int i = 0; i < widget.jobItemModel.timelineStatusObj!.length; i++) {
        if (widget.jobItemModel.timelineStatusObj![i].statusPer ==
            widget.timeLineModel.statusPer) {
          pos = i;
        }
      }
      if (pos != null) {
        if (!isCompleted) {
          // Add status
          widget.jobItemModel.timelineStatusObj![pos].completedDate =
              DateTime.now().millisecondsSinceEpoch;
          widget.jobItemModel.timelineStatusObj![pos].isComplete = true;
        } else {
          // Remove status
          widget.jobItemModel.timelineStatusObj![pos].completedDate = null;
          widget.jobItemModel.timelineStatusObj![pos].isComplete = false;
        }
      }
    }

    String apiStatus = await viewModel.updateJobItem(widget.jobItemModel);
    if (apiStatus == AppConstant.success) {
      isCompleted = !isCompleted;
      widget.onStatusChange(widget.jobItemModel);
      FBroadcast.instance().broadcast(BroadCastConstant.homeScreenUpdate);
    }
  }

  // updateCraftsmanWorkStatus to Firebase
  updateCraftsmanWorkStatus(CraftsmanModel craftsmanModel) async {
    await FirebaseFirestore.instance
        .collection(FbConstant.craftsman)
        .doc(craftsmanModel.id)
        .set(craftsmanModel.toJson());
  }

  void onStatusClick() {
    if (AppUtils.canChangeJobStatus(
        widget.jobItemModel.jobItemPercentage,
        widget.timeLineModel,
        widget.jobItemModel.jobStatusObj!.rejectCount,
        !isCompleted)) {
      confirmationForChangeStatus();
    } else {
      AppUtils.showToast("You can not change status!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Storage.getValue(AppConstant.role) == "B" ||
            Storage.getValue(AppConstant.role) == "C") {
          onStatusClick();
        } else {
          AppUtils.showToast("Only branch user can change status!");
        }
      },
      child: getJobCompleteStatusWidget(),
    );
  }
}

class QualityRejectDialog extends StatelessWidget {
  const QualityRejectDialog({Key? key, required this.onSubmit})
      : super(key: key);
  final Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final formGlobalKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        insetPadding: EdgeInsets.all(15.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
        ),
        elevation: 10,
        backgroundColor: ColorManager.white,
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Form(
            key: formGlobalKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Quality issue",
                        style: getRegularStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.sp),
                TextAreaInputWidget(
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  controller: controller,
                  autofocus: true,
                ),
                SizedBox(height: isTablet ? 15.sp : 20.sp),
                ButtonWidget(
                  onPressed: () {
                    if (formGlobalKey.currentState!.validate()) {
                      onSubmit(controller.text);
                    }
                  },
                  title: "Submit",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
