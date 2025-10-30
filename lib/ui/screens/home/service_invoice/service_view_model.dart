import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/services/firebase_api.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_repository.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/utils/indicator.dart';

import '../../../../services/authentication_service.dart';

class AddJobItemResult {
  AddJobItemResult({
    required this.status,
    this.jobItem,
  });

  final String status;
  final JobItemModel? jobItem;

  bool get isSuccess => status == AppConstant.success && jobItem != null;
}

class ServiceViewModel extends ChangeNotifier {
  ServiceInvoiceRepository repository = ServiceInvoiceRepository();

  Timestamp invoiceDueDate = Timestamp.now();

  setInvoiceDueDate(Timestamp date) {
    invoiceDueDate = date;
    notifyListeners();
  }

  TextEditingController phoneController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController additionalChargesController = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController otherNoteController = TextEditingController();

  // Customer
  TextEditingController addCustomerPhoneNoController = TextEditingController();
  TextEditingController addCustomerNameController = TextEditingController();
  TextEditingController addCustomerVillageController = TextEditingController();

  // Job Item
  TextEditingController jobItemQtyController = TextEditingController();
  TextEditingController jobItemOtherNoteController = TextEditingController();

  Future<Map<String, dynamic>> onAddCustomer(
      List<MembersModel> membersData) async {
    Indicator.showLoading();

    Map<String, dynamic> result = {};

    CustomerModel customerModel = CustomerModel(
      id: generateRandomId(),
      name: addCustomerNameController.text,
      nameForSearch: addCustomerNameController.text.toLowerCase(),
      phone: addCustomerPhoneNoController.text,
      village: addCustomerVillageController.text,
      membersData: membersData,
      branchId: Storage.getValue(FbConstant.uid),
    );

    String val = await repository.createCustomer(customerModel.toJson());
    Indicator.closeIndicator();
    result.addAll({"result": val});
    result.addAll({"data": customerModel});
    return result;
  }

  Future<String> updateCustomer(CustomerModel data) async {
    Indicator.showLoading();
    String val = await repository.createCustomer(data.toJson());
    Indicator.closeIndicator();
    return val;
  }

  bool isCustomersFetchingData = false;
  List<CustomerModel> customersModelList = [];
  var isQueryAllSnapshotAssigned = false;
  Future<List<CustomerModel>> searchCustomer(String query) async {
    Map<String, dynamic> result = await repository.searchCustomers(query,isQueryAllSnapshotAssigned);
    List<CustomerModel> customerList = result[FbConstant.customer];
    isQueryAllSnapshotAssigned = true;
    return customerList;
  }

  void getCustomersList() async {
    try {
      customersModelList.clear();
      if (!isCustomersFetchingData) {
        isCustomersFetchingData = true;

        await repository.fetchCustomers().then((customersList) {
          if (customersList.isNotEmpty) {
            customersModelList.addAll(customersList);
          }
        });

        isCustomersFetchingData = false;
        notifyListeners();
      }
    } catch (e) {
      AppUtils.showToast(e.toString());
    }
  }

  CustomerModel? selectedCustomer;
  MembersModel? selectedMember;

