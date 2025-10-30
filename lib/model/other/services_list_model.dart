import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/constants.dart';

class ServicesListModel {
  final String id;
  final String name;
  final num charges;
  final List<String>? serviceTypeModelList;
  final List<ServiceType>? serviceTypeDetails;
  String? price;
  String? capacity;

  ServicesListModel({
    required this.id,
    required this.name,
    required this.charges,
    this.price,
    this.capacity,
    this.serviceTypeModelList,
    this.serviceTypeDetails,
  });

  factory ServicesListModel.fromJson(Map<String, dynamic> json) {
    List<String>? typeIds;
    List<ServiceType>? inlineTypes;
    final dynamic typeJson = json[FbConstant.serviceTypeModelList];
    if (typeJson is List) {
      final List<String> fetchedTypeIds = [];
      final List<ServiceType> fetchedInlineTypes = [];

      for (final dynamic entry in typeJson) {
        if (entry is DocumentReference) {
          fetchedTypeIds.add(entry.id);
          continue;
        }

        if (entry is String) {
          if (entry.isNotEmpty) {
            fetchedTypeIds.add(entry);
          }
          continue;
        }

        if (entry is Map) {
          final Map<String, dynamic> map =
              Map<String, dynamic>.from(entry as Map<dynamic, dynamic>);

          final String? typeValue = map[FbConstant.type] as String?;
          if (typeValue == null || typeValue.isEmpty) {
            continue;
          }

          String? inlineId;
          final dynamic rawId = map[FbConstant.id];
          if (rawId is String && rawId.isNotEmpty) {
            inlineId = rawId.trim();
            if (inlineId.toLowerCase() == 'null') {
              inlineId = null;
            }
          } else if (rawId is num) {
            inlineId = rawId.toString();
          }

          if (inlineId == null || inlineId.isEmpty) {
            inlineId = '${json[FbConstant.id] ?? ''}_${fetchedInlineTypes.length}';
          }
          map[FbConstant.id] = inlineId;

          try {
            fetchedInlineTypes.add(ServiceType.fromJson(map));
          } catch (_) {
            // Ignore malformed inline types
          }
          continue;
        }
      }

      if (fetchedTypeIds.isNotEmpty) {
        typeIds = fetchedTypeIds;
      }
      if (fetchedInlineTypes.isNotEmpty) {
        inlineTypes = fetchedInlineTypes;
      }
    }

    return ServicesListModel(
      id: json[FbConstant.id]!,
      name: json[FbConstant.name]!,
      charges: json[FbConstant.serviceCharges]!,
      price: json['price']?.toString(),
      capacity: json['capacity']?.toString(),
      serviceTypeModelList: typeIds,
      serviceTypeDetails: inlineTypes,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.name] = name;
    data[FbConstant.serviceCharges] = charges;
    data['price'] = price;
    data['capacity'] = capacity;
    if ((serviceTypeModelList?.isNotEmpty ?? false) ||
        (serviceTypeDetails?.isNotEmpty ?? false)) {
      final List<dynamic> serializedTypes = [];
      if (serviceTypeModelList != null) {
        serializedTypes.addAll(serviceTypeModelList!);
      }
      if (serviceTypeDetails != null) {
        serializedTypes
            .addAll(serviceTypeDetails!.map((type) => type.toJson()));
      }
      data[FbConstant.serviceTypeModelList] = serializedTypes;
    } else {
      data[FbConstant.serviceTypeModelList] = serviceTypeModelList;
    }
    return data;
  }
}

class ServiceType {
  String id;
  String? name;
  String type;
  String? unit;
  List<ServiceOptionModel>? option;
  ServiceValidatorModel? validator;
  String? value;

  ServiceType({
    required this.id,
    this.name,
    required this.type,
    this.value,
    this.unit,
    this.option,
    this.validator,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    List<ServiceOptionModel> data = [];
    if (json[FbConstant.option] != null) {
      json[FbConstant.option].forEach((v) {
        data.add(ServiceOptionModel.fromJson(v));
      });
    }
    ServiceValidatorModel? validatorData;
    if (json[FbConstant.validator] != null) {
      validatorData =
          ServiceValidatorModel.fromJson(json[FbConstant.validator]);
    }
    return ServiceType(
      id: json[FbConstant.id]!,
      name: json[FbConstant.name],
      type: json[FbConstant.type]!,
      unit: json[FbConstant.unit],
      value: json[FbConstant.value],
      option: data,
      validator: validatorData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.id] = id;
    data[FbConstant.name] = name;
    data[FbConstant.type] = type;
    data[FbConstant.unit] = unit;
    data[FbConstant.value] = value;
    data[FbConstant.option] = option;
    data[FbConstant.validator] = validator;
    return data;
  }
}

class ServiceOptionModel {
  final num charges;
  final String label;
  final String name;

  ServiceOptionModel({
    required this.charges,
    required this.label,
    required this.name,
  });

  factory ServiceOptionModel.fromJson(Map<String, dynamic> json) {
    return ServiceOptionModel(
      charges: json[FbConstant.serviceCharges]!,
      name: json[FbConstant.name]!,
      label: json[FbConstant.label]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.serviceCharges] = charges;
    data[FbConstant.name] = name;
    data[FbConstant.label] = label;
    return data;
  }
}

class ServiceValidatorModel {
  final String maxValue;
  final String minValue;

  ServiceValidatorModel({
    required this.maxValue,
    required this.minValue,
  });

  factory ServiceValidatorModel.fromJson(Map<String, dynamic> json) {
    return ServiceValidatorModel(
      maxValue: json[FbConstant.maxValue],
      minValue: json[FbConstant.minValue],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[FbConstant.serviceCharges] = maxValue;
    data[FbConstant.name] = minValue;
    return data;
  }
}
