import 'package:ukel/utils/constants.dart';

class CouponModel {
  String? id;
  String? code;
  String? amount;
  String? branchId;

  CouponModel({
    required this.id,
    required this.code,
    required this.amount,
    required this.branchId,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json[FbConstant.id] ?? '',
      code: json[FbConstant.couponCode] ?? '',
      amount: json[FbConstant.amount] ?? '',
      branchId: json[FbConstant.branchId] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.couponCode] = code;
    data[FbConstant.amount] = amount;
    data[FbConstant.branchId] = branchId;
    return data;
  }
}
