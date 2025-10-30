import 'package:ukel/utils/constants.dart';

import 'crafsman_model.dart';

class BranchModel {
  String? id;
  String? createdBy;
  int? createdAtDate;
  String? branchCode;
  String? tag;
  var sid = 0;
  BranchDetailsModel? branchDetailsModel;
  BankDetailsModel? bankDetailsModel;

  BranchModel({
    required this.id,
    required this.createdBy,
    required this.createdAtDate,
    required this.branchCode,
    required this.tag,
    required this.branchDetailsModel,
    required this.bankDetailsModel,
    required this.sid,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json[FbConstant.craftsmanId],
      createdBy: json[FbConstant.createdBy],
      branchCode: json[FbConstant.branchCode],
      tag: json[FbConstant.tag],
      sid: json[FbConstant.sid] ?? 0,
      createdAtDate: json[FbConstant.jobItemCreatedAtDate],
      branchDetailsModel:
          BranchDetailsModel.fromJson(json[FbConstant.branchDetails]),
      bankDetailsModel:
          BankDetailsModel.fromJson(json[FbConstant.craftsmanBankDetails]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanId] = id;
    data[FbConstant.branchCode] = branchCode;
    data[FbConstant.createdBy] = createdBy;
    data[FbConstant.tag] = tag;
    data[FbConstant.sid] = sid;
    data[FbConstant.jobItemCreatedAtDate] = createdAtDate;
    data[FbConstant.branchDetails] =
        branchDetailsModel == null ? '' : branchDetailsModel?.toJson();
    data[FbConstant.craftsmanBankDetails] =
        bankDetailsModel == null ? '' : bankDetailsModel?.toJson();
    return data;
  }
}

// BranchDetailsModel
class BranchDetailsModel {
  String phoneNumber;
  String ownerName;
  String? mobileNumber;
  String email;
  int dateOfBirth;
  String gender;
  String homeTown;
  String shopAddress;
  String ownerAddress;
  String aadhaarNo;
  String panNo;

  BranchDetailsModel({
    required this.phoneNumber,
    required this.ownerName,
    required this.mobileNumber,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.homeTown,
    required this.shopAddress,
    required this.ownerAddress,
    required this.aadhaarNo,
    required this.panNo,
  });

  factory BranchDetailsModel.fromJson(Map<String, dynamic> json) {
    return BranchDetailsModel(
      phoneNumber: json[FbConstant.craftsmanPhoneNumber],
      ownerName: json[FbConstant.ownerName],
      mobileNumber: json[FbConstant.craftsmanMobileNumber],
      email: json[FbConstant.craftsmanEmail],
      dateOfBirth: json[FbConstant.craftsmanDateOfBirth],
      gender: json[FbConstant.craftsmanGender],
      homeTown: json[FbConstant.craftsmanHomeTown],
      shopAddress: json[FbConstant.branchShopAddress],
      ownerAddress: json[FbConstant.branchOwnerAddress],
      aadhaarNo: json[FbConstant.craftsmanAadhaarNo],
      panNo: json[FbConstant.craftsmanPanNo],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanPhoneNumber] = phoneNumber;
    data[FbConstant.ownerName] = ownerName;
    data[FbConstant.craftsmanMobileNumber] = mobileNumber;
    data[FbConstant.craftsmanEmail] = email;
    data[FbConstant.craftsmanDateOfBirth] = dateOfBirth;
    data[FbConstant.craftsmanGender] = gender;
    data[FbConstant.craftsmanHomeTown] = homeTown;
    data[FbConstant.branchShopAddress] = shopAddress;
    data[FbConstant.branchOwnerAddress] = ownerAddress;
    data[FbConstant.craftsmanAadhaarNo] = aadhaarNo;
    data[FbConstant.craftsmanPanNo] = panNo;
    return data;
  }
}
