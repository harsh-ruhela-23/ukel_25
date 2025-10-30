import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/custom_craftman_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/model/customer_model.dart';

import 'custom_page_transition.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AppUtils {
  static List<ServicesListModel> globalServiceTypeList = [];

  static setGlobalServiceTypeListList(List<ServicesListModel> list) {
    globalServiceTypeList.clear();
    globalServiceTypeList.addAll(list);
  }

  // global service
  getAndSetGlobalServiceList() async {
    Map<String, dynamic> result =
        await ServiceInvoiceRepository().fetchServices();

    List<ServicesListModel> servicesList = result[FbConstant.service];

    if (servicesList.isNotEmpty) {
      AppUtils.setGlobalServiceTypeListList(servicesList);
    }
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    CustomPageTransition customPageTransition,
  ) {
    Navigator.pushAndRemoveUntil(
        context, customPageTransition, (route) => false);
  }

  static Future<dynamic> navigateTo(
    BuildContext context,
    CustomPageTransition customPageTransition,
  ) async {
    return await Navigator.push(context, customPageTransition);
  }

  static void navigateUp(BuildContext context, {dynamic argument}) {
    Navigator.pop(context, argument);
  }

  static Future<bool> checkNetworkConnection() async {
    bool isConnected = false;
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      isConnected = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      isConnected = true;
    }
    return isConnected;
  }

  static showLoaderDialog(BuildContext context, bool status) {
    if (status) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                  color: Colors.transparent,
                  width: 10,
                  height: 100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.cyan,
                      strokeWidth: 3,
                    ),
                  )));
        },
      );
    } else {
      navigateUp(context);
    }
  }

  static bool isTablet() {
    return Device.screenType == ScreenType.tablet;
  }

  static showToast(String msg,
      {Toast? toastLength, ToastGravity? toastGravity}) {
    int timeInSec = 1;

    switch (toastLength) {
      case null:
        timeInSec = 2;
        break;
      case Toast.LENGTH_SHORT:
        timeInSec = 1;
        break;
      case Toast.LENGTH_LONG:
        timeInSec = 3;
        break;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength ?? Toast.LENGTH_SHORT,
        gravity: toastGravity ?? ToastGravity.BOTTOM,
        timeInSecForIosWeb: timeInSec,
        backgroundColor: const Color.fromRGBO(251, 164, 218, 0.6),
        textColor: Colors.black,
        fontSize: 18.0);
  }

  static String parseDate(int milliseconds, String format) {
    // int milli = milliseconds;
    // if (milliseconds.toString().length < 13) {
    //   milli = milliseconds * 1000;
    // }
    var date = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    return DateFormat(format).format(date);
  }

  // input : 5PFwl7HABhOzL14j3M5D (serviceId)
  // output : Koti-Blouse (serviceName)
  String getServiceNameById({required String serviceId}) {
    if (globalServiceTypeList.isNotEmpty) {
      for (var element in globalServiceTypeList) {
        if (element.id == serviceId) {
          return element.name;
        }
      }
    } else {
      return serviceId;
    }
    return serviceId;
  }

  // input : _oZ5AslNSpCWAXK7u1bDDfca9jjeWBBL4Q (serviceId)
  // output : Kartik Patel (serviceName)
  String getCustomerNameById(
      {required List<CustomerModel> customerList, required String customerId}) {
    if (customerList.isNotEmpty) {
      for (var element in customerList) {
        if (element.id == customerId) {
          return element.name;
        }
      }
    } else {
      return customerId;
    }
    return customerId;
  }

  static String getJobStatusName(String percent) {
    String status = AppConstant.inShop;

    if (percent == JobPercentConstant.percent16 ||
        percent == JobPercentConstant.percent68) {
      status = AppConstant.shipment;
    } else if (percent == JobPercentConstant.percent34) {
      status = AppConstant.inProcess;
    } else if (percent == JobPercentConstant.percent50) {
      status = AppConstant.jobDone;
    } else if (percent == JobPercentConstant.percent84) {
      status = AppConstant.packingQt;
    } else if (percent == JobPercentConstant.percent99) {
      status = AppConstant.tobeDeliver;
    } else if (percent == JobPercentConstant.percent100) {
      status = AppConstant.deliver;
    }

    return status;
  }

  static Color getProgressIndicatorColor(String status) {
    Color color = ColorManager.colorStatusPending;
    if (status == JobPercentConstant.percent0) {
      color = ColorManager.colorStatusPending;
    } else if (status == JobPercentConstant.percent16 ||
        status == JobPercentConstant.percent68 ||
        status == JobPercentConstant.percent34) {
      color = ColorManager.colorStatusInProgress;
    } else if (status == JobPercentConstant.percent50) {
      color = ColorManager.colorStatusPickUp;
    } else if (status == JobPercentConstant.percent84) {
      color = ColorManager.colorStatusQT;
    } else if (status == JobPercentConstant.percent99 ||
        status == JobPercentConstant.percent100) {
      color = ColorManager.colorStatusDeliver;
    }

    return color;
  }

  static double getPercentageForIndicator(String status) {
    double percentageInDouble = 0.0;

    int percentage = 0;
    percentage = int.parse(status);

    percentageInDouble = percentage / 100;
    return percentageInDouble;
  }

  static int getServiceCompleteStatusPer(List<JobItemModel> jobList) {
    int percentage = 0;

    int jobCompleteCount = 0;
    if (jobList.isNotEmpty) {
      for (int i = 0; i < jobList.length; i++) {
        jobCompleteCount += int.parse(jobList[i].jobItemPercentage);
      }

      percentage = jobCompleteCount ~/ jobList.length;
    }
    return percentage;
  }

