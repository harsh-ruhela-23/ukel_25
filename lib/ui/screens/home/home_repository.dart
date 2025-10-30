import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukel/model/branch_model.dart';
import 'package:ukel/model/coupon_model.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/service_invoice_model.dart';

import '../../../model/color_model.dart';
import '../../../model/job_item_model.dart';
import '../../../services/get_storage.dart';
import '../../../utils/constants.dart';

class HomeRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // fetchAllJobList List
  Future<List<JobItemModel>> fetchAllJobList({String? branchId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (Storage.getValue(AppConstant.role) == "A" ||
          Storage.getValue(AppConstant.role) == "D" ||
          Storage.getValue(AppConstant.role) == "C") {
        if (branchId != null) {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.jobItem)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .get();
        } else {
          querySnapshot =
              await _firebaseFirestore.collection(FbConstant.jobItem).get();
        }
      } else {
        querySnapshot = await _firebaseFirestore
            .collection(FbConstant.jobItem)
            .where(FbConstant.branchId,
                isEqualTo: Storage.getValue(FbConstant.uid))
            .get();
      }

      List<JobItemModel> jobList = [];
      print("branchId--1");
      print(querySnapshot.docs.length);
      for (var item in querySnapshot.docs) {
        if (item.exists) {
          print("branchId--777");
          print(item.data());
          final model = JobItemModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetchJobListByJobStatus List
  Future<List<JobItemModel>> fetchJobListByJobStatus(
      {required String status, String? branchId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;

      print("branch id :  $branchId");
      if (Storage.getValue(AppConstant.role) == "A" ||
          Storage.getValue(AppConstant.role) == "D") {
        if (branchId != null) {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.jobItem)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .where(FbConstant.jobItemPercentage, isEqualTo: status)
              .get();
        } else {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.jobItem)
              .where(FbConstant.jobItemPercentage, isEqualTo: status)
              .get();
        }
      } else {
        querySnapshot = await _firebaseFirestore
            .collection(FbConstant.jobItem)
            .where(FbConstant.branchId,
                isEqualTo: Storage.getValue(FbConstant.uid))
            .where(FbConstant.jobItemPercentage, isEqualTo: status)
            .get();
      }

      List<JobItemModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = JobItemModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetchJobListByJobStatus List
  Future<List<JobItemModel>> fetchJobListByCraftsmanStatus(
      List<String> statusList) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;

      querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.jobItemSelectedCraftsmanId,
              isEqualTo: Storage.getValue(FbConstant.uid))
          .where(FbConstant.jobItemPercentage, whereIn: statusList)
          .get();

      List<JobItemModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = JobItemModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetchJob List
  Future<List<ServiceInvoiceModel>> fetchJobList({String? branchId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;

      if (Storage.getValue(AppConstant.role) == "A" ||
          Storage.getValue(AppConstant.role) == "D") {
        if (branchId != null) {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.serviceInvoice)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .get();
        } else {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.serviceInvoice)
              .get();
        }
      } else {
        querySnapshot = await _firebaseFirestore
            .collection(FbConstant.serviceInvoice)
            .where(FbConstant.branchId,
                isEqualTo: Storage.getValue(FbConstant.uid))
            //.orderBy(FbConstant.serviceInvoiceCreatedAtDate, descending: false)
            .get();
      }

      List<ServiceInvoiceModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = ServiceInvoiceModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      // if (jobList.isNotEmpty) {
      //   jobList.sort((a, b) => a.serviceInvoiceCreatedAtDate
      //       .compareTo(b.serviceInvoiceCreatedAtDate));
      // }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetch completed Job List
  Future<List<ServiceInvoiceModel>> fetchCompletedJobList() async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .where(FbConstant.branchId,
              isEqualTo: Storage.getValue(FbConstant.uid))
          .where(FbConstant.serviceInvoiceStatusValue,
              isEqualTo: JobPercentConstant.percent100)
          .get();

      List<ServiceInvoiceModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = ServiceInvoiceModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // For creating Craftsman...
  Future<String> createCraftsman(Map<String, dynamic> craftsmanItemData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.craftsman)
          .doc(craftsmanItemData[FbConstant.craftsmanId])
          .set(craftsmanItemData);
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  // For adding Employee...
  Future<String> addEmployee(Map<String, dynamic> employeeItemData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.employee)
          .doc(employeeItemData[FbConstant.craftsmanId])
          .set(employeeItemData);
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

//  '${FbConstant.craftsmanServiceInfo}.${'selectedServiceNames'}',
//               arrayContains: isByServiceType,
  // fetchCraftsmanList List
//   Future<List<CraftsmanModel>> fetchCraftsmanList(
//       {String isByServiceType = '', String? branchId}) async {
//     try {
//       // final QuerySnapshot<Map<String, dynamic>> querySnapshot;
//       // if (isByServiceType.isNotEmpty) {
//       //   querySnapshot = await _firebaseFirestore
//       //       .collection(FbConstant.craftsman)
//       //       .where(
//       //           '${FbConstant.craftsmanServiceInfo}.${FbConstant.craftsmanServiceType}',
//       //           isEqualTo: isByServiceType)
//       //       .where(FbConstant.branchId, isEqualTo: branchId)
//       //       //.orderBy(FbConstant.serviceInvoiceCreatedAtDate, descending: false)
//       //       .get();
//       // } else {
//       //   if (branchId != null) {
//       //     querySnapshot = await _firebaseFirestore
//       //         .collection(FbConstant.craftsman)
//       //         .where(FbConstant.branchId, isEqualTo: branchId)
//       //         .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
//       //             descending: false)
//       //         .get();
//       //   } else {
//       //     querySnapshot = await _firebaseFirestore
//       //         .collection(FbConstant.craftsman)
//       //         .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
//       //             descending: false)
//       //         .get();
//       //   }
//       // }
//       if (isByServiceType.isNotEmpty) {
//         Query checkFieldQuery = _firebaseFirestore
//             .collection(FbConstant.craftsman)
//             .where(
//                 '${FbConstant.craftsmanServiceInfo}.${'selectedServiceNames'}',
//                 isGreaterThanOrEqualTo: '')
//             .where(
//                 '${FbConstant.craftsmanServiceInfo}.${'selectedServiceNames'}',
//                 isLessThanOrEqualTo:
//                     '{}'); // This checks for the field's existence and non-null value

// // Execute the query
//         QuerySnapshot checkFieldSnapshot = await checkFieldQuery.get();

// // Determine if there are any documents where the field is not null
//         bool fieldExistsInAnyDocument = checkFieldSnapshot.docs.isNotEmpty;

//         Query query;

//         if (fieldExistsInAnyDocument) {
//           // Field exists and is not null in some documents, use arrayContains query
//           query = _firebaseFirestore
//               .collection(FbConstant.craftsman)
//               .where(
//                   '${FbConstant.craftsmanServiceInfo}.${'selectedServiceNames'}',
//                   arrayContains: isByServiceType)
//               .where(FbConstant.branchId, isEqualTo: branchId);
//         } else {
//           // Field is null or does not exist in any documents, use the alternative query
//           query = _firebaseFirestore
//               .collection(FbConstant.craftsman)
//               .where(
//                   '${FbConstant.craftsmanServiceInfo}.${FbConstant.craftsmanServiceType}',
//                   isEqualTo: isByServiceType)
//               .where(FbConstant.branchId, isEqualTo: branchId);
//         }

// // Execute the final query
//         QuerySnapshot querySnapshot = await query.get();
//         List<CraftsmanModel> craftsmanList = [];
//         for (var item in querySnapshot.docs) {
//           if (item.exists) {
//             final data = item.data() as Map<String, dynamic>;
//             final model = CraftsmanModel.fromJson(data);
//             craftsmanList.add(model);
//           }
//         }

//         return craftsmanList;
//       } else {
//         final QuerySnapshot<Map<String, dynamic>> querySnapshot;
//         if (branchId != null) {
//           querySnapshot = await _firebaseFirestore
//               .collection(FbConstant.craftsman)
//               .where(FbConstant.branchId, isEqualTo: branchId)
//               .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
//                   descending: false)
//               .get();
//         } else {
//           querySnapshot = await _firebaseFirestore
//               .collection(FbConstant.craftsman)
//               .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
//                   descending: false)
//               .get();
//         }
//         List<CraftsmanModel> craftsmanList = [];
//         for (var item in querySnapshot.docs) {
//           if (item.exists) {
//             final data = item.data();
//             final model = CraftsmanModel.fromJson(data);
//             craftsmanList.add(model);
//           }
//         }
//       }
//     } catch (e) {
//       throw e.toString();
//     }
//   }
  Future<List<CraftsmanModel>> fetchCraftsmanList({
    String isByServiceType = '',
    String? branchId,
    List<String>? selectedServiceFilters,
    bool enforceServiceNameFilters = false,
  }) async {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
    try {
      final List<String> normalizedFilters = (selectedServiceFilters ?? [])
          .map((filter) => filter.trim())
          .where((filter) => filter.isNotEmpty)
          .toList();

      if (normalizedFilters.isNotEmpty) {
        Query<Map<String, dynamic>> query = _firebaseFirestore
            .collection(FbConstant.craftsman)
            .where(
                '${FbConstant.craftsmanServiceInfo}.selectedServiceNames',
                arrayContainsAny: normalizedFilters);

        if (branchId != null) {
          query = query.where(FbConstant.branchId, isEqualTo: branchId);
        }

        final QuerySnapshot<Map<String, dynamic>> filterSnapshot =
            await query.get();
        final List<CraftsmanModel> filteredCraftsmen = filterSnapshot.docs
            .map((item) => CraftsmanModel.fromJson(item.data()))
            .toList();

        if (filteredCraftsmen.isNotEmpty || enforceServiceNameFilters) {
          return filteredCraftsmen;
        }
      }

      if (isByServiceType.isNotEmpty) {
        // Query to check if the field exists and is not null
        Query checkFieldQuery = FirebaseFirestore.instance
            .collection(FbConstant.craftsman)
            .where('${FbConstant.craftsmanServiceInfo}.selectedServiceNames',
                isNotEqualTo: null); // Only check for non-null fields
        // Execute the query
        QuerySnapshot checkFieldSnapshot = await checkFieldQuery.get();

        // Filter documents to ensure field is not an empty array
        List<QueryDocumentSnapshot> validDocuments =
            checkFieldSnapshot.docs.where((doc) {
          List<dynamic>? selectedServiceNames = doc
              .get('${FbConstant.craftsmanServiceInfo}.selectedServiceNames');
          return selectedServiceNames != null &&
              selectedServiceNames.isNotEmpty;
        }).toList();

        // Determine if there are any documents where the field is not null and not empty
        bool fieldExistsInAnyDocument = validDocuments.isNotEmpty;
        Query<Map<String, dynamic>> query;
        if (fieldExistsInAnyDocument) {
          // Field exists and is not null in some documents, use arrayContains query
          query = _firebaseFirestore
              .collection(FbConstant.craftsman)
              .where(
                  '${FbConstant.craftsmanServiceInfo}.${'selectedServiceNames'}',
                  arrayContains: isByServiceType);
        } else {
          // Field is null or does not exist in any documents, use the alternative query
          query = _firebaseFirestore
              .collection(FbConstant.craftsman)
              .where(
                  '${FbConstant.craftsmanServiceInfo}.${FbConstant.craftsmanServiceType}',
                  isEqualTo: isByServiceType);
        }

        if (branchId != null) {
          query = query.where(FbConstant.branchId, isEqualTo: branchId);
        }

        // Execute the final query
        final QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await query.get();
        return querySnapshot.docs
            .where((item) => item.exists)
            .map((item) => CraftsmanModel.fromJson(item.data()))
            .toList();
      } else {
        // Query based on branchId or without branchId
        final QuerySnapshot<Map<String, dynamic>> querySnapshot;
        if (branchId != null) {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.craftsman)
              .where(FbConstant.branchId, isEqualTo: branchId)
              .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
                  descending: false)
              .get();
        } else {
          querySnapshot = await _firebaseFirestore
              .collection(FbConstant.craftsman)
              .orderBy(FbConstant.serviceInvoiceCreatedAtDate,
                  descending: false)
              .get();
        }

        return querySnapshot.docs
            .where((item) => item.exists)
            .map((item) => CraftsmanModel.fromJson(item.data()))
            .toList();
      }
    } catch (e) {
      throw Exception('Error fetching craftsmen: $e');
    }
  }

  Future<CraftsmanModel?> fetchCraftsmanDetail({String id = ''}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;
      querySnapshot = await _firebaseFirestore
          .collection(FbConstant.craftsman)
          .where(FbConstant.craftsmanId, isEqualTo: id)
          .get();

      CraftsmanModel? craftsmanDetail;

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CraftsmanModel.fromJson(item.data());
          craftsmanDetail = model;
        }
      }

      return craftsmanDetail;
    } catch (e) {
      throw e.toString();
    }
  }

  // searchServiceInvoiceList List
  Future<List<ServiceInvoiceModel>> searchServiceInvoiceList(
      String query) async {
    try {
      // final querySnapshot = await _firebaseFirestore
      //     .collection(FbConstant.serviceInvoice)
      //     // .where(FbConstant.branchId,
      //     //     isEqualTo: Storage.getValue(FbConstant.uid))
      //     //.startAt([query]).endAt([query + '\uf8ff'])
      //     .where(FbConstant.serviceInvoiceCustomerName, arrayContains: query)
      //
      //     // .where(FbConstant.serviceInvoiceCustomerName,
      //     //     isGreaterThanOrEqualTo: query, isLessThan: '${query}z')
      //     .get();

      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.serviceInvoice)
          .where(FbConstant.serviceInvoiceCustomerName,
              isGreaterThanOrEqualTo: query,
              isLessThan: query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
          .get();

      List<ServiceInvoiceModel> searchList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = ServiceInvoiceModel.fromJson(item.data());
          searchList.add(model);
        }
      }

      return searchList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetchJobListByJobStatus List
  Future<List<JobItemModel>> fetchJobListByCraftsmanId(
      String craftsmanId) async {
    try {
      // final querySnapshot = await _firebaseFirestore
      //     .collection(FbConstant.jobItem)
      //     .where(FbConstant.branchId,
      //         isEqualTo: Storage.getValue(FbConstant.uid))
      //     .where(FbConstant.jobItemSelectedCraftsmanId, isEqualTo: craftsmanId)
      //     .get();

      final QuerySnapshot<Map<String, dynamic>> querySnapshot;

      // if (Storage.getValue(AppConstant.role) == "A" ||
      //     Storage.getValue(AppConstant.role) == "C") {
      //   querySnapshot = await _firebaseFirestore
      //       .collection(FbConstant.jobItem)
      //       .where(FbConstant.branchId,
      //           isEqualTo: Storage.getValue(FbConstant.uid))
      //       .where(FbConstant.jobItemSelectedCraftsmanId,
      //           isEqualTo: craftsmanId)
      //       .get();
      // } else {
      querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.jobItemSelectedCraftsmanId, isEqualTo: craftsmanId)
          .get();
      // }

      List<JobItemModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = JobItemModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }

  // For creating Branch...
  Future<String> createNewBranch(Map<String, dynamic> branchItemData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.branch)
          .doc(branchItemData[FbConstant.id])
          .set(branchItemData);
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  var querySnapshot;

  Future<List<BranchModel>> fetchBranches() async {
    try {
      final isDealer = Storage.getValue(AppConstant.role) == "D";
      if (Storage.getValue(AppConstant.role) == "D") {
        querySnapshot = await _firebaseFirestore
            .collection(FbConstant.branch)
            .where(
              "createdBy",
              isEqualTo: Storage.getValue(FbConstant.uid),
            )
            .get();
      } else {
        querySnapshot =
            await _firebaseFirestore.collection(FbConstant.branch).get();
      }

      List<BranchModel> branchModelList = [];
      for (var item in querySnapshot.docs) {
        print("fetchBranches-1");
        if (item.exists) {
          final model = BranchModel.fromJson(item.data());
          branchModelList.add(model);
        }
      }
      return branchModelList;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<BranchModel?> fetchBranchDetails(String id) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot;
      querySnapshot = await _firebaseFirestore
          .collection(FbConstant.branch)
          .where(FbConstant.id, isEqualTo: id)
          .get();

      BranchModel? branchDetails;

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = BranchModel.fromJson(item.data());
          branchDetails = model;
        }
      }

      return branchDetails;
    } catch (e) {
      throw e.toString();
    }
  }

  // For add Color...
  Future<String> addColorToFirebase(Map<String, dynamic> colorItemData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.color)
          .doc(colorItemData[FbConstant.id])
          .set(colorItemData);
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  // fetchColor
  Future<List<CustomColorModel>> fetchColorsList(branchId) async {
    print("fetchColor");
    print(Storage.getValue(FbConstant.uid));
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.color)
          .where("branch_id", isEqualTo: branchId)
          .get();
      List<CustomColorModel> colorModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CustomColorModel.fromJson(item.data());
          colorModelList.add(model);
        }
      }
      return colorModelList;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CustomColorModel>> fetchDefaultColorsList() async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.color)
          .where("branch_id", isEqualTo: "1")
          .get();

      List<CustomColorModel> colorModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CustomColorModel.fromJson(item.data());
          colorModelList.add(model);
        }
      }
      return colorModelList;
    } catch (e) {
      throw e.toString();
    }
  }

  // fetchCoupon
  Future<List<CouponModel>> fetchCouponList() async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.coupon)
          .where("branch_id", isEqualTo: "1")
          .get();

      List<CouponModel> couponModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CouponModel.fromJson(item.data());
          couponModelList.add(model);
        }
      }
      return couponModelList;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CouponModel>> fetchCustomCouponList() async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.coupon)
          .where("branch_id", isEqualTo: Storage.getValue(FbConstant.uid))
          .get();

      List<CouponModel> couponModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CouponModel.fromJson(item.data());
          couponModelList.add(model);
        }
      }
      return couponModelList;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> addCouponToFirebase(
      Map<String, dynamic> couponItemData) async {
    try {
      await _firebaseFirestore
          .collection(FbConstant.coupon)
          .doc(couponItemData[FbConstant.id])
          .set(couponItemData);
      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  Future<CouponModel?> fetchCouponByCode(String code) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.coupon)
          .where(FbConstant.couponCode, isEqualTo: code)
          .where(FbConstant.branchId,
              isEqualTo: Storage.getValue(FbConstant.createdBy))
          .get();

      CouponModel? couponModel;
      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = CouponModel.fromJson(item.data());
          couponModel = model;
        }
      }
      return couponModel;
    } catch (e) {
      throw e.toString();
    }
  }

  // getJobListByServiceInvoiceId
  Future<List<JobItemModel>> getJobListByServiceInvoiceId(
      String serviceInvoiceId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(FbConstant.jobItem)
          .where(FbConstant.jobServiceInvoiceId, isEqualTo: serviceInvoiceId)
          .get();

      List<JobItemModel> jobList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = JobItemModel.fromJson(item.data());
          jobList.add(model);
        }
      }

      return jobList;
    } catch (e) {
      throw e.toString();
    }
  }
}
