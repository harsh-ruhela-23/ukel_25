import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukel/model/coupon_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_job_item_screen.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/customer_dropdown_widget.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/suggestion_dropdown_widget.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/widgets/custom_button_widgets.dart';
import 'package:ukel/widgets/custom_input_fields.dart';

import '../../../../NoTextPasteFormatter.dart';
import '../../../../services/authentication_service.dart';

class ServiceInvoiceScreen extends StatefulWidget {
  const ServiceInvoiceScreen(
      {Key? key, required this.model, this.isUpdate = false, this.isNew = true})
      : super(key: key);
  final ServiceInvoiceModel model;
  final bool? isUpdate, isNew;

  @override
  State<ServiceInvoiceScreen> createState() => _ServiceInvoiceScreenState();
}

class _ServiceInvoiceScreenState extends State<ServiceInvoiceScreen> {
  String paymentTypeRadioValue = "";

  bool isChargesReceived = true;
  final receivedAmtController = TextEditingController();
  final otherNoteController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  num receivedAmt = 0;
  num balancedDueAmt = 0;
  num jobItemTotalQty = 0;
  num additionalCharges = 0;
  num jobItemSubTotal = 0;
  num discount = 0;
  List<ServiceInvoicePriceModel> priceModel = [];

  final repository = HomeRepository();
  CouponModel? couponModel;
  bool isCouponApplied = false;
  bool _isSubmitting = false;
  String tag =  ''; // load saved tag
  num sid = 0;
  @override
  void initState() {
    super.initState();
    if (widget.isNew ?? true) {
      Provider.of<ServiceViewModel>(context, listen: false).clearServiceData();
    }
    Provider.of<ServiceViewModel>(context, listen: false).getCustomersList();
    Provider.of<ServiceViewModel>(context, listen: false).getServicesList();
    Provider.of<ServiceViewModel>(context, listen: false)
        .getJobItemList(widget.model.serviceInvoiceId);
    _loadTag();
    AppUtils().getAndSetGlobalServiceList();
  }
  void _loadTag() async {
    final doc = await FirebaseFirestore.instance
        .collection(FbConstant.branch)
        .doc(Storage.getValue(FbConstant.uid))
        .get();
    setState(() {
      tag = doc.data()?[FbConstant.tag] ?? "";
      sid = doc.data()?[FbConstant.sid] ?? 0;
      sid = sid + 1;
      print("tag loaded - $sid");
    });
  }
  getDatePicker(ServiceViewModel viewModel) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(
          viewModel.invoiceDueDate.millisecondsSinceEpoch),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 100),
    );
    if (datePicked != null) {
      //print('datePicked ${AppUtils.parseDate(datePicked.millisecondsSinceEpoch, AppConstant.dd_mm_yyyy)}');
      viewModel.setInvoiceDueDate(Timestamp.fromDate(datePicked));
      // setState(() {});
    }
  }

  Future<void> validateAndSubmitData(
      ServiceViewModel viewModel, bool isSaveAndNew) async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    List<String> jobItemIds = [];
  //  additionalCharges = viewModel.additionalChargesController.text == "" ? 0 : int.parse(viewModel.additionalChargesController.text);
    if (viewModel.phoneController.text.isEmpty &&
        viewModel.customerNameController.text.isEmpty &&
        viewModel.villageController.text.isEmpty) {
      AppUtils.showToast('Please select Customer');
      return;
    }
    if (viewModel.phoneController.text.length != 10) {
      AppUtils.showToast('Please enter a valid 10-digit phone number');
      return;
    }
    if (viewModel.jobItemList.isEmpty) {
      AppUtils.showToast('Please add Job Item');
      return;
    }
    if (paymentTypeRadioValue.isEmpty) {
      AppUtils.showToast('Please select Payment Type');
      return;
    }
    if (isChargesReceived == false && receivedAmt == 0) {
      AppUtils.showToast('Please enter received amount');
      return;
    }

    // extract jobId from jobList
    for (var element in viewModel.jobItemList) {
      jobItemIds.add(element.jobId);
    }

    ServiceInvoiceModel updatedServiceInvoiceModel = ServiceInvoiceModel(
        branchId: Storage.getValue(FbConstant.uid),
        serviceInvoiceCreatedAtDate: widget.model.serviceInvoiceCreatedAtDate,
        serviceInvoiceDueDate: viewModel.invoiceDueDate,
        serviceInvoiceId: widget.model.serviceInvoiceId,
        serviceInvoicePaymentMode: paymentTypeRadioValue,
        serviceInvoiceReceivedAmount:
            isChargesReceived == true ? jobItemSubTotal : receivedAmt,
        serviceInvoiceDueAmount: isChargesReceived == true ? 0 : balancedDueAmt,
        serviceInvoiceTotalAmount: jobItemSubTotal / jobItemTotalQty,
        serviceInvoiceTotalQty: jobItemTotalQty,
        serviceInvoiceCode: widget.model.serviceInvoiceCode,
        serviceInvoiceCustomerId: viewModel.selectedCustomer!.id,
        serviceInvoiceNotes: otherNoteController.text,
        customerName: viewModel.selectedCustomer?.name ??
            viewModel.customerNameController.text,
        customerPhoneNo: viewModel.phoneController.text,
        customerVillage: viewModel.villageController.text,
        jobIdsList: jobItemIds,
        serviceInvoiceStatusValue: 0,
        couponModel: couponModel,
        sid: sid.toString(),
        tag: tag,
        priceModel: priceModel);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final status = await viewModel.createUpdateServiceInvoice(
          serviceInvoiceModel: updatedServiceInvoiceModel);
      if (status == AppConstant.success) {
        await FirebaseFirestore.instance
            .collection(FbConstant.branch)
            .doc(Storage.getValue(FbConstant.uid))
            .update({FbConstant.sid: sid});
        FBroadcast.instance().broadcast(BroadCastConstant.homeScreenUpdate);
        AppUtils.showToast(AppConstant.serviceInvoiceCreatedSuccess);

        if (isSaveAndNew) {
          await recreateServiceInvoice(viewModel);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        AppUtils.showToast(status);
      }
    } catch (error) {
      AppUtils.showToast('Failed to save invoice. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> recreateServiceInvoice(ServiceViewModel viewModel) async {
    paymentTypeRadioValue = "";
    isChargesReceived = true;
    receivedAmtController.clear();
    otherNoteController.clear();
    receivedAmt = 0;
    balancedDueAmt = 0;
    jobItemTotalQty = 0;
    additionalCharges = 0;
    jobItemSubTotal = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tag = prefs.getString('tagId') ?? ''; // load saved tag
    ServiceInvoiceModel serviceInvoiceModel = ServiceInvoiceModel(
      branchId: Storage.getValue(FbConstant.uid),
      serviceInvoiceCreatedAtDate: Timestamp.now(),
      serviceInvoiceDueDate: Timestamp.now(),
      serviceInvoiceId: generateRandomId(),
      serviceInvoicePaymentMode: '',
      serviceInvoiceReceivedAmount: 0,
      serviceInvoiceDueAmount: 0,
      serviceInvoiceTotalAmount: 0,
      serviceInvoiceTotalQty: 0,
      serviceInvoiceCode: generateServiceInvoiceQRId(),
      serviceInvoiceCustomerId: '',
      serviceInvoiceNotes: '',
      customerName: '',
      customerPhoneNo: '',
      customerVillage: '',
      jobIdsList: [],
      sid:sid.toString(),
      serviceInvoiceStatusValue: 0,
      couponModel: null,
      priceModel: [],
      tag: tag,
    );

    ServiceViewModel()
        .createUpdateServiceInvoice(serviceInvoiceModel: serviceInvoiceModel)
        .then((status) {
      if (status == AppConstant.success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceInvoiceScreen(
              model: serviceInvoiceModel,
              isNew: true,
            ),
          ),
        );
      }
    });
  }

  void handleClick(int item, ServiceViewModel viewModel) {
    switch (item) {
      case 0:
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
                FBroadcast.instance()
                    .broadcast(BroadCastConstant.homeScreenUpdate);
                AppUtils.navigateUp(context);
                AppUtils.navigateUp(context, argument: true);
              },
            );
          },
        );
        break;
    }
  }

  Future<void> deleteJobItems(ServiceViewModel viewModel) async {
    if (viewModel.jobItemList.isNotEmpty) {
      for (int i = 0; i < viewModel.jobItemList.length; i++) {
        await viewModel.deleteJobItem(viewModel.jobItemList[i].jobId);
      }
    }
  }

  applyCoupon() async {
    try {
      if (codeController.text.isEmpty) {
        AppUtils.showToast("Please enter coupon code to apply coupon");
        return;
      }

      await repository.fetchCouponByCode(codeController.text).then((data) {
        if (data != null) {
          couponModel = data;
          isCouponApplied = true;
          AppUtils.showToast(AppConstant.couponAppliedSuccess);
        } else {
          AppUtils.showToast("No Coupon found");
          isCouponApplied = false;
        }
      });
    } catch (e) {
      isCouponApplied = false;
      AppUtils.showToast("Error: $e");
    }
    calculateDiscount();
    setState(() {});
  }

  clearCoupon() {
    isCouponApplied = false;
    codeController.text = "";
    couponModel = null;
    calculateDiscount();
  }

  calculateDiscount() {
    if (couponModel != null) {
      if (jobItemSubTotal > num.parse(couponModel!.amount!)) {
        discount = num.parse(couponModel!.amount!);
      } else {
        discount = (jobItemSubTotal);
      }
    } else {
      discount = 0;
    }
    calculateSubTotal();
    setState(() {});
  }

  calculateSubTotal() {
    jobItemTotalQty = 0;
    jobItemSubTotal = 0;
    priceModel.forEach((element) {
      jobItemTotalQty += element.qty;
      jobItemSubTotal += (element.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    // cancel dialog
    showCancelDialog(ServiceViewModel viewModel) {
      // set up the AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: "Are you want to save invoice?",
            negativeLabel: "Save",
            positiveLabel: "Don't Save",
            onNegativeClick: () {
              FBroadcast.instance()
                  .broadcast(BroadCastConstant.homeScreenUpdate);
              viewModel.customerName.text = "";
              Navigator.pop(context);
              AppUtils.navigateUp(context, argument: true);
            },
            onPositiveClick: () async {
              await deleteJobItems(viewModel);
              viewModel.deleteServiceInvoiceItem(widget.model.serviceInvoiceId);
              FBroadcast.instance()
                  .broadcast(BroadCastConstant.homeScreenUpdate);
              AppUtils.navigateUp(context);
              AppUtils.navigateUp(context, argument: true);
            },
          );
        },
      );
    }

    Future<bool> willPopCallback(ServiceViewModel viewModel) async {
      showCancelDialog(viewModel);
      return true;
    }

    return Consumer<ServiceViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () => willPopCallback(viewModel),
            child: Scaffold(
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
                  'Service Invoice',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.large,
                  ),
                ),
                leading: Padding(
                  padding: EdgeInsets.only(left: 15.sp),
                  child: GestureDetector(
                    onTap: () {
                      willPopCallback(viewModel);
                      //AppUtils.navigateUp(context);

                    },
                    child: SvgPicture.asset(
                      IconAssets.iconBack,
                      height: 10.sp,
                      width: 10.sp,
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton<int>(
                    offset: const Offset(-33, 30),
                    onSelected: (item) => handleClick(item, viewModel),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
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
                    ],
                  ),
                ],
                leadingWidth: 26.sp,
              ),
              body: viewModel.isJobListFetchingData == true
                  ? Center(child: buildLoadingWidget)
                  : viewModel.jobItemList.isEmpty
                      ? buildEmptyJobItemListUI(viewModel)
                      : buildWithJobItemListUI(viewModel),
              bottomNavigationBar: BottomView(
                isProcessing: _isSubmitting,
                onSaveNextClick: () {
                  validateAndSubmitData(viewModel, true);
                },
                onSaveClick: () {
                  validateAndSubmitData(viewModel, false);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEmptyJobItemListUI(ServiceViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: getRegularStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                      Text(
                        AppUtils.parseDate(
                            widget.model.serviceInvoiceCreatedAtDate
                                .millisecondsSinceEpoch,
                            AppConstant.dd_mm_yyyy),
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.bigExtra,
                        ),
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
                        onTap: () => getDatePicker(viewModel),
                        child: Row(
                          children: [
                            Text(
                              AppUtils.parseDate(
                                  viewModel
                                      .invoiceDueDate.millisecondsSinceEpoch,
                                  AppConstant.dd_mm_yyyy),
                              style: getBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.bigExtra,
                              ),
                            ),
                            SizedBox(width: 5.sp),
                            Icon(Icons.keyboard_arrow_down, size: 19.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 3.sp,
                  height: 40.sp,
                  color: ColorManager.colorGrey,
                  child: const Column(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '#$tag - $sid',
                        style: getRegularStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                      QrImageView(
                        data: widget.model.serviceInvoiceCode,
                        version: QrVersions.auto,
                        size: 40.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.sp),
            margin: EdgeInsets.symmetric(horizontal: 15.sp),
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
                  "Phone Number *",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                SuggestionDropdownWidget(
                  controller: viewModel.phoneController,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    NoTextPasteFormatter(), // block pasting non-numbers
                  ],
                  onCustomerSelected: (data) {
                    viewModel.setSelectedCustomer(data);
                    viewModel.customerName.text =
                        viewModel.selectedCustomer!.name;
                    viewModel.selectedMember = viewModel.selectedCustomer!.membersData![0];
                    setState(() {});
                  },
                ),
                SizedBox(height: 15.sp),
                Text(
                  "Customer name *",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                TextInputWidget(controller: viewModel.customerName,isEnable: false,hintText: "Please Select Phone number first",),
                // CustomerDropDownWidget(
                //   isEnable:false,
                //   isDropDownEnable:false,
                //   memberList: viewModel.selectedCustomer?.membersData,
                //   onChange: (data) {
                //     viewModel.selectedMember = data;
                //     setState(() {});
                //   },
                //   selectedMember: viewModel.selectedMember,
                // ),
               SizedBox(height: 15.sp),
                Text(
                  "Members name *",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                CustomerDropDownWidget(
                  memberList: viewModel.selectedCustomer?.membersData,
                  onChange: (data) {
                    viewModel.selectedMember = data;
                    setState(() {});
                  },
                  selectedMember: viewModel.selectedMember,
                  isEnable: viewModel.selectedCustomer != null,
                ),
                SizedBox(height: 15.sp),
                Text(
                  "Village *",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                TextInputWidget(controller: viewModel.villageController),
                SizedBox(height: 20.sp),
                ButtonWidget(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (viewModel.selectedCustomer == null) {
                      AppUtils.showToast(
                          "Please enter customer details first!");
                      return;
                    }
                    jobItemList2.clear();
                    jobItemCount.value = 0.0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddJobItemScreen(
                          serviceInvoiceId: widget.model.serviceInvoiceId,
                          selectedCustomer: viewModel.selectedCustomer,
                          selectedMember: viewModel.selectedMember,
                          isNew: true,
                        ),
                      ),
                    );
                  },
                  title: "Confirm",
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.bigExtra,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.sp, horizontal: 15.sp),
                      decoration: BoxDecoration(
                        color: ColorManager.colorLightWhite,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(IconAssets.iconRupee),
                          SizedBox(width: 8.sp),
                          Text(
                            "0",
                            style: getBoldStyle(
                              color: ColorManager.textColorBlack,
                              fontSize: FontSize.big,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
                Text(
                  "Additional Charges *",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 15.sp),
                // TextInputWidget(
                //     controller: viewModel.additionalChargesController, isEnable: true,onChange: (p0) {
                //
                //     },textInputType: TextInputType.number,),
                // SizedBox(height: 15.sp),
                Text(
                  "Other note",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                TextAreaInputWidget(
                  controller: otherNoteController,
                  maxLines: 5,
                  maxLength: 500,
                  isToShowCounterText: true,
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],
      ),
    );
  }
  Widget buildWithJobItemListUI(ServiceViewModel viewModel) {
    priceModel = [];
    for (var element in viewModel.jobItemList) {
      priceModel.add(ServiceInvoicePriceModel(
        qty: element.jobItemQty,
        amount: element.jobItemTotalCharge,
        jobId: element.jobId,
      ));
      // jobItemTotalQty += element.jobItemQty;
      // jobItemSubTotal += (element.jobItemTotalCharge * element.jobItemQty);
    }

    calculateSubTotal();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: getRegularStyle(
                                color: ColorManager.textColorGrey,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            Text(
                              AppUtils.parseDate(
                                  widget.model.serviceInvoiceCreatedAtDate
                                      .millisecondsSinceEpoch,
                                  AppConstant.dd_mm_yyyy),
                              style: getBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.bigExtra,
                              ),
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
                              onTap: () => getDatePicker(viewModel),
                              child: Row(
                                children: [
                                  Text(
                                    AppUtils.parseDate(
                                        viewModel.invoiceDueDate
                                            .millisecondsSinceEpoch,
                                        AppConstant.dd_mm_yyyy),
                                    style: getBoldStyle(
                                      color: ColorManager.textColorBlack,
                                      fontSize: FontSize.bigExtra,
                                    ),
                                  ),
                                  SizedBox(width: 5.sp),
                                  Icon(Icons.keyboard_arrow_down, size: 19.sp),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 3.sp,
                        height: 40.sp,
                        color: ColorManager.colorGrey,
                        child: Column(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '#$tag - $sid',
                              style: getRegularStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            QrImageView(
                              data: widget.model.serviceInvoiceCode,
                              version: QrVersions.auto,
                              size: 40.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "Phone Number *",
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.medium,
                      
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  SuggestionDropdownWidget(
                    controller: viewModel.phoneController,
                    isEnable: false,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "Customer name *",
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  CustomerDropDownWidget(
                    memberList: viewModel.selectedCustomer?.membersData,
                    onChange: (data) {
                      viewModel.selectedMember = data;
                      setState(() {});
                    },
                    selectedMember: viewModel.selectedMember,
                    isEnable: false,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "Village *",
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  TextInputWidget(
                      controller: viewModel.villageController, isEnable: false),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 15.sp, right: 15.sp, top: 20.sp, bottom: 15.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Billed Items",
                      style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.large,
                      ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 3,
                    child: SvgPicture.asset(
                      IconAssets.iconBtnForward,
                      height: 23.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.sp),
              margin: EdgeInsets.symmetric(horizontal: 15.sp),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorManager.colorGrey,
                  width: 3.sp,
                ),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: viewModel.jobItemList.length,
                    itemBuilder: (context, index) {
                      JobItemModel jobItemModel = viewModel.jobItemList[index];
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : 15.sp),
                        child: BilledItemsWidget(
                            onTapDeleteJobItem: (jobItemId) {
                              viewModel.deleteJobItem(jobItemId).then((value) {
                                if (value == AppConstant.success) {
                                  viewModel.removeJobItemLocally(jobItemModel);
                                  AppUtils.showToast('Item Deleted Successfully');
                                } else {
                                  AppUtils.showToast(value.toString());
                                }
                              });
                            },
                            jobItemModel: jobItemModel,
                            serviceList: viewModel.servicesModelList),
                      );
                    },
                  ),
                  SizedBox(height: 18.sp),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Total QTY :",
                              style: getSemiBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.big,
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            Expanded(
                              child: Text(
                                jobItemTotalQty.toString(),
                                style: getSemiBoldStyle(
                                  color: ColorManager.textColorGrey,
                                  fontSize: FontSize.mediumExtra,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              "Sub Total :",
                              style: getSemiBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.big,
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            Expanded(
                              child: Text(
                                "₹ ${(jobItemSubTotal)}",
                                style: getSemiBoldStyle(
                                  color: ColorManager.textColorGrey,
                                  fontSize: FontSize.mediumExtra,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  ButtonWidget(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      jobItemList2.clear();
                      jobItemCount.value = 0.0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddJobItemScreen(
                            serviceInvoiceId: widget.model.serviceInvoiceId,
                            selectedCustomer: viewModel.selectedCustomer,
                            selectedMember: viewModel.selectedMember,
                            isNew: true,
                          ),
                        ),
                      );
                    },
                    title: "Confirm",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 20.sp),
              child: Text(
                "Coupon",
                style: getBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.large,
                ),
              ),
            ),
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextInputWidget(
                          controller: codeController,
                          hintText: 'Coupon code',
                          isEnable: !isCouponApplied,
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      isCouponApplied
                          ? GestureDetector(
                              onTap: () {
                                clearCoupon();
                              },
                              child: Text(
                                "Clear",
                                style: getBoldStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.big,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                applyCoupon();
                              },
                              child: Text(
                                "Apply",
                                style: getBoldStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.big,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 20.sp),
              child: Text(
                "Charges",
                style: getBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.large,
                ),
              ),
            ),
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
                children: [
                  Row(
                    children: [
                      Text(
                        "Amount",
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          "₹ ${jobItemSubTotal}",
                          textAlign: TextAlign.right,
                          style: getSemiBoldStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.bigExtra,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      Text(
                        "Discount",
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          "₹ ${discount}",
                          textAlign: TextAlign.right,
                          style: getSemiBoldStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.bigExtra,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      Text(
                        "Total Amount",
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          "₹ ${(jobItemSubTotal) - discount}",
                          textAlign: TextAlign.right,
                          style: getSemiBoldStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.bigExtra,
                          ),
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
                            Checkbox(
                              // fillColor: MaterialStateProperty.all<Color>(
                              //     ColorManager.primary),
                              activeColor: ColorManager.primary,
                              value: isChargesReceived,
                              onChanged: (value) {
                                isChargesReceived = value!;
                                setState(() {});
                              },
                            ),
                            Text(
                              "Received",
                              style: getBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.big,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      isChargesReceived
                          ? Text(
                              "₹ ${(jobItemSubTotal) - discount}",
                              textAlign: TextAlign.right,
                              style: getSemiBoldStyle(
                                color: ColorManager.textColorGrey,
                                fontSize: FontSize.bigExtra,
                              ),
                            )
                          : SizedBox(
                              width: 38.sp,
                              height: 25.sp,
                              child: TextInputWidget(
                                preFixText: '₹ ',
                                prefixStyle: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                textInputType: TextInputType.number,
                                controller: receivedAmtController,
                                isLastField: true,
                                onChange: (val) {
                                  if (val.isNotEmpty) {
                                    receivedAmt = num.parse(val);
                                    if (receivedAmt >
                                        ((jobItemSubTotal) - discount)) {
                                      AppUtils.showToast(
                                          'can not be more than Total Amount');
                                    } else {
                                      balancedDueAmt =
                                          ((jobItemSubTotal) - discount) -
                                              receivedAmt;
                                    }
                                  } else {
                                    balancedDueAmt =
                                        ((jobItemSubTotal) - discount);
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Container(
                    height: 3.sp,
                    decoration: BoxDecoration(color: ColorManager.colorGrey),
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      Text(
                        "Balance Due",
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          isChargesReceived ? "₹0" : "₹$balancedDueAmt",
                          textAlign: TextAlign.right,
                          style: getSemiBoldStyle(
                            color: isChargesReceived
                                ? ColorManager.colorFrancisLightGreen
                                : ColorManager.textColorRed,
                            fontSize: FontSize.bigExtra,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 15.sp, right: 15.sp, top: 20.sp, bottom: 15.sp),
              child: Text(
                "Payment Type",
                style: getBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.bigExtra,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.sp, right: 5.sp, bottom: 15.sp),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorManager.colorGrey,
                    width: 3.sp,
                  ),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          "Cash",
                          style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.big,
                          ),
                        ),
                        value: AppConstant.cash,
                        groupValue: paymentTypeRadioValue,
                        onChanged: (value) {
                          setState(() {
                            paymentTypeRadioValue = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          "Online",
                          style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.big,
                          ),
                        ),
                        value: AppConstant.online,
                        groupValue: paymentTypeRadioValue,
                        onChanged: (value) {
                          setState(() {
                            paymentTypeRadioValue = value.toString();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15.sp,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Other note",
                    style: getRegularStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  TextAreaInputWidget(
                    controller: otherNoteController,
                    maxLines: 5,
                    maxLength: 500,
                    isToShowCounterText: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }
}

// BilledItemsWidget
class BilledItemsWidget extends StatelessWidget {
  const BilledItemsWidget(
      {Key? key,
      required this.jobItemModel,
      required this.serviceList,
      required this.onTapDeleteJobItem})
      : super(key: key);
  final JobItemModel jobItemModel;
  final List<ServicesListModel> serviceList;
  final Function(String) onTapDeleteJobItem;

  @override
  Widget build(BuildContext context) {
    // void copyJobItem(ServiceViewModel viewModel, bool isSaveAndNew) {
    //   FocusScope.of(context).unfocus();
    //   List<AddJobTimeLineModel> timeLineList = AppUtils.getInitTimeLineList();
    //   viewModel
    //       .addJobItem(
    //           serviceInvoiceId: jobItemModel.serviceInvoiceId,
    //           itemQR: generateJobItemInvoiceQRId(),
    //           dueDate: DateTime.now().millisecondsSinceEpoch,
    //           itemColor: IntToHexColor(jobItemModel.jobItemColor.toString()),
    //           noteText: viewModel.jobItemOtherNoteController.text,
    //           jobItemImage: selectedImage!,
    //           timeLineList: timeLineList)
    //       .then((value) {
    //     if (value == AppConstant.success) {
    //       viewModel.getJobItemList(jobItemModel.serviceInvoiceId);
    //       AppUtils.showToast(AppConstant.jobItemAddedSuccess);
    //       if (isSaveAndNew) {
    //         recreateJobItem();
    //       }
    //       Navigator.pop(context);
    //     } else {
    //       AppUtils.showToast(value);
    //     }
    //   });
    // }

    return Slidable(
      key: const ValueKey(0),
      closeOnScroll: false,
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            onPressed: (context) {},
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmationDialog(
                    title: "Are you sure want to delete item!",
                    negativeLabel: "Cancel",
                    positiveLabel: "Delete",
                    onNegativeClick: () => Navigator.pop(context),
                    onPositiveClick: () {
                      Navigator.pop(context);
                      onTapDeleteJobItem(jobItemModel.jobId);
                    },
                  );
                },
              );
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
            color: ColorManager.colorLightGrey,
            borderRadius: BorderRadius.circular(10.sp)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${jobItemModel.jobItemCode}',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.bigExtra,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppUtils.parseDate(
                        jobItemModel.jobItemDueDate, AppConstant.dd_mm_yyyy),
                    textAlign: TextAlign.right,
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.big,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.sp),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppUtils().getServiceNameById(
                        serviceId: jobItemModel.jobItemServiceId),
                    style: getSemiBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.big,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${jobItemModel.jobItemQty.toString()} X ${(jobItemModel.jobItemTotalCharge / jobItemModel.jobItemQty).toString()} = ${jobItemModel.jobItemQty * (jobItemModel.jobItemTotalCharge / jobItemModel.jobItemQty)}",
                    textAlign: TextAlign.right,
                    style: getBoldStyle(
                      color: ColorManager.textColorGrey,
                      fontSize: FontSize.mediumExtra,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