  setSelectedCustomer(CustomerModel customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  // Services
  bool isServicesFetchingData = false;
  List<ServicesListModel> servicesModelList = [];

  ServicesListModel? selectedService;

  setSelectedService(ServicesListModel service, bool fromApi) {
    selectedService = service;
    clearServiceValues();
    if (selectedService != null) {
      jobItemCharge =
          double.tryParse(selectedService!.charges.toString()) ?? 0.0;
      getServiceType(fromApi);
    }
  }

  List<ServiceType> serviceAddTypeList = [];

  void getAddNewServiceType(
    String serviceId,
    bool fromApi,
  ) async {
    serviceAddTypeList.clear();
    // if (!provider.isServiceTypeFetchingData) {
    //   provider.isServiceTypeFetchingData = true;
    //   Indicator.showLoading();

    Map<String, dynamic> result = await repository.fetchServicesType(serviceId);

    ServiceType? servicesType = result[FbConstant.serviceType];
    if (servicesType != null) {
      serviceAddTypeList.add(servicesType);
    }

    // if (fromApi) {
    //   setPrefillDataServiceType();
    // }
    // selectedMember?.serviceData?.forEach((element) {
    //   if (element.serviceId != null) {
    //     if (element.serviceId == selectedService?.id) {
    //       setPrefillServiceTypeMemberData();
    //     }
    //   }
    // });

    Indicator.closeIndicator();
    // isServiceTypeFetchingData = false;
    // notifyListeners();
  }

  void getServicesList() async {
    servicesModelList.clear();
    if (!isServicesFetchingData) {
      isServicesFetchingData = true;

      Map<String, dynamic> result = await repository.fetchServices();

      List<ServicesListModel> servicesList = result[FbConstant.service];

      if (servicesList.isNotEmpty) {
        servicesModelList.addAll(servicesList);
      }
      isServicesFetchingData = false;
      notifyListeners();
    }
  }

  bool isServiceTypeFetchingData = false;
  List<ServiceType> serviceTypeList = [];

  Future<List<ServiceType>> _fetchServiceTypesForService(
      ServicesListModel service) async {
    try {
      return await repository.resolveServiceTypes(service);
    } catch (e) {
      return [];
    }
  }

  Future<void> getServiceType(bool fromApi) async {
    serviceTypeList.clear();
    if (selectedService == null) {
      notifyListeners();
      return;
    }

    if (isServiceTypeFetchingData) {
      return;
    }

    isServiceTypeFetchingData = true;
    Indicator.showLoading();

    try {
      final List<ServiceType> resolvedTypes =
          await _fetchServiceTypesForService(selectedService!);
      serviceTypeList.addAll(resolvedTypes);

      selectedMember?.serviceData?.forEach((element) {
        if (element.serviceId != null &&
            element.serviceId == selectedService?.id) {
          setPrefillServiceTypeMemberData();
        }
      });
    } finally {
      Indicator.closeIndicator();
      isServiceTypeFetchingData = false;
      notifyListeners();
    }
  }

  void getNewServiceType(ServicesListModel service, bool fromApi,
      List<ServiceType> newServiceTypeList) async {
    newServiceTypeList.clear();
    // if (!isServiceTypeFetchingData) {
    //   isServiceTypeFetchingData = true;
    Indicator.showLoading();
    try {
      final List<ServiceType> resolvedTypes =
          await _fetchServiceTypesForService(service);
      newServiceTypeList.addAll(resolvedTypes);
      if (fromApi) {
        setPrefillDataServiceType(newServiceTypeList);
      }
    // selectedMember?.serviceData?.forEach((element) {
    //   if (element.serviceId != null) {
    //     if (element.serviceId == selectedService?.id) {
    //       setPrefillServiceTypeMemberData();
    //     }
    //   }
    // });
    } finally {
      Indicator.closeIndicator();
      // isServiceTypeFetchingData = false;
      notifyListeners();
    }
    //}
  }

  void clearServiceValues() {
    serviceRadioValue = "";
    serviceRadioId = "";
    jobItemCharge = 0.0;
    jobItemQty = 0;
    jobItemTotal = 0.0;
    jobItemQtyController.text = "1";
    calculateJobItemTotal();
  }

  String serviceRadioValue = "";
  String serviceRadioId = "";

  double jobItemCharge = 0.0;
  int jobItemQty = 0;
  double jobItemTotal = 0.0;

  void calculateJobItemTotal() {
    double chrge = 0.0;
    if (serviceRadioValue.isNotEmpty) {
      if (serviceRadioId.isNotEmpty) {
        for (int i = 0; i < serviceTypeList.length; i++) {
          if (serviceTypeList[i].id == serviceRadioId &&
              serviceTypeList[i].type.toLowerCase() == "radio") {
            if (serviceTypeList[i].option != null) {
              for (int j = 0; j < serviceTypeList[i].option!.length; j++) {
                if (serviceTypeList[i].option![j].label == serviceRadioValue) {
                  chrge = double.tryParse(
                          serviceTypeList[i].option![j].charges.toString()) ??
                      0.0;
                  break;
                }
              }
            }
          }
        }
      }
    }

    jobItemCharge = double.tryParse(selectedService?.charges == null
            ? "0"
            : selectedService!.charges.toString()) ??
        0.0;
    jobItemCharge = jobItemCharge + chrge;
    jobItemQty = int.tryParse(jobItemQtyController.text) ?? 0;
    jobItemTotal = jobItemCharge * jobItemQty;
    notifyListeners();
  }

  // addJobItem
  Future<AddJobItemResult> addJobItem(
      {required String noteText,
      required File jobItemImage,
      required String itemQR,
      required Color itemColor,
      required int dueDate,
      required String colorName,
      required List<AddJobTimeLineModel> timeLineList,
      required String serviceInvoiceId}) async {
    Indicator.showLoading();

    try {
      String imageUrl = await FirebaseApi.uploadPost(
        jobItemImage,
        FbConstant.jobItemImages,
        "${generateRandomId()}.jpg",
      );

      if (imageUrl.isEmpty) {
        return AddJobItemResult(status: 'image uploading failed');
      }

      JobItemStatusObj statusObj =
          JobItemStatusObj(rejectCount: 0, rejectReason: []);

      JobItemModel jobItemModel = JobItemModel(
        branchId: Storage.getValue(FbConstant.uid),
        serviceInvoiceId: serviceInvoiceId,
        jobItemCreatedAtDate: DateTime.now().millisecondsSinceEpoch,
        jobId: generateRandomId(),
        jobItemCode: itemQR,
        customerModel: selectedCustomer!,
        jobItemColor: itemColor.value,
        jobItemDueDate: dueDate,
        jobItemNotes: noteText,
        jobItemQty: jobItemQty,
        jobItemTotalCharge: jobItemTotal,
        jobItemImageUrl: imageUrl,
        jobItemServiceId: selectedService!.id,
        jobItemServiceValue: getServiceTypeValues(),
        jobItemPercentage: JobPercentConstant.percent0,
        selectedCraftsmanId: '',
        selectedCraftsmanName: '',
        timelineStatusObj: timeLineList,
        jobStatusObj: statusObj,
        colorName: colorName,
      );

      if (selectedMember != null) {
        jobItemModel.customerModel.name = selectedMember!.name!;
        jobItemModel.customerModel.nameForSearch = selectedMember!.name!;
      }

      final String status =
          await repository.createUpdateJobItem(jobItemModel.toJson());

      if (status == AppConstant.success) {
        newMemberJobItemList.add(jobItemModel);
        return AddJobItemResult(status: status, jobItem: jobItemModel);
      }

      return AddJobItemResult(status: status);
    } catch (e) {
      AppUtils.showToast(e.toString());
      return AddJobItemResult(status: e.toString());
    } finally {
      Indicator.closeIndicator();
    }
  }

  Future<String> updateJobItem(JobItemModel model) async {
    String apiStatus = AppConstant.somethingWentWrong;
    Indicator.showLoading();

    await repository.createUpdateJobItem(model.toJson()).then((status) {
      Indicator.closeIndicator();
      apiStatus = status;
    });

    return apiStatus;
  }

  List<JobItemModel> jobItemList = [];
  List<JobItemModel> newMemberJobItemList = [];
  bool isJobListFetchingData = false;

  // getJobItemList
  void getJobItemList(String invoiceId) async {
    try {
      jobItemList.clear();
      if (!isJobListFetchingData) {
        isJobListFetchingData = true;

        await repository.fetchJobItemList(invoiceId).then((list) {
          if (list.isNotEmpty) {
            jobItemList.addAll(list);
          }
        });
        isJobListFetchingData = false;
        notifyListeners();
      }
    } catch (e) {
      isJobListFetchingData = false;
      AppUtils.showToast(e.toString());
    }
  }

  // removeJobItem
  Future<String> deleteJobItem(String jobItemId) async {
    String apiStatus = AppConstant.somethingWentWrong;

    Indicator.showLoading();

    await repository.deleteJobItem(jobItemId).then((status) {
      Indicator.closeIndicator();
      apiStatus = status;
    });
    return apiStatus;
  }

  removeJobItemLocally(JobItemModel jobItemModel) {
    jobItemList.remove(jobItemModel);
    notifyListeners();
  }

  String validateServiceType() {
    String errMsg = "";
    for (final serviceType in serviceTypeList) {
      final String type = serviceType.type.toLowerCase();
      final String value = serviceType.value?.trim() ?? "";
      if (type == "radio") {
        if (value.isEmpty) {
          if (serviceType.option != null && serviceType.option!.isNotEmpty) {
            final List<String> optionNames = serviceType.option!
                .map((option) => option.name.trim())
                .where((name) => name.isNotEmpty)
                .toList();
            if (optionNames.isEmpty) {
              errMsg = "Please select an option";
            } else if (optionNames.length == 1) {
              errMsg = "Please Select ${optionNames.first}";
            } else {
              errMsg =
                  "Please Select Either ${optionNames[0]} Or ${optionNames[1]}";
            }
          } else {
            errMsg = "Please select an option";
          }
          break;
        }
      } else {
        final String fieldName = serviceType.name?.isNotEmpty == true
            ? serviceType.name!
            : "value";
        if (value.isEmpty) {
          errMsg = "Please Enter $fieldName";
          break;
        }
        final ServiceValidatorModel? validator = serviceType.validator;
        if (validator != null) {
          final double? enteredValue = double.tryParse(value);
          final double? minValue = double.tryParse(validator.minValue);
          final double? maxValue = double.tryParse(validator.maxValue);
          final String unitLabel = serviceType.unit?.isNotEmpty == true
              ? serviceType.unit!
              : 'inch';
          if (enteredValue != null) {
            if (minValue != null && enteredValue < minValue) {
              errMsg =
                  '$fieldName must be >=${validator.minValue} $unitLabel';
              break;
            }
            if (maxValue != null && enteredValue > maxValue) {
              errMsg =
                  '$fieldName must be <=${validator.maxValue} $unitLabel';
              break;
            }
          }
        }
      }
    }
    return errMsg;
  }

  List<MemberServiceValueData> getServiceTypeValues() {
    List<MemberServiceValueData> serviceValues = [];
    for (int i = 0; i < serviceTypeList.length; i++) {
      MemberServiceValueData value = MemberServiceValueData(
          id: serviceTypeList[i].id, value: serviceTypeList[i].value ?? "");
      serviceValues.add(value);
    }
    return serviceValues;
  }

  // job item details retrival

  JobItemModel? jobItemData;
  bool isJobItemFetchingData = false;

  void getJobItemData(String jobId, List<ServiceType> newServiceTypeList,
      ServicesListModel? newAddedService) async {
    if (!isJobItemFetchingData) {
      // Indicator.showLoading();
      isJobItemFetchingData = true;
      Map<String, dynamic> result = await repository.fetchJobItem(jobId);

      JobItemModel jobItemDetail = result[FbConstant.jobItem];
      jobItemData = jobItemDetail;
      setJobItemData(newServiceTypeList, newAddedService);
      // Indicator.closeIndicator();
      isJobItemFetchingData = false;
    }
  }

  Future<ServicesListModel?> getServiceName(String jobId) async {
    isJobItemFetchingData = false;
    if (!isJobItemFetchingData) {
      // Indicator.showLoading();
      isJobItemFetchingData = true;
      Map<String, dynamic> result = await repository.fetchJobItem(jobId);

      JobItemModel jobItemDetail = result[FbConstant.jobItem];

      if (jobItemDetail != null) {
        Map<String, dynamic> result =
            await repository.fetchServiceById(jobItemDetail!.jobItemServiceId);

        ServicesListModel servicesListModel = result[FbConstant.service];
        // if (servicesListModel?.serviceTypeModelList != null) {
        //   getServiceType(servicesListModel!.serviceTypeModelList!, true);
        // }

        jobItemQtyController.text = jobItemData!.jobItemQty.toString();
        return servicesListModel;
      }
      notifyListeners();
      // Indicator.closeIndicator();
      isJobItemFetchingData = false;
    }
    return null;
  }

  void setJobItemData(List<ServiceType> newServiceTypeList,
      ServicesListModel? newAddedService) async {
    if (jobItemData != null) {
      getServiceById(
          jobItemData!.jobItemServiceId, newServiceTypeList, newAddedService);
      jobItemQtyController.text = jobItemData!.jobItemQty.toString();
    }
    notifyListeners();
  }

  void setPrefillDataServiceType(List<ServiceType> newServiceTypeList) {
    if (jobItemData!.jobItemServiceValue != null) {
      if (newServiceTypeList.length >=
          jobItemData!.jobItemServiceValue!.length) {
        if (jobItemData!.jobItemServiceValue != null) {
          for (int i = 0; i < jobItemData!.jobItemServiceValue!.length; i++) {
            MemberServiceValueData serviceValue =
                jobItemData!.jobItemServiceValue![i];
            int? foundServiceTypePos =
                getServiceTypeById(serviceValue.id ?? "");
            if (foundServiceTypePos != null) {
              newServiceTypeList[foundServiceTypePos].value =
                  serviceValue.value;
            }
          }
        }
        calculateJobItemTotal();
      }
    }
  }

  void setPrefillServiceTypeMemberData() {
    if (selectedMember!.serviceData != null) {
      int index = -1;
      for (int i = 0; i < selectedMember!.serviceData!.length; i++) {
        if (selectedMember!.serviceData![i].serviceId == selectedService!.id) {
          index = i;
          break;
        }
      }
      if (index > -1) {
        if (selectedMember!.serviceData![index].value != null) {
          if (serviceTypeList.length >=
              selectedMember!.serviceData![index].value!.length) {
            for (int i = 0;
                i < selectedMember!.serviceData![index].value!.length;
                i++) {
              MemberServiceValueData serviceValue =
                  selectedMember!.serviceData![index].value![i];
              int? foundServiceTypePos =
                  getServiceTypeById(serviceValue.id ?? "");
              if (foundServiceTypePos != null) {
                serviceTypeList[foundServiceTypePos].value = serviceValue.value;
                if (serviceTypeList[foundServiceTypePos]
                        .type
                        .toLowerCase() ==
                    "radio") {
                  serviceRadioId = serviceTypeList[foundServiceTypePos].id;
                  serviceRadioValue =
                      serviceTypeList[foundServiceTypePos].value ?? "";
                }
              }
            }
            calculateJobItemTotal();
          }
        }
      }
    }
  }

  int? getServiceTypeById(String id) {
    for (int i = 0; i < serviceTypeList.length; i++) {
      if (serviceTypeList[i].id == id) {
        return i;
      }
    }
    return null; // Return null if ID is not found in the list
  }

  void getCustomerById(String id) async {
    Map<String, dynamic> result = await repository.fetchCustomerById(id);

    CustomerModel customerModel = result[FbConstant.customer];

    selectedCustomer = customerModel;
  }

  void getServiceById(String id, List<ServiceType> newServiceTypeList,
      ServicesListModel? newAddedService) async {
    Map<String, dynamic> result = await repository.fetchServiceById(id);

    ServicesListModel servicesListModel = result[FbConstant.service];
    // if (servicesListModel?.serviceTypeModelList != null) {
    //   getServiceType(servicesListModel!.serviceTypeModelList!, true);
    // }
    newAddedService = servicesListModel;
    setNewSelectedService(
        servicesListModel, true, newServiceTypeList, newAddedService);
  }

  setNewSelectedService(ServicesListModel service, bool fromApi,
      List<ServiceType> newServiceTypeList, ServicesListModel newAddedService) {
    /// The above code in Dart is assigning the value of the variable `service` to the variable
    /// `newAddedService`.
    newAddedService = service;
    clearServiceValues();
    if (newAddedService != null) {
      jobItemCharge = double.tryParse(service.charges.toString()) ?? 0.0;
      getNewServiceType(service, fromApi, newServiceTypeList);
    }
  }

  // // addServiceInvoice
  // Future<String> addServiceInvoice({
  //   String? noteText,
  //   String? paymentMode,
  //   num? receivedAmount,
  //   num? dueAmount,
  //   num? totalAmount,
  //   int? totalQty,
  //   Color? itemColor,
  //   required String invoiceQR,
  //   String? selectedCustomerId,
  //   int? dueDate,
  //   String? customerName,
  //   String? customerPhNo,
  //   String? customerVillage,
  //   List<String>? jobIdsList,
  // }) async {
  //   String apiStatus = AppConstant.somethingWentWrong;
  //
  //   Indicator.showLoading();
  //
  //   ServiceInvoiceModel serviceInvoiceModel = ServiceInvoiceModel(
  //     serviceInvoiceCreatedAtDate: DateTime.now().millisecondsSinceEpoch,
  //     serviceInvoiceDueDate: dueDate ?? DateTime.now().millisecondsSinceEpoch,
  //     serviceInvoiceId: generateRandomId(),
  //     serviceInvoicePaymentMode: paymentMode ?? '',
  //     serviceInvoiceReceivedAmount: receivedAmount ?? 0,
  //     serviceInvoiceDueAmount: dueAmount ?? 0,
  //     serviceInvoiceTotalAmount: totalAmount ?? 0,
  //     serviceInvoiceTotalQty: totalQty ?? 0,
  //     serviceInvoiceCode: invoiceQR,
  //     serviceInvoiceCustomerId: selectedCustomerId ?? '',
  //     serviceInvoiceNotes: noteText ?? '',
  //     customerName: customerName ?? '',
  //     customerPhoneNo: customerPhNo ?? '',
  //     customerVillage: customerVillage ?? '',
  //     jobIdsList: jobIdsList ?? [],
  //   );
  //
  //   await repository
  //       .createServiceInvoice(serviceInvoiceModel.toJson())
  //       .then((status) {
  //     Indicator.closeIndicator();
  //     apiStatus = status;
  //   });
  //   return apiStatus;
  // }

  // createUpdateServiceInvoice
  Future<String> createUpdateServiceInvoice(
      {required ServiceInvoiceModel serviceInvoiceModel}) async {
    String apiStatus = AppConstant.somethingWentWrong;

    Indicator.showLoading();

    await repository
        .createUpdateServiceInvoice(serviceInvoiceModel.toJson())
        .then((status) {
      Indicator.closeIndicator();
      apiStatus = status;
    });
    return apiStatus;
  }

  // remove ServiceInvoice Item
  Future<String> deleteServiceInvoiceItem(String serviceInvoiceItemId) async {
    String apiStatus = AppConstant.somethingWentWrong;

    Indicator.showLoading();

    await repository
        .deleteServiceInvoiceItem(serviceInvoiceItemId)
        .then((status) {
      Indicator.closeIndicator();
      apiStatus = status;
    });
    return apiStatus;
  }

  //service

  ServiceInvoiceModel? serviceData;
  bool isServiceDataFetch = false;

  void getServiceData(String id) async {
    if (!isServiceDataFetch) {
      isServiceDataFetch = true;
      // Indicator.showLoading();

      Map<String, dynamic> result = await repository.getServiceData(id);

      ServiceInvoiceModel? data = result[FbConstant.serviceInvoice];
      serviceData = data;

      // Indicator.closeIndicator();
      isServiceDataFetch = false;
      notifyListeners();
    }
  }

  void clearServiceData() {
    phoneController.clear();
    customerNameController.clear();
    villageController.clear();
    otherNoteController.clear();
    selectedCustomer = null;
    selectedMember = null;
  }

  void clearJobItemData(CustomerModel? customer) {
    isServicesFetchingData = false;
    servicesModelList = [];
    selectedService = null;
    selectedCustomer = null;
    jobItemQtyController.text = "1";
    jobItemOtherNoteController.clear();
    if (customer != null) {
      setSelectedCustomer(customer);
    }
    clearServiceValues();
  }

  void changeJobStatus() {}
}
