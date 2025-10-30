import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/custom_page_transition.dart';

import '../main.dart';
import '../ui/screens/login/login_screen.dart';
import 'get_storage.dart';

class ConfirmedJobItem {
  ConfirmedJobItem({
    required this.serviceName,
    required this.pieces,
    required this.amount,
    required this.unitPrice,
    required this.jobItemModel,
  });

  final String serviceName;
  int pieces;
  double amount;
  final double unitPrice;
  final JobItemModel jobItemModel;
}

RxList<ConfirmedJobItem> jobItemList2 = <ConfirmedJobItem>[].obs;
RxDouble jobItemCount = 0.0.obs; // this is RxDouble
class AuthenticationService {
  final homeRepo = HomeRepository();

  AuthenticationService._privateConstructor();

  static final AuthenticationService _instance =
      AuthenticationService._privateConstructor();

  factory AuthenticationService() => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<String> userLogin(String role, String email, String password) async {
    try {
      final user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        print("fetchBranchDetails $uid");
        await homeRepo.fetchBranchDetails(uid).then((data) async {
          if (data != null) {
            await Storage.saveValue(FbConstant.branchId, data.id);
            await Storage.saveValue(FbConstant.branchCode, data.branchCode);
            await Storage.saveValue(FbConstant.createdBy, data.createdBy);
            if (data.branchDetailsModel != null) {
              await Storage.saveValue(
                  FbConstant.branch, data.branchDetailsModel!.ownerAddress);
            }
            print("fetchBranchDetails-2");
          }
          print("fetchBranchDetails-1 ");
        });
        await Storage.saveValue(FbConstant.uid, uid);
        await Storage.saveValue(AppConstant.role, role);
        await Storage.saveValue(AppConstant.isLogin, true);
        print("login success 1");
        return AppConstant.success;
      } else {
        return AppConstant.failed;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AppConstant.noUserFound;
      } else if (e.code == 'wrong-password') {
        return 'Wrong Password Provided';
      } else {
        return 'Wrong Password Provided';
      }
    }
  }

  Future<void> logOut(BuildContext context) async {
    await _firebaseMessaging
        .unsubscribeFromTopic(Storage.getValue(FbConstant.uid));

    await Storage.clearStorage();

    await _auth.signOut().then((value) {
      AppUtils.navigateAndRemoveUntil(
        context,
        CustomPageTransition(
          MyApp.myAppKey,
          LoginScreen.routeName,
        ),
      );
    });
  }
}
