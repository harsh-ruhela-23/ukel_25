import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/utils/constants.dart';

import '../../../../services/authentication_service.dart';
import '../../../../services/get_storage.dart';

class ServiceInvoiceRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> createCustomer(Map<String, dynamic> customerDetails) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.customer)
          .doc(customerDetails[FbConstant.id])
          .set(customerDetails);

      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  // fetchCustomers
  Future<List<CustomerModel>> fetchCustomers({String? branchId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;
      if (branchId != null) {
        querySnapshot = await _firebaseFirestore
            .collection(FbConstant.customer)
            .where(FbConstant.branchId, isEqualTo: branchId)
            .get();
      } else {
        querySnapshot =
            await _firebaseFirestore.collection(FbConstant.customer).get();
      }

      List<CustomerModel> customerModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CustomerModel.fromJson(item.data());
          customerModelList.add(model);
        }
      }
      return customerModelList;
    } catch (e) {
      print("errorr===$e");
      throw e.toString();
    }
  }

  bool isStringNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }

  late QuerySnapshot<Map<String, dynamic>> queryAllSnapshot;

  Future<Map<String, dynamic>> searchCustomers(String query,bool isQueryAllSnapshotAssigned) async {
    List<CustomerModel> customerModelList = [];
    try {
      var branchId = Storage.getValue(FbConstant.branchId);

      if (!isQueryAllSnapshotAssigned) {
        // not yet assigned → fetch
        if (query.trim().isEmpty) {
          queryAllSnapshot = await _firebaseFirestore
              .collection(FbConstant.customer)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .get();
        } else if (isStringNumeric(query)) {
          queryAllSnapshot = await _firebaseFirestore
              .collection(FbConstant.customer)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .where(FbConstant.phone, isGreaterThanOrEqualTo: query)
              .where(FbConstant.phone, isLessThan: '${query}z')
              .get();
        } else {
          queryAllSnapshot = await _firebaseFirestore
              .collection(FbConstant.customer)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .where(FbConstant.nameForSearch, isGreaterThanOrEqualTo: query)
              .where(FbConstant.nameForSearch, isLessThan: '${query}z')
              .get();
        }
        for (var item in queryAllSnapshot.docs) {
          if (item.exists) {
            final model = CustomerModel.fromJson(item.data());
            customerModelList.add(model);
          }
        }
      } else {
        for (var item in queryAllSnapshot.docs) {
          if (item.exists) {
            final model = CustomerModel.fromJson(item.data());
            if (model.name.toLowerCase().startsWith(query.toLowerCase()) ||
                model.phone.startsWith(query)) {
              customerModelList.add(model);
            }
          }
        }
      }

      // now use queryAllSnapshot directly

      return {
        FbConstant.customer: customerModelList,
      };
    } catch (e) {
      return {
        FbConstant.customer: [],
      };
    }
  }

  // fetchServices
  Future<Map<String, dynamic>> fetchServices() async {
    try {
      final querySnapshot =
          await _firebaseFirestore.collection(FbConstant.service)
              .where('branch_id', isEqualTo: Storage.getValue(FbConstant.uid))
              .get();

      List<ServicesListModel> servicesModelList = [];

      for (var item in querySnapshot.docs) {
        final model = ServicesListModel.fromJson(item.data());
        servicesModelList.add(model);
      }

      Map<String, dynamic> result = {
        FbConstant.service: servicesModelList,
      };

      return result;
    } catch (e) {
      return {
        FbConstant.service: [],
      };
    }
  }

  // fetchServicesType
  Future<Map<String, dynamic>> fetchServicesType(String id) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.serviceType)
          .where(FbConstant.id, isEqualTo: id)
          .get();

      ServiceType? serviceType;

      for (var item in querySnapshot.docs) {
        final model = ServiceType.fromJson(item.data());
        serviceType = model;
      }

      Map<String, dynamic> result = {
        FbConstant.serviceType: serviceType,
      };

      return result;
    } catch (e) {
      return {
        FbConstant.serviceType: null,
      };
    }
  }

  Future<List<ServiceType>> resolveServiceTypes(
      ServicesListModel service) async {
    final List<ServiceType> resolvedTypes = [];
    final Set<String> addedIds = {};

    if (service.serviceTypeModelList != null) {
      for (final id in service.serviceTypeModelList!) {
        if (id.isEmpty) {
          continue;
        }
        final Map<String, dynamic> result = await fetchServicesType(id);
        final ServiceType? serviceType = result[FbConstant.serviceType];
        if (serviceType != null) {
          resolvedTypes.add(serviceType);
          addedIds.add(serviceType.id);
        }
      }
    }

    final List<ServiceType>? inlineTypes = service.serviceTypeDetails;
    if (inlineTypes != null && inlineTypes.isNotEmpty) {
      for (int index = 0; index < inlineTypes.length; index++) {
        final ServiceType inlineType = inlineTypes[index];
        String inlineId = inlineType.id.trim();

        if (inlineId.isEmpty || inlineId.toLowerCase() == 'null' ||
            addedIds.contains(inlineId)) {
          inlineId =
              '${service.id}_${index}_${inlineType.name ?? inlineType.type}';
        }

        resolvedTypes.add(
          ServiceType(
            id: inlineId,
            name: inlineType.name,
            type: inlineType.type,
            unit: inlineType.unit,
            value: inlineType.value,
            option: inlineType.option
                ?.map(
                  (option) => ServiceOptionModel(
                    charges: option.charges,
                    label: option.label,
                    name: option.name,
                  ),
                )
                .toList(),
            validator: inlineType.validator == null
                ? null
                : ServiceValidatorModel(
                    maxValue: inlineType.validator!.maxValue,
                    minValue: inlineType.validator!.minValue,
                  ),
          ),
        );
        addedIds.add(inlineId);
      }
    }

    return resolvedTypes;
  }

  // For creating Job Item...
  Future<String> createUpdateJobItem(Map<String, dynamic> jobItemData) async {
    try {
      print(
          "jobItemData! ${jobItemData[FbConstant.jobItemSelectedCraftsmanId]!}");
      await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .doc(jobItemData[FbConstant.jobId])
          .set(jobItemData);
      return AppConstant.success;
    } catch (e) {
      print("createUpdateJobItem==error==$e");
      return e.toString();
    }
  }

  // For delete Job Item...
  Future<String> deleteJobItem(String jobItemId) async {
    try {
      print("deleteJobId: ${jobItemId}");
      await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .doc(jobItemId)
          .delete();
      return AppConstant.success;
    } catch (e) {
      print("deleteJobItem==error==$e");
      return e.toString();
    }
  }

  // fetchJobItem List
  Future<List<JobItemModel>> fetchJobItemList(String serviceInvoiceId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.jobServiceInvoiceId, isEqualTo: serviceInvoiceId)
          .get();

      List<JobItemModel> jobItemList = [];
      jobItemCount.value = 0.0;
      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = JobItemModel.fromJson(item.data());
          print("jobItemCount ${model.jobItemTotalCharge.toString()}");
          jobItemCount.value = jobItemCount.value + double.parse(model.jobItemTotalCharge.toString());
          print(jobItemCount.value);
          jobItemList.add(model);
        }
      }
      jobItemCount.refresh();
      return jobItemList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetch job item
  Future<Map<String, dynamic>> fetchJobItem(String id) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.id, isEqualTo: id)
          .get();

      JobItemModel? jobItemModel;

      for (var item in querySnapshot.docs) {
        print("querySnapshot");
        print(item.data());
        final model = JobItemModel.fromJson(item.data());
        jobItemModel = model;
      }

      Map<String, dynamic> result = {
        FbConstant.jobItem: jobItemModel,
      };

      return result;
    } catch (e) {
      print("fetchJobItem==error==" + e.toString());
      return {
        FbConstant.jobItem: null,
      };
    }
  }

  // fetch customer detail by id
  Future<Map<String, dynamic>> fetchCustomerById(String id) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.customer)
          .where(FbConstant.id, isEqualTo: id)
          .get();

      CustomerModel? customerModel;

      for (var item in querySnapshot.docs) {
        final model = CustomerModel.fromJson(item.data());
        customerModel = model;
      }

      Map<String, dynamic> result = {
        FbConstant.customer: customerModel,
      };

      return result;
    } catch (e) {
      return {
        FbConstant.customer: null,
      };
    }
  }

  // fetch service detail by id
  Future<Map<String, dynamic>> fetchServiceById(String id) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.service)
          .where(FbConstant.id, isEqualTo: id)
          .get();

      ServicesListModel? servicesListModel;

      for (var item in querySnapshot.docs) {
        final model = ServicesListModel.fromJson(item.data());
        servicesListModel = model;
      }

      Map<String, dynamic> result = {
        FbConstant.service: servicesListModel,
      };

      return result;
    } catch (e) {
      return {
        FbConstant.service: null,
      };
    }
  }

  // create/Update Service Invoice...
  Future<String> createUpdateServiceInvoice(
      Map<String, dynamic> serviceInvoiceData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .doc(serviceInvoiceData[FbConstant.serviceInvoiceId])
          .set(serviceInvoiceData);
      return AppConstant.success;
    } catch (e) {
      print("err==" + e.toString());
      return e.toString();
    }
  }

  // For service Invoice
  Future<String> deleteServiceInvoiceItem(String serviceInvoiceId) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .doc(serviceInvoiceId)
          .delete();
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  // For service data
  Future<Map<String, dynamic>> getServiceData(String id) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .where(FbConstant.serviceInvoiceId, isEqualTo: id)
          .get();

      ServiceInvoiceModel? serviceInvoiceModel;

      for (var item in querySnapshot.docs) {
        final model = ServiceInvoiceModel.fromJson(item.data());
        serviceInvoiceModel = model;
      }

      Map<String, dynamic> result = {
        FbConstant.serviceInvoice: serviceInvoiceModel,
      };

      return result;
    } catch (e) {
      print("err=$e");
      return {
        FbConstant.serviceInvoice: null,
      };
    }
  }
}
