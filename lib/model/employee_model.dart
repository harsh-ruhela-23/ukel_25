import 'package:ukel/utils/constants.dart';

import 'crafsman_model.dart';

class EmployeeModel {
  String id;
  int createdAtDate;
  PersonalDetailsModel personalDetailsModel;
  BankDetailsModel bankDetailsModel;

  EmployeeModel({
    required this.id,
    required this.createdAtDate,
    required this.personalDetailsModel,
    required this.bankDetailsModel,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json[FbConstant.craftsmanId],
      createdAtDate: json[FbConstant.jobItemCreatedAtDate],
      personalDetailsModel: PersonalDetailsModel.fromJson(
          json[FbConstant.craftsmanPersonalDetails]),
      bankDetailsModel:
          BankDetailsModel.fromJson(json[FbConstant.craftsmanBankDetails]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.craftsmanId] = id;
    data[FbConstant.jobItemCreatedAtDate] = createdAtDate;
    data[FbConstant.craftsmanPersonalDetails] = personalDetailsModel.toJson();
    data[FbConstant.craftsmanBankDetails] = bankDetailsModel.toJson();
    return data;
  }
}
