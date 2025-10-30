import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/color_model.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/card_with_data.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/customer_dropdown_widget.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/suggestion_dropdown_widget.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/default_button.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/utils/indicator.dart';
import 'package:ukel/widgets/custom_button_widgets.dart';
import 'package:ukel/widgets/custom_color_picker_dialog.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import 'package:ukel/widgets/other_widgets.dart';

import '../../../../../main.dart';
import '../../../../../services/authentication_service.dart';
import '../../../../../services/get_storage.dart';
import 'service_dropdown_widget.dart';

class AddJobItemScreen extends StatefulWidget {
  const AddJobItemScreen({
    Key? key,
    required this.serviceInvoiceId,
    this.selectedCustomer,
    this.isNew = true,
    this.selectedMember,
    this.serviceInvoiceModel,
  }) : super(key: key);
  final String serviceInvoiceId;
  final bool? isNew;
  final CustomerModel? selectedCustomer;
  final MembersModel? selectedMember;
  final ServiceInvoiceModel? serviceInvoiceModel;

  @override
  State<AddJobItemScreen> createState() => _AddJobItemScreenState();
}

class _AddJobItemScreenState extends State<AddJobItemScreen> {
  Color? selectedColor;
  String? selectedColorName;

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  String itemQRCode = generateJobItemInvoiceQRId();
  int dueDate = DateTime.now().millisecondsSinceEpoch;

  final Set<String> _updatingJobItemIds = <String>{};

  void _recalculateConfirmedItemTotals() {
    jobItemCount.value = jobItemList2.fold<double>(
      0.0,
      (previousValue, element) => previousValue + element.amount,
    );
  }

