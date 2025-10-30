import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/add_new_color_screen.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/indicator.dart';

import '../../../../model/color_model.dart';
import '../../../../resource/color_manager.dart';
import '../../../../services/get_storage.dart';

class AdminColorListTab extends StatefulWidget {
  const AdminColorListTab({Key? key}) : super(key: key);

  @override
  State<AdminColorListTab> createState() => _AdminColorListTabState();
}

class _AdminColorListTabState extends State<AdminColorListTab> {
  final repository = HomeRepository();
  bool isColorsListFetchingData = false;
  List<CustomColorModel> colorList = [];
  String error = '';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getColorsList();
  }

  void getColorsList() async {
    colorList.clear();
    try {
      if (!isColorsListFetchingData) {
        isColorsListFetchingData = true;

        await repository.fetchColorsList(Storage.getValue(FbConstant.uid)).then((list) {
          if (list.isNotEmpty) {
            colorList.addAll(list);
          }
        });
        await repository.fetchDefaultColorsList().then((list) {
          if (list.isNotEmpty) {
            colorList.addAll(list);
          }
        });
        error = '';
        isColorsListFetchingData = false;
      }
    } catch (e) {
      error = e.toString();
      isColorsListFetchingData = false;
    }
    setState(() {});
  }

  Future removeColorItem(String id) async {
    Indicator.showLoading();
    try {
      _firebaseFirestore.collection(FbConstant.color).doc(id).delete();
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
            if (colorList.isNotEmpty)
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
                            builder: (context) => const AddNewColorScreen(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            getColorsList();
                          }
                        });
                      },
                      child: Text(
                        '+ Add New Color',
                        style: getBoldStyle(
                            color: Colors.purple,
                            fontSize: FontSize.mediumExtra),
                      ),
                    ),
                  ],
                ),
              ),

            // Color List
            isColorsListFetchingData
                ? Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: buildLoadingWidget,
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Text(error.toString()),
                      )
                    : colorList.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 30.h),
                            child: Center(child: addNewBranchCard()),
                          )
                        : buildColorListWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildColorListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: colorList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 15.sp),
          child: ListTile(
            contentPadding: EdgeInsets.all(11.sp),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: ColorManager.colorLightGrey, width: 1),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: colorList[index].colorCode != null
                //     ? Color(validateColor(colorList[index].colorCode!) == true
                //         ? int.parse(colorList[index].colorCode!)
                //         : 0xff000000)
                //     : Colors.black,
                color: colorList[index].colorCode != null
                    ? Color(int.parse(colorList[index].colorCode!))
                    : Colors.black,
              ),
            ),
            title: Text(
              colorList[index].name ?? '-',
              style: getBoldStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.big,
              ),
            ),
            trailing: InkWell(
              onTap: () {
                removeColorItem(colorList[index].id!).then((value) {
                  colorList.remove(colorList[index]);
                  getColorsList();
                });
              },
              child: Icon(Icons.delete,
                  size: 20.sp, color: ColorManager.colorDarkBlue),
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
            builder: (context) => const AddNewColorScreen(),
          ),
        ).then((value) {
          if (value == true) {
            getColorsList();
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
              'Add New Color',
              style: getBoldStyle(
                  color: Colors.black, fontSize: FontSize.mediumExtra),
            ),
          ],
        ),
      ),
    );
  }
}
