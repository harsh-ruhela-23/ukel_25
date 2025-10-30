import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeRepository homeRepository = HomeRepository();

  List<JobItemModel> allJobItemList = [];
  List<JobItemModel> todoList = [];
  bool isAllJobListFetchingData = false;
  String getAllJobItemListError = '';

  // getJobItemList
  Future getAllJobItemList({String? branchId}) async {
    try {
      allJobItemList.clear();
      todoList.clear();
      if (!isJobListFetchingData) { 
        isAllJobListFetchingData = true;
        await homeRepository.fetchAllJobList(branchId: branchId).then((list) {
          if (list.isNotEmpty) {
            allJobItemList.addAll(list);
            for (var element in list) {
              if (element.jobItemPercentage == '50' ||
                  element.jobItemPercentage == '84' ||
                  element.jobItemPercentage == '0') {
                todoList.add(element);
              }
            }
          }
        });

        getAllJobItemListError = '';
        isAllJobListFetchingData = false;
        notifyListeners();
      }
    } catch (e) {
      isAllJobListFetchingData = false;
      getAllJobItemListError = e.toString();
      notifyListeners();
    }
  }

  List<JobItemModel> craftsmanAllJobsList = [];

  Future<List<JobItemModel>> getAllJobsCraftsman(String id) async {
    craftsmanAllJobsList.clear();
    await homeRepository.fetchAllJobList().then((list) {
      if (list.isNotEmpty) {
        for (var jobItem in list) {
          if (jobItem.selectedCraftsmanId == id) {
            craftsmanAllJobsList.add(jobItem);
          }
        }
      }
    });
    return craftsmanAllJobsList;
  }

  Future<List<JobItemModel>> getAllTodoJobsCraftsman(String id) async {
    List<JobItemModel> craftsmanTodoList = [];
    for (var jobItem in craftsmanAllJobsList) {
      if (jobItem.selectedCraftsmanId == id) {
        if (jobItem.jobItemPercentage == "34") {
          craftsmanTodoList.add(jobItem);
        }
      }
    }
    return craftsmanTodoList;
  }

  Future<List<JobItemModel>> getAllHistoryJobsCraftsman(String id) async {
    List<JobItemModel> craftsmanHistoryList = [];
    for (var jobItem in craftsmanAllJobsList) {
      if (jobItem.selectedCraftsmanId == id) {
        if (jobItem.jobItemPercentage == "100") {
          craftsmanHistoryList.add(jobItem);
        }
      }
    }
    return craftsmanHistoryList;
  }

  List<ServiceInvoiceModel> jobList = [];
  bool isJobListFetchingData = false;
  String getJobListApiError = '';

  // getJobList
  Future<List<ServiceInvoiceModel>?> getJobList({String? branchId}) async {

    try {
      jobList.clear();
      if (!isJobListFetchingData) {
        isJobListFetchingData = true;
        await homeRepository.fetchJobList(branchId: branchId).then((list) {
          print("branch id 1 : $branchId");
          if (list.isNotEmpty) {
            print("branch id 2 : $branchId");

            jobList.addAll(list);
            // jobList = jobList.reversed.toList();
            jobList.sort((a, b) {
              final int codeA = int.parse(a.serviceInvoiceCode.replaceAll(' ', ''));
              final int codeB = int.parse(b.serviceInvoiceCode.replaceAll(' ', ''));
              return codeB.compareTo(codeA); // descending order
            });
          }
        });

        isJobListFetchingData = false;
        getJobListApiError = '';
        notifyListeners();
        return jobList;
      }
    } catch (e) {
      isJobListFetchingData = false;
      getJobListApiError = e.toString();
      notifyListeners();
    }
    return null;
  }

  Future<List<ServiceInvoiceModel>?> onSearch(String query) async {
    print('query is ${query}');

    List<ServiceInvoiceModel>? model =
        await HomeRepository().searchServiceInvoiceList(query);
    return model;
  }
}
