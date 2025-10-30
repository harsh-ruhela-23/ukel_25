import 'package:ukel/utils/constants.dart';

class CraftsmanModel {
  String id;
  String? branchId;
  int createdAtDate;
  num appointed;
  num running;
  num done;
  num qtPassed;
  List<String> inJobIdsList;
  List<String> outJobIdsList;
  PersonalDetailsModel personalDetailsModel;
  BankDetailsModel bankDetailsModel;
  ServiceInfoModel serviceInfoModel;

  CraftsmanModel({
    required this.id,
    this.branchId,
    required this.createdAtDate,
    required this.appointed,
    required this.running,
    required this.done,
    required this.qtPassed,
    required this.personalDetailsModel,
    required this.bankDetailsModel,
    required this.serviceInfoModel,
    required this.inJobIdsList,
    required this.outJobIdsList,
  });

  factory CraftsmanModel.fromJson(Map<String, dynamic> json) {
    return CraftsmanModel(
      id: json[FbConstant.craftsmanId],
      branchId: json[FbConstant.branchId],
      createdAtDate: json[FbConstant.jobItemCreatedAtDate],
      appointed: json[FbConstant.appointed],
      running: json[FbConstant.running],
      done: json[FbConstant.done],
      qtPassed: json[FbConstant.qtPassed],
      personalDetailsModel: PersonalDetailsModel.fromJson(
          json[FbConstant.craftsmanPersonalDetails]),
      bankDetailsModel:
          BankDetailsModel.fromJson(json[FbConstant.craftsmanBankDetails]),
      serviceInfoModel:
          ServiceInfoModel.fromJson(json[FbConstant.craftsmanServiceInfo]),
      inJobIdsList: (json[FbConstant.craftsmanIn] as List)
          .map((e) => e.toString())
          .toList(),
      outJobIdsList: (json[FbConstant.craftsmanOut] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanId] = id;
    data[FbConstant.branchId] = branchId;
    data[FbConstant.jobItemCreatedAtDate] = createdAtDate;
    data[FbConstant.appointed] = appointed;
    data[FbConstant.running] = running;
    data[FbConstant.done] = done;
    data[FbConstant.qtPassed] = qtPassed;
    data[FbConstant.craftsmanPersonalDetails] = personalDetailsModel.toJson();
    data[FbConstant.craftsmanBankDetails] = bankDetailsModel.toJson();
    data[FbConstant.craftsmanServiceInfo] = serviceInfoModel.toJson();
    data[FbConstant.craftsmanIn] = inJobIdsList;
    data[FbConstant.craftsmanOut] = outJobIdsList;
    return data;
  }
}

// PersonalDetailsModel
class PersonalDetailsModel {
  String phoneNumber;
  String name;
  String? mobileNumber;
  String email;
  int dateOfBirth;
  String gender;
  String homeTown;
  String workingLocation;
  String address;
  String aadhaarNo;
  String panNo;

  PersonalDetailsModel({
    required this.phoneNumber,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.homeTown,
    required this.workingLocation,
    required this.address,
    required this.aadhaarNo,
    required this.panNo,
  });

  factory PersonalDetailsModel.fromJson(Map<String, dynamic> json) {
    return PersonalDetailsModel(
      phoneNumber: json[FbConstant.craftsmanPhoneNumber],
      name: json[FbConstant.craftsmanName],
      mobileNumber: json[FbConstant.craftsmanMobileNumber],
      email: json[FbConstant.craftsmanEmail],
      dateOfBirth: json[FbConstant.craftsmanDateOfBirth],
      gender: json[FbConstant.craftsmanGender],
      homeTown: json[FbConstant.craftsmanHomeTown],
      workingLocation: json[FbConstant.craftsmanHomeTown],
      address: json[FbConstant.craftsmanAddress],
      aadhaarNo: json[FbConstant.craftsmanAadhaarNo],
      panNo: json[FbConstant.craftsmanPanNo],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanPhoneNumber] = phoneNumber;
    data[FbConstant.craftsmanName] = name;
    data[FbConstant.craftsmanMobileNumber] = mobileNumber;
    data[FbConstant.craftsmanEmail] = email;
    data[FbConstant.craftsmanDateOfBirth] = dateOfBirth;
    data[FbConstant.craftsmanGender] = gender;
    data[FbConstant.craftsmanHomeTown] = homeTown;
    data[FbConstant.craftsmanWorkingLocation] = workingLocation;
    data[FbConstant.craftsmanAddress] = address;
    data[FbConstant.craftsmanAadhaarNo] = aadhaarNo;
    data[FbConstant.craftsmanPanNo] = panNo;
    return data;
  }
}

// BankDetailsModel
class BankDetailsModel {
  String bankName;
  String branch;
  String accountNo;
  String ifscCode;
  String accountHolderName;

  BankDetailsModel({
    required this.bankName,
    required this.branch,
    required this.accountNo,
    required this.ifscCode,
    required this.accountHolderName,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      bankName: json[FbConstant.craftsmanBankName],
      branch: json[FbConstant.craftsmanBranch],
      accountNo: json[FbConstant.craftsmanAccountNo],
      ifscCode: json[FbConstant.craftsmanIFSCCode],
      accountHolderName: json[FbConstant.craftsmanAccountHolderName],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanBankName] = bankName;
    data[FbConstant.craftsmanBranch] = branch;
    data[FbConstant.craftsmanAccountNo] = accountNo;
    data[FbConstant.craftsmanIFSCCode] = ifscCode;
    data[FbConstant.craftsmanAccountHolderName] = accountHolderName;
    return data;
  }
}

// ServiceInfoModel
class ServiceInfoModel {
  num workCapacity;
  String serviceType;
  String connectedBranch;
  String workingLocation;
  num serviceCharges;
  List<String>? selectedServiceNames;
  List<String>? selectedServicePrice;
  List<String>? selectedServiceCapacity;

  ServiceInfoModel({
    required this.workCapacity,
    required this.serviceType,
    required this.connectedBranch,
    required this.workingLocation,
    required this.serviceCharges,
    this.selectedServiceNames,
    this.selectedServicePrice,
    this.selectedServiceCapacity,
  });

  factory ServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return ServiceInfoModel(
      workCapacity: json[FbConstant.craftsmanWorkingCapacity],
      serviceType: json[FbConstant.craftsmanServiceType],
      connectedBranch: json[FbConstant.craftsmanConnectedBranch],
      workingLocation: json[FbConstant.craftsmanServiceWorkingLocation],
      serviceCharges: json[FbConstant.craftsmanServiceCharges],
      selectedServiceNames: List<String>.from(json['selectedServiceNames'] ?? []), 
      selectedServicePrice: List<String>.from(json['selectedServicePrice'] ?? []),
      selectedServiceCapacity: List<String>.from(json['selectedServiceCapacity'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanWorkingCapacity] = workCapacity;
    data[FbConstant.craftsmanServiceType] = serviceType;
    data[FbConstant.craftsmanConnectedBranch] = connectedBranch;
    data[FbConstant.craftsmanServiceWorkingLocation] = workingLocation;
    data[FbConstant.craftsmanServiceCharges] = serviceCharges;
    data['selectedServiceNames'] = selectedServiceNames ?? [];
    data['selectedServicePrice'] = selectedServicePrice ?? [];
    data['selectedServiceCapacity'] = selectedServiceCapacity ?? [];
    return data;
  }
}
