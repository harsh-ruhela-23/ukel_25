import 'package:ukel/model/customer_model.dart';
import 'package:ukel/utils/constants.dart';

class JobItemModel {
  String jobId;
  String branchId;
  CustomerModel customerModel;
  String jobItemCode;
  String jobItemNotes;
  String jobItemImageUrl;
  String jobItemServiceId;
  List<MemberServiceValueData>? jobItemServiceValue;

  // Timestamp jobItemDueDate;
  int jobItemDueDate;
  int jobItemCreatedAtDate;
  int jobItemColor;
  num jobItemQty;
  num jobItemTotalCharge;
  String serviceInvoiceId;
  JobItemStatusObj? jobStatusObj;
  String selectedCraftsmanId;
  String selectedCraftsmanName;
  String jobItemPercentage;
  String? colorName;
  List<AddJobTimeLineModel>? timelineStatusObj;

  JobItemModel({
    required this.jobId,
    required this.branchId,
    required this.customerModel,
    required this.jobItemCode,
    required this.jobItemNotes,
    required this.jobItemImageUrl,
    required this.jobItemServiceId,
    required this.jobItemDueDate,
    required this.jobItemColor,
    required this.jobItemQty,
    required this.jobItemTotalCharge,
    required this.jobItemCreatedAtDate,
    this.jobItemServiceValue,
    this.timelineStatusObj,
    required this.serviceInvoiceId,
    this.jobStatusObj,
    required this.jobItemPercentage,
    required this.selectedCraftsmanId,
    required this.selectedCraftsmanName,
    required this.colorName,
  });

