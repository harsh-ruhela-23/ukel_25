import 'package:ukel/utils/constants.dart';

class CustomerModel {
  String id;
  String? branchId;
  String name;
  String? nameForSearch;
  String phone;
  String village;
  List<MembersModel>? membersData;

  CustomerModel({
    required this.id,
    this.branchId,
    required this.phone,
    required this.name,
    this.nameForSearch,
    this.membersData,
    required this.village,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    List<MembersModel> membersList = [];
    if (json[FbConstant.membersData] != null) {
      json[FbConstant.membersData].forEach((v) {
        membersList.add(MembersModel.fromJson(v));
      });
    }
    return CustomerModel(
      id: json[FbConstant.id]!,
      branchId: json[FbConstant.branchId],
      name: json[FbConstant.name]!,
      nameForSearch: json[FbConstant.nameForSearch]!,
      phone: json[FbConstant.phone]!,
      village: json[FbConstant.village]!,
      membersData: membersList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.name] = name;
    data[FbConstant.nameForSearch] = nameForSearch;
    data[FbConstant.id] = id;
    data[FbConstant.branchId] = branchId;
    data[FbConstant.phone] = phone;
    data[FbConstant.village] = village;
    if (membersData != null) {
      data[FbConstant.membersData] =
          membersData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MembersModel {
  String? name;
  List<MemberServiceData>? serviceData;

  MembersModel({
    this.name,
    this.serviceData,
  });

  factory MembersModel.fromJson(Map<String, dynamic> json) {
    List<MemberServiceData> serviceData = [];
    if (json[FbConstant.serviceData] != null) {
      json[FbConstant.serviceData].forEach((v) {
        serviceData.add(MemberServiceData.fromJson(v));
      });
    }
    return MembersModel(
      name: json[FbConstant.name],
      serviceData: serviceData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.name] = name;
    if (serviceData != null) {
      data[FbConstant.serviceData] =
          serviceData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberServiceData {
  String? serviceId;
  List<MemberServiceValueData>? value;

  MemberServiceData({
    required this.serviceId,
    this.value,
  });

  factory MemberServiceData.fromJson(Map<String, dynamic> json) {
    List<MemberServiceValueData> serviceValue = [];
    if (json[FbConstant.value] != null) {
      json[FbConstant.value].forEach((v) {
        serviceValue.add(MemberServiceValueData.fromJson(v));
      });
    }
    return MemberServiceData(
      serviceId: json[FbConstant.serviceId],
      value: serviceValue,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.serviceId] = serviceId;
    if (value != null) {
      data[FbConstant.value] =
          value!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberServiceValueData {
  String? id;
  String? value;

  MemberServiceValueData({
    required this.id,
    this.value,
  });

  factory MemberServiceValueData.fromJson(Map<String, dynamic> json) {
    return MemberServiceValueData(
      id: json[FbConstant.id],
      value: json[FbConstant.value],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.value] = value;
    return data;
  }
}