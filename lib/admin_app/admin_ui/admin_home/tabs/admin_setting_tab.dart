import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/dialogs/confirmation_dialog.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/indicator.dart';

class AdminSettingTab extends StatefulWidget {
  const AdminSettingTab({super.key});

  @override
  State<AdminSettingTab> createState() => _AdminSettingTabState();
}

class _AdminSettingTabState extends State<AdminSettingTab> {
  HomeRepository homeRepository = HomeRepository();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> deleteUnusedJobs(String id) async {
    try {
      await _firebaseFirestore.collection(FbConstant.jobItem).doc(id).delete();

      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  deleteAllImages() async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child(FbConstant.jobItemImages);
    ListResult result = await storageRef.listAll();
    print("result: ${result.items.length}");
    result.items.forEach((element) async {
      element.delete();
    });
  }

  onClearCache() async {
    Indicator.showLoading();
    await homeRepository.fetchAllJobList().then((list) async {
      list.forEach((element) {
        if (element.serviceInvoiceId == "") {
          deleteUnusedJobs(element.jobId);
          Reference ref =
              FirebaseStorage.instance.refFromURL(element.jobItemImageUrl);
          ref.delete();
        }
      });
    });
    Indicator.closeIndicator();
  }

  onClearData() async {
    Indicator.showLoading();

    await deleteAllImages();

    //craftsman
    var craftsmanRef = _firebaseFirestore.collection(FbConstant.craftsman);
    var craftsmanDocuments = await craftsmanRef.get();
    for (var document in craftsmanDocuments.docs) {
      await document.reference.delete();
    }

    //branch
    var branchRef = _firebaseFirestore.collection(FbConstant.branch);
    var branchDocuments = await branchRef.get();
    for (var document in branchDocuments.docs) {
      await document.reference.delete();
    }

    //customer
    var customerRef = _firebaseFirestore.collection(FbConstant.customer);
    var customerDocuments = await customerRef.get();
    for (var document in customerDocuments.docs) {
      await document.reference.delete();
    }

    //job items
    var jobItemRef = _firebaseFirestore.collection(FbConstant.jobItem);
    var jobItemDocuments = await jobItemRef.get();
    for (var document in jobItemDocuments.docs) {
      await document.reference.delete();
    }

    //service invoice
    var serviceInvoiceRef =
        _firebaseFirestore.collection(FbConstant.serviceInvoice);
    var serviceInvoiceDocuments = await serviceInvoiceRef.get();
    for (var document in serviceInvoiceDocuments.docs) {
      await document.reference.delete();
    }

    //user
    var userRef = _firebaseFirestore.collection(FbConstant.user);
    var userDocuments = await userRef.get();
    for (var document in userDocuments.docs) {
      if (document.exists) {
        final model = UserModel.fromJson(document.data());
        if (model.id != Storage.getValue(FbConstant.uid)) {
          await document.reference.delete();
        }
      }
    }

    Indicator.closeIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: "Are you sure want to\nclear cache?",
                        negativeLabel: "Cancel",
                        positiveLabel: "Yes",
                        negativeButtonBorder: Border.all(
                          color: ColorManager.colorDarkBlue,
                        ),
                        onNegativeClick: () {
                          Navigator.pop(context);
                        },
                        onPositiveClick: () {
                          Navigator.pop(context);
                          onClearCache();
                        },
                        negativeButtonColor: ColorManager.white,
                        negativeTextColor: ColorManager.colorDarkBlue,
                        positiveButtonColor: ColorManager.colorDarkBlue,
                        positiveTextColor: ColorManager.textColorWhite,
                      );
                    });
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 10, right: 10, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Clear Cache",
                      style: getRegularStyle(
                        color: ColorManager.colorRed,
                        fontSize: FontSize.mediumExtra,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: ColorManager.colorBlack,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: "Are you sure want to\nclear data permanently?",
                        negativeLabel: "Cancel",
                        positiveLabel: "Yes",
                        negativeButtonBorder: Border.all(
                          color: ColorManager.colorDarkBlue,
                        ),
                        onNegativeClick: () {
                          Navigator.pop(context);
                        },
                        onPositiveClick: () {
                          Navigator.pop(context);
                          onClearData();
                        },
                        negativeButtonColor: ColorManager.white,
                        negativeTextColor: ColorManager.colorDarkBlue,
                        positiveButtonColor: ColorManager.colorDarkBlue,
                        positiveTextColor: ColorManager.textColorWhite,
                      );
                    });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "Clear All Data",
                      style: getRegularStyle(
                        color: ColorManager.colorRed,
                        fontSize: FontSize.mediumExtra,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: ColorManager.colorBlack,
            ),
          ],
        ),
      ),
    );
  }
}
