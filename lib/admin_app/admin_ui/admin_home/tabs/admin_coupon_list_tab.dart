import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/add_coupon_screen.dart';
import 'package:ukel/model/coupon_model.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/indicator.dart';
import '../../../../resource/color_manager.dart';
import '../../../../services/get_storage.dart';

class AdminCouponListTab extends StatefulWidget {
  const AdminCouponListTab({Key? key}) : super(key: key);

  @override
  State<AdminCouponListTab> createState() => _AdminCouponListTabState();
}

class _AdminCouponListTabState extends State<AdminCouponListTab> {
  final repository = HomeRepository();
  bool isCouponListFetchingData = false;
  List<CouponModel> couponList = [];
  String error = '';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print("FbConstant");
    print(Storage.getValue(FbConstant.uid));
    fetchCouponList();
  }

  void fetchCouponList() async {
    couponList.clear();
    try {
      if (!isCouponListFetchingData) {
        isCouponListFetchingData = true;

        await repository.fetchCouponList().then((list) {
          if (list.isNotEmpty) {
            couponList.addAll(list);
          }
        });
        await repository.fetchCustomCouponList().then((list) {
          if (list.isNotEmpty) {
            couponList.addAll(list);
          }
        });

        error = '';
        isCouponListFetchingData = false;
      }
    } catch (e) {
      error = e.toString();
      isCouponListFetchingData = false;
    }
    setState(() {});
  }

  Future removeCouponItem(String id) async {
    Indicator.showLoading();
    try {
      _firebaseFirestore.collection(FbConstant.coupon).doc(id).delete();
      Indicator.closeIndicator();
      return;
    } catch (e) {
      log('errr');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Column(
          children: [
            SizedBox(height: 15.sp),

            if (couponList.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 15.sp, top: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddNewCouponScreen(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            fetchCouponList();
                          }
                        });
                      },
                      child: Text(
                        '+ Add New Coupon',
                        style: getBoldStyle(
                            color: Colors.purple,
                            fontSize: FontSize.mediumExtra),
                      ),
                    ),
                  ],
                ),
              ),

            // Color List
            isCouponListFetchingData
                ? Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: buildLoadingWidget,
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Text(error.toString()),
                      )
                    : couponList.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 30.h),
                            child: Center(child: addNewBranchCard()),
                          )
                        : buildCouponListWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildCouponListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: couponList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 6, right: 6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: ColorManager.colorLightGrey),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        couponList[index].code ?? "",
                        style: getMediumStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          couponList[index].amount ?? "",
                          style: getRegularStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    removeCouponItem(couponList[index].id!).then((value) {
                      couponList.remove(couponList[index]);
                      fetchCouponList();
                    });
                  },
                  child: Icon(Icons.delete,
                      size: 20.sp, color: ColorManager.colorDarkBlue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget addNewBranchCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddNewCouponScreen(),
          ),
        ).then((value) {
          if (value == true) {
            fetchCouponList();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.sp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          color: const Color(0XFFFAF4E1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.black,
              size: 25.sp,
            ),
            SizedBox(height: 5.sp),
            Text(
              'Add New Coupon',
              style: getBoldStyle(
                  color: Colors.black, fontSize: FontSize.mediumExtra),
            ),
          ],
        ),
      ),
    );
  }
}