static List<String> getImagesListtatusPer(List<JobItemModel> jobList) {


     List<String > listImagesList = [];
    if (jobList.isNotEmpty) {
      for (int i = 0; i < jobList.length; i++) {
        listImagesList.add(jobList[i].jobItemImageUrl);
      }

    
    }
    return listImagesList;
  }
  static List<String> jobStatusListInOrder() {
    List<String> statusListInOrder = [
      JobPercentConstant.percent0,
      JobPercentConstant.percent16,
      JobPercentConstant.percent34,
      JobPercentConstant.percent50,
      JobPercentConstant.percent68,
      JobPercentConstant.percent84,
      JobPercentConstant.percent99,
      JobPercentConstant.percent100,
    ];
    return statusListInOrder;
  }

  static bool isJobStatusCompleted(
      AddJobTimeLineModel status, String jobStatus, int rejectCount) {
    bool isComplete = false;

    int indexOfJobStatus = jobStatusListInOrder().indexOf(jobStatus);
    int indexOfStatus = jobStatusListInOrder().indexOf(status.statusPer);
    if (indexOfStatus != -1 && indexOfJobStatus != -1) {
      if (status.statusPer == "100") {
        if (status.isComplete) {
          isComplete = true;
        }
      } else {
        if (status.rejectCount < rejectCount) {
          isComplete = true;
        } else {
          if (indexOfStatus <= indexOfJobStatus) {
            isComplete = true;
          }
        }
      }
    }

    return isComplete;
  }

  // For Home Screen

  // 1. In Shop
  static String getTotalInShopJobs({required List<JobItemModel> allJobList}) {
    List<JobItemModel> inShopJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent0) {
          inShopJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${inShopJobItemList.length} ${inShopJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  // 2. In Process
  static String getTotalInProcessJobs(
      {required List<JobItemModel> allJobList}) {
    List<JobItemModel> inProgressJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent34) {
          inProgressJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${inProgressJobItemList.length} ${inProgressJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  // 3. Shipment
  static String getTotalShipmentJobs({required List<JobItemModel> allJobList}) {
    List<JobItemModel> shipmentJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent16 ||
            element.jobItemPercentage == JobPercentConstant.percent68) {
          shipmentJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${shipmentJobItemList.length} ${shipmentJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  // 4. Pick Up
  static String getTotalPickUpJobs({required List<JobItemModel> allJobList}) {
    List<JobItemModel> pickUpJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent50) {
          pickUpJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${pickUpJobItemList.length} ${pickUpJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  // 5. packingQt
  static String getTotalPackingQtJobs(
      {required List<JobItemModel> allJobList}) {
    List<JobItemModel> packingQtJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent84) {
          packingQtJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${packingQtJobItemList.length} ${packingQtJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  // 6. To be Delivered
  static String getTotalToBeDeliveredJobs(
      {required List<JobItemModel> allJobList}) {
    List<JobItemModel> toBeDeliveredJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent99) {
          toBeDeliveredJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${toBeDeliveredJobItemList.length} ${toBeDeliveredJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }

  static bool canChangeJobStatus(String currentStatus,
      AddJobTimeLineModel changeStatus, int rejectCount, bool isAdd) {
    bool canChangeStatus = false;

    int indexOfCurrentStatus = jobStatusListInOrder().indexOf(currentStatus);
    int indexOfChangeStatus =
        jobStatusListInOrder().indexOf(changeStatus.statusPer);

    if (Storage.getValue(AppConstant.role) == "C") {
      if ((indexOfCurrentStatus == 1 && isAdd) ||
          indexOfCurrentStatus == 2 ||
          indexOfCurrentStatus == 3) {
        canChangeStatus = true;
      } else {
        return canChangeStatus;
      }
    }

    if (indexOfChangeStatus != -1 && indexOfCurrentStatus != -1) {
      if (isAdd) {
        if (indexOfChangeStatus == indexOfCurrentStatus + 1) {
          if (rejectCount == changeStatus.rejectCount) {
            canChangeStatus = true;
          } else if (changeStatus.rejectCount == 0) {
            if (jobStatusListInOrder()[indexOfChangeStatus] ==
                JobPercentConstant.percent100) {
              canChangeStatus = true;
            }
          }
        }
      } else {
        if (indexOfCurrentStatus < 3) {
          if (indexOfChangeStatus == indexOfCurrentStatus) {
            if (rejectCount == changeStatus.rejectCount) {
              canChangeStatus = true;
            }
          }
        }
      }
    } else if (indexOfCurrentStatus == -1) {
      if (indexOfChangeStatus < 1) {
        if (isAdd) {
          if (indexOfChangeStatus == indexOfCurrentStatus + 1) {
            if (rejectCount == changeStatus.rejectCount) {
              canChangeStatus = true;
            }
          }
        } else {
          if (indexOfCurrentStatus < 3) {
            if (indexOfChangeStatus == indexOfCurrentStatus) {
              if (rejectCount == changeStatus.rejectCount) {
                canChangeStatus = true;
              }
            }
          }
        }
      }
    }

    return canChangeStatus;
  }

  // craftsman
  static num? calculateCraftsmanIndividualRemainingDays(
      CraftsmanModel craftsmanModel) {
    num totalPendingJobs = craftsmanModel.appointed + craftsmanModel.running;
    num workCapacity = craftsmanModel.serviceInfoModel.workCapacity;

    if (totalPendingJobs != 0 && workCapacity != 0) {
      return totalPendingJobs / workCapacity;
    }
    return null;
  }

  static double getCraftsmanWorkLoad(
      List<CustomCraftsmanModel> customCraftsmanList,
      num remainingDays,
      String serviceType) {
    List<num> remainingDaysList = [];
    num maxRemainingDays = 0;

    if (customCraftsmanList.isNotEmpty) {
      for (var element in customCraftsmanList) {
        if (serviceType == element.model.serviceInfoModel.serviceType) {
          remainingDaysList.add(element.remainingDays);
        }
      }
    }

    double result;

    if (remainingDaysList.isNotEmpty && remainingDaysList.length > 1) {
      maxRemainingDays = remainingDaysList.reduce(max);

      if (maxRemainingDays == 0) {
        result = 0;
      } else {
        result = (remainingDays / maxRemainingDays) > 0
            ? (remainingDays / maxRemainingDays)
            : 0;
      }
    } else {
      result = remainingDays.toDouble();
    }

    // 👉 Apply cap: if remainingDays > 2.0, force result = 1.0
    if (remainingDays > 1.0) {
      result = 1.0;
    }

    return result.toDouble();
  }

  static List<AddJobTimeLineModel> getInitTimeLineList() {
    List<AddJobTimeLineModel> list = [];
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent16,
        title: TimeLineTitleConstant.outFromShop,
        subTitle: "Craftsman",
        rejectCount: 0,
        bgColor: 0xFFE1EBFA,
        indicatorColor: 0xFFA3B0C3,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: true));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent34,
        title: TimeLineTitleConstant.craftsmanReceivedWork,
        rejectCount: 0,
        bgColor: 0xFFFAF4E1,
        indicatorColor: 0xFFFACF44,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: false));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent50,
        title: TimeLineTitleConstant.jobDone,
        rejectCount: 0,
        bgColor: 0xFFFAF4E1,
        indicatorColor: 0xFFFACF44,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: false));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent68,
        title: TimeLineTitleConstant.outFromCraftsman,
        rejectCount: 0,
        subTitle: "Shop",
        bgColor: 0xFFFAF4E1,
        indicatorColor: 0xFFFACF44,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: false));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent84,
        title: TimeLineTitleConstant.receivedAtShop,
        rejectCount: 0,
        bgColor: 0xFFE5E4FD,
        indicatorColor: 0xFF877EFD,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: false));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent99,
        title: TimeLineTitleConstant.qualityTestingAndPacking,
        rejectCount: 0,
        bgColor: 0xFFFEE5E7,
        indicatorColor: 0xFFFE6776,
        isComplete: false,
        isReject: false,
        isLast: false,
        isFirst: false));
    list.add(AddJobTimeLineModel(
        statusPer: JobPercentConstant.percent100,
        title: TimeLineTitleConstant.delivered,
        rejectCount: 0,
        bgColor: 0xFFE1FAEC,
        indicatorColor: 0xFF79CB9D,
        isComplete: false,
        isReject: false,
        isLast: true,
        isFirst: false));

    return list;
  }

  static List<AddJobTimeLineModel> timelineStatusList(
      List<AddJobTimeLineModel> list, int count) {
    List<AddJobTimeLineModel> tempList = [];
    tempList.addAll(list);
    int diffeerence = tempList.length - ((count * 6) + 1);
    if (count > 0) {
      if (count == 1 && tempList.length == 7) {
        AddJobTimeLineModel lastObj = tempList[tempList.length - 1];
        tempList.remove(lastObj);
        for (int i = 0; i < count; i++) {
          List<AddJobTimeLineModel> tList = getInitTimeLineList();
          tList.removeAt(getInitTimeLineList().length - 1);
          for (int j = 0; j < tList.length; j++) {
            tList[j].rejectCount = count;
            tempList.add(tList[j]);
          }
        }
        tempList.add(lastObj);
      } else {
        if (diffeerence == 0) {
          AddJobTimeLineModel lastObj = tempList[tempList.length - 1];
          tempList.remove(lastObj);

          List<AddJobTimeLineModel> tList = getInitTimeLineList();
          tList.removeAt(getInitTimeLineList().length - 1);
          for (int j = 0; j < tList.length; j++) {
            tList[j].rejectCount = count;
            tempList.add(tList[j]);
          }

          tempList.add(lastObj);
        }
        // if (tempList.length > (6 * count) + 1) {
        // } else {
        //   AddJobTimeLineModel lastObj = tempList[tempList.length - 1];
        //   tempList.remove(lastObj);
        //   for (int i = 0; i < count; i++) {
        //     List<AddJobTimeLineModel> tList = getInitTimeLineList();
        //     tList.removeAt(getInitTimeLineList().length - 1);
        //     for (int j = 0; j < tList.length; j++) {
        //       tList[j].rejectCount = count;
        //       tempList.add(tList[j]);
        //     }
        //   }
        //   tempList.add(lastObj);
        // }
      }
    }
    return tempList;
  }

  static String getServiceInvoiceStatusNameByPercent(num percentage) {
    String status = 'In-Progress';

    if (percentage == 0) {
      status = 'Pending';
    } else if (percentage == 100) {
      status = 'Successful';
    }

    return status;
  }

  static List<JobItemModel> getJobsListByServiceInvoice(
      {required List<JobItemModel> allJobsList,
      required ServiceInvoiceModel serviceInvoiceModel}) {
    List<JobItemModel> jobItemList = [];

    jobItemList.clear();
    for (var jobItemModel in allJobsList) {
      if (jobItemModel.serviceInvoiceId ==
          serviceInvoiceModel.serviceInvoiceId) {
        jobItemList.add(jobItemModel);
      }
    }

    return jobItemList;
  }

  static Future<String> generateInvoicePdf(
      ServiceInvoiceModel model,
      ServiceViewModel viewModel,
      ) async {
    num discount = 0;
    if (model.couponModel != null) {
      final couponAmt = num.tryParse(model.couponModel!.amount ?? '') ?? 0;
      discount = model.serviceInvoiceTotalAmount > couponAmt
          ? couponAmt
          : model.serviceInvoiceTotalAmount;
    }

    num totalQty = 0;
    num subTotal = 0;
    model.priceModel?.forEach((element) {
      totalQty += element.qty;
      subTotal += element.amount;
      print("total: $subTotal");
    });

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.all(12.sp),
        build: (pw.Context context) {
          final headerStyle = pw.TextStyle(fontSize: 14.sp, fontWeight: pw.FontWeight.bold);
          final labelStyle  = pw.TextStyle(fontSize: 10.sp, fontWeight: pw.FontWeight.bold);
          final valueStyle  = pw.TextStyle(fontSize: 10.sp);

          pw.TableRow buildRow(String label, String value) => pw.TableRow(children: [
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: 4.sp, horizontal: 2.sp),
              child: pw.Text(label, style: labelStyle),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: 4.sp, horizontal: 2.sp),
              child: pw.Text(value, style: valueStyle),
            ),
          ]);

          return <pw.Widget>[
            pw.Center(child: pw.Text('SERVICE INVOICE', style: headerStyle)),
            pw.SizedBox(height: 6.sp),
            pw.Divider(),

            pw.Row(children: [
              pw.Expanded(
                child: pw.Text(model.customerName,
                    style: pw.TextStyle(fontSize: 12.sp, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: '#${model.serviceInvoiceCode}',
                  width: 40.sp,
                  height: 40.sp,
                ),
                pw.SizedBox(height: 4.sp),
                pw.Text('#${model.tag} - ${model.sid.toString()}', style: pw.TextStyle(fontSize: 8.sp)),
              ]),
            ]),
            pw.SizedBox(height: 10.sp),

            pw.Table(
              border: pw.TableBorder.all(width: .5, color: PdfColors.grey300),
              columnWidths: {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(7)},
              children: [
                buildRow('Phone', model.customerPhoneNo),
                buildRow('Village', model.customerVillage),
                buildRow(
                  'Created',
                  parseDate(
                    model.serviceInvoiceCreatedAtDate.millisecondsSinceEpoch,
                    AppConstant.yMMMMd,
                  ),
                ),
                buildRow(
                  'Due Date',
                  parseDate(
                    model.serviceInvoiceDueDate.millisecondsSinceEpoch,
                    AppConstant.yMMMMd,
                  ),
                ),
                buildRow('Payment', model.serviceInvoicePaymentMode),
                buildRow('Note', model.serviceInvoiceNotes.isEmpty ? '-' : model.serviceInvoiceNotes),
              ],
            ),
            pw.SizedBox(height: 10.sp),

            pw.Table(
              border: pw.TableBorder.all(width: .5, color: PdfColors.grey300),
              columnWidths: {0: pw.FlexColumnWidth(5), 1: pw.FlexColumnWidth(5)},
              children: [
                buildRow('Total Qty', totalQty.toString()),
                buildRow('Sub Total', 'Rs. ${subTotal.toStringAsFixed(2)}'),
                buildRow('Discount', 'Rs. ${discount.toStringAsFixed(2)}'),
                buildRow('Due Payment', 'Rs. ${model.serviceInvoiceDueAmount.toStringAsFixed(2)}'),
                buildRow('Final Amount', 'Rs. ${(subTotal - discount).toStringAsFixed(2)}'),
              ],
            ),
            pw.SizedBox(height: 10.sp),

            pw.Text('JOB ITEMS', style: pw.TextStyle(fontSize: 12.sp, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),

            pw.ListView.builder(
              itemCount: viewModel.jobItemList.length,
              itemBuilder: (context, index) {
                final item = viewModel.jobItemList[index];
                final qty  = item.jobItemQty;
                final rate = qty > 0 ? item.jobItemTotalCharge / qty : 0;

                final raw = item.jobItemColor?.toString().replaceAll('#', '') ?? '';

                final hex      = (raw.length == 3 || raw.length == 6 || raw.length == 8)
                    ? raw
                    : '000000';

                return pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 4.sp),
                  padding: pw.EdgeInsets.all(6.sp),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: .5, color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(item.customerModel.name,
                            style: pw.TextStyle(fontSize: 10.sp, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            AppUtils().getServiceNameById(serviceId: item.jobItemServiceId),
                            style: pw.TextStyle(fontSize: 10.sp)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Row(children: [
                          pw.Container(
                            width: 8.sp,
                            height: 8.sp,
                            decoration: pw.BoxDecoration(color: PdfColor.fromHex(hex)),
                          ),
                          pw.SizedBox(width: 4.sp),
                          pw.Text(item.colorName ?? '-',
                              style: pw.TextStyle(fontSize: 10.sp)),
                        ]),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            parseDate(item.jobItemCreatedAtDate, AppConstant.dd_mm_yyyy),
                            style: pw.TextStyle(fontSize: 10.sp)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('$qty × ${rate.toStringAsFixed(2)}',
                            style: pw.TextStyle(fontSize: 10.sp)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Rs. ${item.jobItemTotalCharge.toStringAsFixed(2)}',
                            style: pw.TextStyle(fontSize: 10.sp)),
                      ),
                      pw.Container(
                        width: 24.sp,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: '#${item.jobItemCode}',
                          width: 24.sp,
                          height: 24.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ];
        },
      ),
    );
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String outputPath = '$dir/service_invoice.pdf';
    final File file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return outputPath;
  }


  static Future<String> generateInvoicePdfJobItem(JobItemModel model) async {
    // helper to build a table row
    pw.TableRow _buildRow(String label, String value) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      );
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) => [
          // Title
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),

          // Customer Details
          pw.Text(
            'Customer Details',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(7),
            },
            children: [
              _buildRow('Name', model.customerModel.name),
              _buildRow('Phone', model.customerModel.phone),
              _buildRow('Village', model.customerModel.village),
            ],
          ),
          pw.SizedBox(height: 8),

          // Job Details
          pw.Text(
            'Job Details',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(7),
            },
            children: [
              _buildRow(
                'Service',
                AppUtils().getServiceNameById(serviceId: model.jobItemServiceId),
              ),
              _buildRow('Color', model.colorName ?? '—'),
              _buildRow('Qty', model.jobItemQty.toString()),
              _buildRow(
                'Rate',
                '₹${(model.jobItemTotalCharge / model.jobItemQty).toStringAsFixed(2)}',
              ),
              _buildRow('Total', '₹${model.jobItemTotalCharge}'),
              _buildRow(
                'Due Date',
                parseDate(model.jobItemDueDate, AppConstant.yMMMMd),
              ),
              _buildRow(
                'Created',
                parseDate(model.jobItemCreatedAtDate, AppConstant.yMMMMd),
              ),
              _buildRow(
                'Note',
                model.jobItemNotes.isEmpty ? '-' : model.jobItemNotes,
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // QR Code
          pw.Center(
            child: pw.Column(
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: "#${model.jobItemCode}",
                  width: 60,
                  height: 60,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '#${model.jobItemCode}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // save PDF to file
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/service_invoice.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static String getTotalAppointedJobs(
      {required List<JobItemModel> allJobList, required}) {
    List<JobItemModel> inShopJobItemList = [];

    if (allJobList.isNotEmpty) {
      for (var element in allJobList) {
        if (element.jobItemPercentage == JobPercentConstant.percent0) {
          inShopJobItemList.add(element);
        }
      }
    } else {
      return '0 Job';
    }

    return '${inShopJobItemList.length} ${inShopJobItemList.length > 1 ? 'Jobs' : 'Job'}';
  }
}