  Future<void> _incrementConfirmedItemQuantity(
      ServiceViewModel viewModel, ConfirmedJobItem item) async {
    final String jobId = item.jobItemModel.jobId;
    if (_updatingJobItemIds.contains(jobId)) {
      return;
    }

    _updatingJobItemIds.add(jobId);
    setState(() {});

    final int previousPieces = item.pieces;
    final double previousAmount = item.amount;
    final int updatedPieces = previousPieces + 1;
    final double newAmount = item.unitPrice * updatedPieces;

    item.pieces = updatedPieces;
    item.amount = newAmount;
    item.jobItemModel.jobItemQty = updatedPieces;
    item.jobItemModel.jobItemTotalCharge = newAmount;
    jobItemList2.refresh();
    _recalculateConfirmedItemTotals();

    final String status = await viewModel.updateJobItem(item.jobItemModel);

    if (status != AppConstant.success) {
      item.pieces = previousPieces;
      item.amount = previousAmount;
      item.jobItemModel.jobItemQty = previousPieces;
      item.jobItemModel.jobItemTotalCharge = previousAmount;
      jobItemList2.refresh();
      _recalculateConfirmedItemTotals();
      AppUtils.showToast(status);
    } else {
      viewModel.getJobItemList(widget.serviceInvoiceId);
    }

    _updatingJobItemIds.remove(jobId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.isNew ?? true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ServiceViewModel>(context, listen: false)
            .clearJobItemData(widget.selectedCustomer);
        Provider.of<ServiceViewModel>(context, listen: false)
            .jobItemQtyController
            .text = "1";

        dueDate = Provider.of<ServiceViewModel>(context, listen: false)
            .invoiceDueDate
            .millisecondsSinceEpoch;

        getColorsList();
      });
    }
  }

  openDatePicker() async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(dueDate),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 100),
    );
    if (datePicked != null) {
      dueDate = datePicked.millisecondsSinceEpoch;
      setState(() {});
    }
  }

  onImagePicker() async {
    Indicator.showLoading();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Image",
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      selectedImage = File(result.files.single.path!);
      Indicator.closeIndicator();
      setState(() {});
    } else {
      Indicator.closeIndicator();
    }
  }

  void validateAndSubmitData(ServiceViewModel viewModel, bool isSaveAndNew) {
    FocusScope.of(context).unfocus();
    if (selectedImage == null) {
      AppUtils.showToast('Please Select Image');
      return;
    }
    if (selectedColor == null || selectedColorName == null) {
      AppUtils.showToast('Please Select Color');
      return;
    }
    if (viewModel.selectedCustomer == null) {
      AppUtils.showToast('Please Select Customer');
      return;
    }
    if (jobItemList2.isEmpty) {
      AppUtils.showToast('Please Select Service');
      return;
    }
    String validateServiceType = viewModel.validateServiceType();
    if (validateServiceType.isNotEmpty) {
      AppUtils.showToast(validateServiceType);
      return;
    }
    if (viewModel.jobItemQtyController.text.isEmpty) {
      AppUtils.showToast('Please Enter Number of Pieces');
      return;
    } else if (viewModel.jobItemQtyController.text == "0") {
      AppUtils.showToast('Please Enter Number of Pieces');
      return;
    }

    List<AddJobTimeLineModel> timeLineList = AppUtils.getInitTimeLineList();

    if (viewModel.selectedMember != null) {
      MembersModel membersModel = widget.selectedMember!;
      if (membersModel.serviceData != null) {
        bool isIdExist = false;
        for (int i = 0; i < membersModel.serviceData!.length; i++) {
          if (membersModel.serviceData![i].serviceId != null) {
            if (membersModel.serviceData![i].serviceId ==
                viewModel.selectedService?.id) {
              isIdExist = true;
              membersModel.serviceData![i].value =
                  viewModel.getServiceTypeValues();
              break;
            }
          }
        }
        if (!isIdExist) {
          MemberServiceData memberServiceData = MemberServiceData(
              serviceId: viewModel.selectedService?.id,
              value: viewModel.getServiceTypeValues());
          membersModel.serviceData!.add(memberServiceData);
        }
      } else {
        MemberServiceData memberServiceData = MemberServiceData(
            serviceId: viewModel.selectedService?.id,
            value: viewModel.getServiceTypeValues());
        membersModel.serviceData = [];
        membersModel.serviceData!.add(memberServiceData);
      }

      if (widget.selectedCustomer != null) {
        CustomerModel customerModel = widget.selectedCustomer!;
        if (customerModel.membersData != null) {
          for (int i = 0; i < customerModel.membersData!.length; i++) {
            if (customerModel.membersData![i].name == membersModel.name) {
              customerModel.membersData![i] = membersModel;
              break;
            }
          }
        }
        viewModel.updateCustomer(customerModel);
      }
    }
    AppUtils.showToast(AppConstant.jobItemAddedSuccess);
    if (isSaveAndNew) {
      recreateJobItem();
    }
    viewModel.newMemberJobItemList.clear();

    Navigator.pop(context);
    // viewModel
    //     .addJobItem(
    //         serviceInvoiceId: widget.serviceInvoiceId,
    //         itemQR: itemQRCode,
    //         dueDate: dueDate,
    //         colorName: selectedColorName!,
    //         itemColor: selectedColor!,
    //         noteText: viewModel.jobItemOtherNoteController.text,
    //         jobItemImage: selectedImage!,
    //         timeLineList: timeLineList)
    //     .then((value) {
    //   if (value == AppConstant.success) {
    //     // viewModel.getJobItemList(widget.serviceInvoiceId);
    //
    //   } else {
    //     AppUtils.showToast(value);
    //   }
    //   viewModel.selectedService = null;
    // });
  }

  var isRefreshScreen = false.obs;

  void NewAddMembersJobList(ServiceViewModel viewModel) {
    FocusScope.of(context).unfocus();
    if (selectedImage == null) {
      AppUtils.showToast('Please Select Image');
      return;
    }
    if (selectedColor == null || selectedColorName == null) {
      AppUtils.showToast('Please Select Color');
      return;
    }
    if (viewModel.selectedCustomer == null) {
      AppUtils.showToast('Please Select Customer');
      return;
    }

    if (viewModel.selectedService == null) {
      AppUtils.showToast('Please Select Service');
      return;
    }

    String validateServiceType = viewModel.validateServiceType();
    if (validateServiceType.isNotEmpty) {
      AppUtils.showToast(validateServiceType);
      return;
    }
    if (viewModel.jobItemQtyController.text.isEmpty) {
      AppUtils.showToast('Please Enter Number of Pieces');
      return;
    } else if (viewModel.jobItemQtyController.text == "0") {
      AppUtils.showToast('Please Enter Number of Pieces');
      return;
    }
    isRefreshScreen.value = true;
    List<AddJobTimeLineModel> timeLineList = AppUtils.getInitTimeLineList();
    if (viewModel.selectedMember != null) {
      MembersModel membersModel = widget.selectedMember!;
      if (membersModel.serviceData != null) {
        bool isIdExist = false;
        for (int i = 0; i < membersModel.serviceData!.length; i++) {
          if (membersModel.serviceData![i].serviceId != null) {
            if (membersModel.serviceData![i].serviceId ==
                viewModel.selectedService?.id) {
              isIdExist = true;
              membersModel.serviceData![i].value =
                  viewModel.getServiceTypeValues();
              break;
            }
          }
        }
        if (!isIdExist) {
          MemberServiceData memberServiceData = MemberServiceData(
              serviceId: viewModel.selectedService?.id,
              value: viewModel.getServiceTypeValues());
          membersModel.serviceData!.add(memberServiceData);
        }
      } else {
        MemberServiceData memberServiceData = MemberServiceData(
            serviceId: viewModel.selectedService?.id,
            value: viewModel.getServiceTypeValues());
        membersModel.serviceData = [];
        membersModel.serviceData!.add(memberServiceData);
      }

      if (widget.selectedCustomer != null) {
        CustomerModel customerModel = widget.selectedCustomer!;
        if (customerModel.membersData != null) {
          for (int i = 0; i < customerModel.membersData!.length; i++) {
            if (customerModel.membersData![i].name == membersModel.name) {
              customerModel.membersData![i] = membersModel;
              break;
            }
          }
        }
        viewModel.updateCustomer(customerModel);
      }
    }
    print("selectedMember-1");
    viewModel
        .addJobItem(
            serviceInvoiceId: widget.serviceInvoiceId,
            itemQR: itemQRCode,
            dueDate: dueDate,
            colorName: selectedColorName!,
            itemColor: selectedColor!,
            noteText: viewModel.jobItemOtherNoteController.text,
            jobItemImage: selectedImage!,
            timeLineList: timeLineList)
        .then((result) {
      if (result.isSuccess) {
        viewModel.calculateJobItemTotal();
        final JobItemModel jobItemModel = result.jobItem!;
        final int pieces = jobItemModel.jobItemQty.toInt();
        final double amount = jobItemModel.jobItemTotalCharge.toDouble();
        final double unitPrice = pieces == 0 ? 0.0 : amount / pieces;
        final ConfirmedJobItem confirmedItem = ConfirmedJobItem(
          serviceName: viewModel.selectedService?.name ?? '',
          pieces: pieces,
          amount: amount,
          unitPrice: unitPrice,
          jobItemModel: jobItemModel,
        );
        jobItemList2.add(confirmedItem);
        _recalculateConfirmedItemTotals();
        viewModel.getJobItemList(widget.serviceInvoiceId);
        viewModel.jobItemOtherNoteController.clear();
        viewModel.selectedService = null;
        viewModel.serviceTypeList.clear();
        viewModel.clearServiceValues();
        AppUtils.showToast(AppConstant.jobItemAddedSuccess);
        setState(() {});
        viewModel.notifyListeners();
      } else {
        AppUtils.showToast(result.status);
      }
      isRefreshScreen.value = false;
    });
  }

  void recreateJobItem() {
    Future(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddJobItemScreen(
            serviceInvoiceId: widget.serviceInvoiceId,
            selectedCustomer: widget.selectedCustomer,
            isNew: true,
          ),
        ),
      );
    });
  }

  CustomColorModel? selectedColorModel;
  List<CustomColorModel> colorList = [];

  void getColorsList() async {
    colorList.clear();
    print('getColorsList');
    try {
      await HomeRepository()
          .fetchColorsList(Storage.getValue(FbConstant.createdBy))
          .then((list) {
        if (list.isNotEmpty) {
          colorList.addAll(list);
        }
      });
      await HomeRepository().fetchDefaultColorsList().then((list) {
        if (list.isNotEmpty) {
          colorList.addAll(list);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('err');
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(builder: (context, provider, child) {
      return SafeArea(
        child: Scaffold(
          appBar: OtherScreenAppBar(
            onBackClick: () {
              AppUtils.navigateUp(context);
              provider.newMemberJobItemList.clear();
            },
            title: "Add Job Item",
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Item No.",
                                  style: getRegularStyle(
                                    color: ColorManager.textColorGrey,
                                    fontSize: FontSize.mediumExtra,
                                  ),
                                ),
                                SizedBox(height: 10.sp),
                                Text(
                                  '#$itemQRCode',
                                  style: getBoldStyle(
                                    color: ColorManager.textColorBlack,
                                    fontSize: FontSize.big,
                                  ),
                                ),
                                SizedBox(height: 10.sp),
                                QrImageView(
                                  data: itemQRCode,
                                  version: QrVersions.auto,
                                  size: 40.sp,
                                ),
                                SizedBox(height: 15.sp),
                                Text(
                                  "Due Date",
                                  style: getRegularStyle(
                                    color: ColorManager.textColorGrey,
                                    fontSize: FontSize.mediumExtra,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openDatePicker(),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppUtils.parseDate(
                                            dueDate, AppConstant.dd_mm_yyyy),
                                        style: getBoldStyle(
                                          color: ColorManager.textColorBlack,
                                          fontSize: FontSize.big,
                                        ),
                                      ),
                                      SizedBox(width: 5.sp),
                                      Icon(Icons.keyboard_arrow_down,
                                          size: 19.sp),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: ((builder) =>
                                          chooseImageOptionBottomSheet()),
                                    );
                                    // onImagePicker();
                                  },
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(10.sp),
                                    dashPattern: const [10, 10],
                                    color: ColorManager.colorBlue,
                                    strokeWidth: 4.sp,
                                    child: selectedImage != null
                                        ? Image.file(
                                            selectedImage!,
                                            height: 42.sp,
                                            width: 100.w,
                                            fit: BoxFit.fitHeight,
                                          )
                                        : Container(
                                            height: 45.sp,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25.sp,
                                                vertical: 20.sp),
                                            decoration: BoxDecoration(
                                              color: ColorManager.colorBlue
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.sp),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(height: 5.sp),
                                                    SvgPicture.asset(
                                                      IconAssets.iconPlus,
                                                      color: ColorManager
                                                          .colorBlack,
                                                      height: 17.sp,
                                                      width: 17.sp,
                                                    ),
                                                    SizedBox(height: 15.sp),
                                                    Text(
                                                      "Add Photo",
                                                      style: getMediumStyle(
                                                        color: ColorManager
                                                            .darkPrimary,
                                                        fontSize: FontSize
                                                            .mediumExtra,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 20.sp),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet<CustomColorModel>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          CustomColorPickerBottomSheet(
                                        colorList: colorList,
                                        selectedColorModel: selectedColorModel,
                                      ),
                                    ).then((colorModel) {
                                      if (colorModel != null) {
                                        selectedColorModel = colorModel;
                                        selectedColorName =
                                            selectedColorModel!.name ?? '';
                                        selectedColor = Color(int.parse(
                                            selectedColorModel!.colorCode!));
                                        setState(() {});
                                      }
                                    });
                                    //
                                    //
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return CustomColorPickerDialog(
                                    //         colorList: colorList,
                                    //         selectedColorModel:
                                    //             selectedColorModel);
                                    //   },
                                    // ).then((colorModel) {
                                    //   if (colorModel != null) {
                                    //     selectedColorModel = colorModel;
                                    //     if (colorModel != null) {
                                    //       selectedColorName =
                                    //           selectedColorModel!.name ?? '';
                                    //       selectedColor = Color(int.parse(
                                    //           selectedColorModel!.colorCode!));
                                    //     }
                                    //     setState(() {});
                                    //   }
                                    // });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.sp, horizontal: 10.sp),
                                    decoration: BoxDecoration(
                                        color: ColorManager.colorBlue
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10.sp)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (selectedColorName != null)
                                          Text(
                                            "Color: ",
                                            style: getRegularStyle(
                                              color: ColorManager.textColorGrey,
                                              fontSize: FontSize.mediumExtra,
                                            ),
                                          ),
                                        SizedBox(width: 5.sp),
                                        Flexible(
                                          child: Text(
                                            selectedColorName ?? 'Pick a Color',
                                            style: getBoldStyle(
                                              color:
                                                  ColorManager.textColorBlack,
                                              fontSize: FontSize.mediumExtra,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.sp),
                                        if (selectedColor != null)
                                          BuildColorDot(
                                              color: selectedColor,
                                              size: 15.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.sp),
                      // Text(
                      //   "Customer name *",
                      //   style: getRegularStyle(
                      //     color: ColorManager.textColorGrey,
                      //     fontSize: FontSize.medium,
                      //   ),
                      // ),
                      // SizedBox(height: 10.sp),
                      // SuggestionDropdownWidget(
                      //   controller: provider.phoneController,
                      //   onCustomerSelected: (data) {
                      //     provider.setSelectedCustomer(data);
                      //     setState(() {});
                      //   },
                      //   isFromJobItem: true,
                      // ),
                      CustomerDropDownWidget(
                          memberList: provider.selectedCustomer?.membersData,
                          onChange: (data) {
                            provider.selectedMember = data;
                            setState(() {});
                          },
                          selectedMember: provider.selectedMember,
                          isEnable: provider.newMemberJobItemList.isEmpty),
                      SizedBox(height: 15.sp),

                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.newMemberJobItemList.length + 1,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Show the Column at the first position
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    final String labelText = jobItemList2.isNotEmpty
                                        ? 'Add more'
                                        : 'Service *';
                                    return Text(
                                      labelText,
                                      style: getRegularStyle(
                                        color: ColorManager.textColorGrey,
                                        fontSize: FontSize.medium,
                                      ),
                                    );
                                  }),
                                  SizedBox(height: 10.sp),
                                  Obx(() {
                                    return isRefreshScreen.value
                                        ? const ServiceDropDownWidget()
                                        : const ServiceDropDownWidget();
                                  }),
                                  SizedBox(height: 15.sp),
                                  Text(
                                    "Other note",
                                    style: getRegularStyle(
                                      color: ColorManager.textColorGrey,
                                      fontSize: FontSize.medium,
                                    ),
                                  ),
                                  SizedBox(height: 10.sp),
                                  TextAreaInputWidget(
                                    controller:
                                        provider.jobItemOtherNoteController,
                                    maxLines: 5,
                                    maxLength: 500,
                                    isToShowCounterText: true,
                                  ),
                                  // Text(
                                  //   "Other note",
                                  //   style: getRegularStyle(
                                  //     color: ColorManager.textColorGrey,
                                  //     fontSize: FontSize.medium,
                                  //   ),
                                  // ),
                                ],
                              );
                            } else {
                              // Adjust the index to account for the Column at the first position
                              int adjustedIndex = index - 1;
// provider
//                                     .newMemberJobItemList[adjustedIndex].jobItemServiceId.
                              // provider.getAddNewServiceType(
                              //     provider.newMemberJobItemList[adjustedIndex]
                              //         .jobItemServiceId,
                              //     false,
                              //    );
                              // return Padding(
                              //   padding: EdgeInsets.symmetric(vertical: 2.w),
                              //   child: DataWithServiceDropDownWidget(
                              //     jobItemModel: provider
                              //         .newMemberJobItemList[adjustedIndex],
                              //     serviceViewModel: provider,
                              //   ),
                              // );
                            }
                          }),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonWidget(
                          onPressed: () {
                            NewAddMembersJobList(provider);
                          },
                          title: "Confirm",
                        ),
                      ),
                      // if (provider.jobItemList.isNotEmpty)
                      //   ListView.builder(
                      //     shrinkWrap: true,
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     itemCount: provider.jobItemList.length,
                      //     itemBuilder: (context, index) {
                      //       ServicesListModel jobItem = provider.jobItemList[index];
                      //       return Container(
                      //         margin: const EdgeInsets.all(8),
                      //         padding: const EdgeInsets.all(12),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey),
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: Text(jobItem.name
                      //             .toString()), // replace with widget
                      //       );
                      //     },
                      //   ),
                      Obx(() {
                        return jobItemList2.isEmpty
                            ? const Center(child: Text("No Job Items"))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: jobItemList2.length,
                                itemBuilder: (context, index) {
                                  final ConfirmedJobItem jobItem =
                                      jobItemList2[index];
                                  return Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                jobItem.serviceName,
                                                style: getSemiBoldStyle(
                                                  color:
                                                      ColorManager.textColorBlack,
                                                  fontSize: FontSize.big,
                                                ),
                                              ),
                                              SizedBox(height: 4.sp),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Pieces: ${jobItem.pieces}',
                                                      style: getRegularStyle(
                                                        color: ColorManager
                                                            .textColorGrey,
                                                        fontSize:
                                                            FontSize.mediumExtra,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.add_circle_outline),
                                                    color:
                                                        ColorManager.colorBlue,
                                                    onPressed: _updatingJobItemIds
                                                            .contains(jobItem
                                                                .jobItemModel
                                                                .jobId)
                                                        ? null
                                                        : () =>
                                                            _incrementConfirmedItemQuantity(
                                                                provider,
                                                                jobItem),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹${jobItem.amount.toStringAsFixed(2)}',
                                              style: getBoldStyle(
                                                color: ColorManager
                                                    .textColorBlack,
                                                fontSize: FontSize.big,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                      })
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
          bottomNavigationBar: BottomView(
            onSaveClick: () {
              validateAndSubmitData(provider, false);
            },
            onSaveNextClick: () async {
              validateAndSubmitData(provider, true);
            },
          ),
        ),
      );
    });
  }

  void onChooseOption(ImageSource source) async {
    XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);
    Indicator.showLoading();

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      Indicator.closeIndicator();
      setState(() {});
    } else {
      Indicator.closeIndicator();
    }
  }

  Widget chooseImageOptionBottomSheet() {
    return Container(
      height: 13.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          Text(
            'Choose option',
            style: getBoldStyle(color: Colors.black, fontSize: 17.sp),
          ),
          SizedBox(height: 1.8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera),
                    onPressed: () {
                      onChooseOption(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  InkWell(
                      onTap: () {
                        onChooseOption(ImageSource.camera);
                        Navigator.pop(context);
                      },
                      child: const Text('Camera')),
                  Container(width: 4.w),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () {
                      onChooseOption(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  InkWell(
                      onTap: () {
                        onChooseOption(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                      child: const Text('Gallery')),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  buildWithJobItemListUI(ServiceViewModel viewModel) {
    ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.jobItemList.length,
      itemBuilder: (context, index) {
        var jobItem = viewModel.jobItemList;
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(jobItem.join(",").toString()), // replace with widget
        );
      },
    );
  }
}

class BottomView extends StatelessWidget {
  const BottomView(
      {Key? key,
      required this.onSaveClick,
      required this.onSaveNextClick,
      this.isProcessing = false,
      this.saveLabel = 'Save',
      this.processingLabel = 'Saving...'})
      : super(key: key);

  final Function() onSaveClick, onSaveNextClick;
  final bool isProcessing;
  final String saveLabel;
  final String processingLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: GestureDetector(
        //     onTap: onSaveNextClick,
        //     child: Container(
        //       padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
        //       decoration: BoxDecoration(color: ColorManager.btnColorWhite),
        //       child: Text(
        //         "Save & new",
        //         textAlign: TextAlign.center,
        //         style: getBoldStyle(
        //           color: ColorManager.textColorBlack,
        //           fontSize: FontSize.mediumExtra,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Expanded(
          child: GestureDetector(
            onTap: isProcessing ? null : onSaveClick,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
              decoration: BoxDecoration(color: ColorManager.btnColorDarkBlue),
              child: isProcessing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorManager.textColorWhite,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Text(
                          processingLabel,
                          textAlign: TextAlign.center,
                          style: getBoldStyle(
                            color: ColorManager.textColorWhite,
                            fontSize: FontSize.mediumExtra,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      saveLabel,
                      textAlign: TextAlign.center,
                      style: getBoldStyle(
                        color: ColorManager.textColorWhite,
                        fontSize: FontSize.mediumExtra,
                      ),
                    ),
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: onForwardClick,
        //   child: Container(
        //     width: 35.sp,
        //     padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
        //     decoration: BoxDecoration(color: ColorManager.btnColorWhite),
        //     child: SvgPicture.asset(
        //       IconAssets.iconForward,
        //       width: 19.sp,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

//}
String px = "";
// DropDown
class ServiceDetailWidget extends StatelessWidget {
  const ServiceDetailWidget(
      {Key? key,
      required this.data,
      required this.index,
      required this.viewModelProvider,
      this.isFieldsEnable})
      : super(key: key);

  final ServiceType data;
  final ServiceViewModel viewModelProvider;
  final int index;
  final bool? isFieldsEnable;

  @override
  Widget build(BuildContext context) {
    int pos = viewModelProvider.serviceTypeList.indexOf(data);
    final String unitLabel =
        (viewModelProvider.serviceTypeList[pos].unit?.trim().isNotEmpty ??
                false)
            ? viewModelProvider.serviceTypeList[pos].unit!.trim()
            : 'Inch';
    final String fieldName =
        viewModelProvider.serviceTypeList[pos].name ?? 'Measurement';
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0.sp : 10.sp),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${index + 1}. $fieldName",
              style: getMediumStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.mediumExtra,
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          SizedBox(
            width: 35.sp,
            height: 22.sp,
            child: TextInputWidget(
              isEnable: isFieldsEnable ?? true,
              textInputType: TextInputType.number,
              controller: TextEditingController(
                  text: px),
              isLastField: false,
              inputFormatterRegex: "[0-9. -]",
              onChange: (value) {
                px = value;
                viewModelProvider.serviceTypeList[pos].value = value;
              },
            ),
          ),
          SizedBox(width: 15.sp),
          Text(
            unitLabel,
            style: getMediumStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      ),
    );
  }
}
