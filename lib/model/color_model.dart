import 'package:ukel/utils/constants.dart';

class CustomColorModel {
  String? id;
  String? colorCode;
  String? name;
  String? branchId;

  CustomColorModel({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.branchId,
  });

  factory CustomColorModel.fromJson(Map<String, dynamic> json) {
    return CustomColorModel(
      id: json[FbConstant.id],
      name: json[FbConstant.name],
      colorCode: json[FbConstant.code],
      branchId: json[FbConstant.branchId],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.name] = name;
    data[FbConstant.code] = colorCode;
    data[FbConstant.branchId] = branchId;
    return data;
  }
}