  factory JobItemModel.fromJson(Map<String, dynamic> json) {
    List<MemberServiceValueData> data = [];
    if (json[FbConstant.jobItemServiceValues] != null) {
      json[FbConstant.jobItemServiceValues].forEach((v) {
        data.add(MemberServiceValueData.fromJson(v));
      });
    }
    List<AddJobTimeLineModel> timeLineData = [];
    if (json[FbConstant.timelineStatusObj] != null) {
      json[FbConstant.timelineStatusObj].forEach((v) {
        timeLineData.add(AddJobTimeLineModel.fromJson(v));
      });
    }
    JobItemStatusObj? jStatus;
    if (json[FbConstant.jobStatusObj] != null) {
      jStatus = JobItemStatusObj.fromJson(json[FbConstant.jobStatusObj]);
    }

    return JobItemModel(
      branchId: json[FbConstant.branchId]!,
      jobId: json[FbConstant.jobId]!,
      customerModel: CustomerModel.fromJson(json[FbConstant.customer]),
      jobItemCode: json[FbConstant.jobItemCode]!,
      jobItemNotes: json[FbConstant.jobItemNotes]!,
      jobItemImageUrl: json[FbConstant.jobItemImageUrl]!,
      jobItemServiceId: json[FbConstant.jobItemServiceId]!,
      jobItemColor: json[FbConstant.jobItemColor]!,
      jobItemQty: json[FbConstant.jobItemQty]!,
      jobItemTotalCharge: json[FbConstant.jobItemTotalCharge]!,
      jobItemDueDate: json[FbConstant.jobItemDueDate]!,
      jobItemCreatedAtDate: json[FbConstant.jobItemCreatedAtDate]!,
      serviceInvoiceId: json[FbConstant.jobServiceInvoiceId]!,
      jobItemServiceValue: data,
      timelineStatusObj: timeLineData,
      jobStatusObj: jStatus,
      jobItemPercentage: json[FbConstant.jobItemPercentage]!,
      selectedCraftsmanId: json[FbConstant.jobItemSelectedCraftsmanId]!,
      selectedCraftsmanName: json[FbConstant.jobItemSelectedCraftsmanName]!,
      colorName: json[FbConstant.jobItemColorName]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.jobId] = jobId;
    data[FbConstant.branchId] = branchId;
    data[FbConstant.customer] = customerModel.toJson();
    data[FbConstant.jobItemCode] = jobItemCode;
    data[FbConstant.jobItemNotes] = jobItemNotes;
    data[FbConstant.jobItemImageUrl] = jobItemImageUrl;
    data[FbConstant.jobItemServiceId] = jobItemServiceId;
    data[FbConstant.jobItemColor] = jobItemColor;
    data[FbConstant.jobItemQty] = jobItemQty;
    data[FbConstant.jobItemTotalCharge] = jobItemTotalCharge;
    data[FbConstant.jobItemDueDate] = jobItemDueDate;
    data[FbConstant.jobItemCreatedAtDate] = jobItemCreatedAtDate;
    data[FbConstant.jobServiceInvoiceId] = serviceInvoiceId;
    data[FbConstant.jobStatusObj] = jobStatusObj?.toJson();
    data[FbConstant.jobItemPercentage] = jobItemPercentage;
    data[FbConstant.jobItemSelectedCraftsmanId] = selectedCraftsmanId;
    data[FbConstant.jobItemSelectedCraftsmanName] = selectedCraftsmanName;
    data[FbConstant.jobItemColorName] = colorName;
    if (jobStatusObj != null) {
      data[FbConstant.jobStatusObj] = jobStatusObj!.toJson();
    }
    if (jobItemServiceValue != null) {
      data[FbConstant.jobItemServiceValues] =
          jobItemServiceValue!.map((v) => v.toJson()).toList();
    }
    if (timelineStatusObj != null) {
      data[FbConstant.timelineStatusObj] =
          timelineStatusObj!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class JobItemServiceValue {
  String id;
  String value;

  JobItemServiceValue({
    required this.id,
    required this.value,
  });

  factory JobItemServiceValue.fromJson(Map<String, dynamic> json) {
    return JobItemServiceValue(
      id: json[FbConstant.id]!,
      value: json[FbConstant.value]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, String> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.value] = value;
    return data;
  }
}

class JobItemStatusObj {
  int rejectCount;
  List<String> rejectReason;

  JobItemStatusObj({
    required this.rejectCount,
    required this.rejectReason,
  });

  factory JobItemStatusObj.fromJson(Map<String, dynamic> json) {
    List<String> reasons = [];
    if (json[FbConstant.rejectReason] != null) {
      reasons = json[FbConstant.rejectReason].cast<String>();
    }
    return JobItemStatusObj(
      rejectCount: json[FbConstant.rejectCount]!,
      rejectReason: reasons,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.rejectCount] = rejectCount;
    data[FbConstant.rejectReason] = rejectReason;
    return data;
  }
}

class AddJobTimeLineModel {
  String statusPer;
  String title;
  String? subTitle;
  int bgColor;
  int indicatorColor;
  bool isComplete;
  bool isReject;
  bool isLast;
  bool isFirst;
  int? completedDate;
  int rejectCount;

  AddJobTimeLineModel({
    required this.statusPer,
    required this.title,
    this.subTitle,
    required this.bgColor,
    required this.indicatorColor,
    required this.isComplete,
    required this.isReject,
    required this.isLast,
    required this.isFirst,
    required this.rejectCount,
    this.completedDate,
  });

  factory AddJobTimeLineModel.fromJson(Map<String, dynamic> json) {
    return AddJobTimeLineModel(
      statusPer: json[FbConstant.timelineStatusPer]!,
      title: json[FbConstant.timelineTitle]!,
      subTitle: json[FbConstant.timelineSubTitle],
      bgColor: json[FbConstant.timelineBgColor]!,
      indicatorColor: json[FbConstant.timelineIndicatorColor]!,
      isComplete: json[FbConstant.timelineIsComplete]!,
      isReject: json[FbConstant.timelineIsReject]!,
      isLast: json[FbConstant.timelineIsLast]!,
      isFirst: json[FbConstant.timelineIsFirst]!,
      completedDate: json[FbConstant.timelineCompleteDate],
      rejectCount: json[FbConstant.timelineRejectCount],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.timelineStatusPer] = statusPer;
    data[FbConstant.timelineTitle] = title;
    data[FbConstant.timelineSubTitle] = subTitle;
    data[FbConstant.timelineBgColor] = bgColor;
    data[FbConstant.timelineIndicatorColor] = indicatorColor;
    data[FbConstant.timelineIsComplete] = isComplete;
    data[FbConstant.timelineIsReject] = isReject;
    data[FbConstant.timelineIsLast] = isLast;
    data[FbConstant.timelineIsFirst] = isFirst;
    data[FbConstant.timelineCompleteDate] = completedDate;
    data[FbConstant.timelineRejectCount] = rejectCount;
    return data;
  }
}
