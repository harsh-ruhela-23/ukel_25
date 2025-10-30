import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukel/model/coupon_model.dart';
import 'package:ukel/utils/constants.dart';

class ServiceInvoiceModel {
  String branchId;
  String serviceInvoiceId;
  String serviceInvoiceCustomerId;
  String serviceInvoiceCode;
  String serviceInvoiceNotes;
  Timestamp serviceInvoiceDueDate;
  Timestamp serviceInvoiceCreatedAtDate;
  num serviceInvoiceTotalQty;
  num serviceInvoiceTotalAmount;
  num serviceInvoiceReceivedAmount;
  num serviceInvoiceDueAmount;
  String serviceInvoicePaymentMode;
  String customerPhoneNo;
  String customerName;
  String customerVillage;
  String tag;
  String sid = "";
  List<String> jobIdsList;
  List<ServiceInvoicePriceModel>? priceModel;
  num serviceInvoiceStatusValue;
  CouponModel? couponModel;

  ServiceInvoiceModel({
    required this.serviceInvoiceId,
    required this.branchId,
    required this.serviceInvoiceCustomerId,
    required this.serviceInvoiceCode,
    required this.serviceInvoiceNotes,
    required this.serviceInvoiceDueDate,
    required this.serviceInvoiceTotalQty,
    required this.serviceInvoiceTotalAmount,
    required this.serviceInvoiceCreatedAtDate,
    required this.serviceInvoiceDueAmount,
    required this.serviceInvoiceReceivedAmount,
    required this.serviceInvoicePaymentMode,
    required this.customerName,
    required this.customerPhoneNo,
    required this.customerVillage,
    required this.jobIdsList,
    required this.serviceInvoiceStatusValue,
    required this.tag,
    required this.sid,
    required this.couponModel,
    this.priceModel,
  });

  factory ServiceInvoiceModel.fromJson(Map<String, dynamic> json) {
    List<ServiceInvoicePriceModel> priceData = [];
    if (json[FbConstant.serviceInvoicePriceInfo] != null) {
      json[FbConstant.serviceInvoicePriceInfo].forEach((v) {
        priceData.add(ServiceInvoicePriceModel.fromJson(v));
      });
    }

    return ServiceInvoiceModel(
      serviceInvoiceId: json[FbConstant.serviceInvoiceId]!,
      branchId: json[FbConstant.branchId]!,
      serviceInvoiceCustomerId: json[FbConstant.serviceInvoiceCustomerId] ?? '',
      serviceInvoiceCode: json[FbConstant.serviceInvoiceCode]!,
      serviceInvoiceNotes: json[FbConstant.serviceInvoiceNotes] ?? '',
      serviceInvoiceTotalQty: json[FbConstant.serviceInvoiceTotalQty] ?? 0,
      serviceInvoiceTotalAmount:
          json[FbConstant.serviceInvoiceTotalAmount] ?? 0,
      serviceInvoiceDueDate: json[FbConstant.serviceInvoiceDueDate],
      serviceInvoiceCreatedAtDate: json[FbConstant.serviceInvoiceCreatedAtDate],
      serviceInvoiceDueAmount: json[FbConstant.serviceInvoiceDueAmount] ?? 0,
      serviceInvoiceReceivedAmount:
          json[FbConstant.serviceInvoiceReceivedAmount] ?? 0,
      serviceInvoicePaymentMode:
          json[FbConstant.serviceInvoicePaymentMode] ?? '',
      customerName: json[FbConstant.serviceInvoiceCustomerName] ?? '',
      customerPhoneNo: json[FbConstant.serviceInvoiceCustomerPhNo] ?? '',
      customerVillage: json[FbConstant.serviceInvoiceCustomerVillage] ?? '',
      serviceInvoiceStatusValue:
          json[FbConstant.serviceInvoiceStatusValue] ?? '',
      jobIdsList: (json[FbConstant.serviceInvoiceJobIds] as List)
          .map((e) => e.toString())
          .toList(),
      couponModel: json[FbConstant.coupon] != null
          ? CouponModel.fromJson(json[FbConstant.coupon])
          : null,
      priceModel: priceData,
      tag: json[FbConstant.tag],
      sid: json[FbConstant.sid] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.serviceInvoiceId] = serviceInvoiceId;
    data[FbConstant.branchId] = branchId;
    data[FbConstant.serviceInvoiceCustomerId] = serviceInvoiceCustomerId;
    data[FbConstant.serviceInvoiceCode] = serviceInvoiceCode;
    data[FbConstant.serviceInvoiceNotes] = serviceInvoiceNotes;
    data[FbConstant.serviceInvoiceTotalQty] = serviceInvoiceTotalQty;
    data[FbConstant.serviceInvoiceTotalAmount] = serviceInvoiceTotalAmount;
    data[FbConstant.serviceInvoiceDueDate] = serviceInvoiceDueDate;
    data[FbConstant.serviceInvoiceCreatedAtDate] = serviceInvoiceCreatedAtDate;
    data[FbConstant.serviceInvoiceDueAmount] = serviceInvoiceDueAmount;
    data[FbConstant.serviceInvoiceReceivedAmount] =
        serviceInvoiceReceivedAmount;
    data[FbConstant.serviceInvoicePaymentMode] = serviceInvoicePaymentMode;
    data[FbConstant.serviceInvoiceCustomerName] = customerName;
    data[FbConstant.serviceInvoiceCustomerPhNo] = customerPhoneNo;
    data[FbConstant.serviceInvoiceCustomerVillage] = customerVillage;
    data[FbConstant.serviceInvoiceJobIds] = jobIdsList;
    data[FbConstant.serviceInvoiceStatusValue] = serviceInvoiceStatusValue;
    data[FbConstant.tag] = tag;
    data[FbConstant.sid] = sid;
    if (couponModel != null) {
      data[FbConstant.coupon] = couponModel?.toJson();
    }
    if (priceModel != null) {
      data[FbConstant.serviceInvoicePriceInfo] =
          priceModel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceInvoicePriceModel {
  String? jobId;
  num qty;
  num amount;

  ServiceInvoicePriceModel({
    required this.qty,
    required this.amount,
    this.jobId,
  });

  factory ServiceInvoicePriceModel.fromJson(Map<String, dynamic> json) {
    return ServiceInvoicePriceModel(
      jobId: json[FbConstant.jobId] ?? "",
      qty: json[FbConstant.serviceInvoiceQty]!,
      amount: json[FbConstant.serviceInvoiceAmount]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.serviceInvoiceQty] = qty;
    data[FbConstant.serviceInvoiceAmount] = amount;
    data[FbConstant.jobId] = jobId;
    return data;
  }
}
