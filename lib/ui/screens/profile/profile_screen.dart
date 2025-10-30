import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukel/model/branch_model.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:flutter/services.dart';
import '../../../resource/color_manager.dart';
import '../../../resource/styles_manager.dart';
import '../../../services/get_storage.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constants.dart';
import '../home/home_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BranchModel? profileDetailsModel;
  bool isBranchFetchingData = false;
  final homeRepository = HomeRepository();
  String error = '';

  @override
  void initState() {
    super.initState();
    getBranchDetails();
  }

  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _showChangeTagDialog() async {
    _tagController.text = profileDetailsModel!.tag.toString(); // load saved tag
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Tag'),
        content: TextFormField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: 'Enter your tag',
            counterText: '',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.isNotEmpty) {
                print(_tagController.text);
                final newTag = _tagController.text.toUpperCase();
                saveData(newTag);
                profileDetailsModel!.tag = newTag;
                Navigator.of(ctx).pop();
              }else{
                print("less than 2 char");
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveData(String newTag,) async {
    await FirebaseFirestore.instance
        .collection(FbConstant.branch)
        .doc(Storage.getValue(FbConstant.uid))
        .update({FbConstant.tag: newTag});
  }

  void getBranchDetails() async {
    try {
      if (!isBranchFetchingData) {
        isBranchFetchingData = true;

        await homeRepository
            .fetchBranchDetails(Storage.getValue(FbConstant.uid))
            .then((data) {
          if (data != null) {
            profileDetailsModel = data;
            print("profileDetailsModel");
            print(profileDetailsModel?.tag);
            setState(() {});
          }
        });
        error = '';
        isBranchFetchingData = false;
      }
    } catch (e) {
      isBranchFetchingData = false;
      error = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 28.sp),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.all(17.sp),
              margin: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorManager.colorLightGrey),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: isBranchFetchingData
                  ? buildLoadingWidget
                  : error.isNotEmpty
                      ? Center(
                          child: Text(error.toString()),
                        )
                      : Column(
                          children: [
                            const CircleAvatar(
                              radius: 45, // Image radius
                              backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTj9ySx6w03MteA7LmBWIqr5C7rhqOdC8xY2SLkoAN03bMZfXmTVpRmcH3ewSR_pFpxqJM&usqp=CAU'),
                            ),
                            SizedBox(height: 16.sp),
                            Text(
                              "#${profileDetailsModel!.branchCode ?? ''}",
                              style: getBoldStyle(
                                  color: Colors.black,
                                  fontSize: FontSize.large),
                            ),
                            SizedBox(height: 19.sp),

                            // Personal Details Card
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorManager.colorLightGrey),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.sp, vertical: 11.sp),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE5E9FF),
                                      border: Border.all(
                                          color: ColorManager.colorLightGrey),
                                    ),
                                    child: Text(
                                      'Franchise\'s Detail',
                                      style: getBoldStyle(
                                          color: ColorManager.btnColorDarkBlue,
                                          fontSize: FontSize.big),
                                    ),
                                  ),
                                  SizedBox(height: 12.sp),
                                  Padding(
                                    padding: EdgeInsets.all(10.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        rowDataWidget(
                                            key: 'Owner name',
                                            value: profileDetailsModel!
                                                .branchDetailsModel!.ownerName),
                                        rowDataWidget(
                                            key: 'Owner Address.',
                                            value: profileDetailsModel!
                                                .branchDetailsModel!
                                                .ownerAddress),
                                        rowDataWidget(
                                            key: 'Address',
                                            value: profileDetailsModel!
                                                .branchDetailsModel!
                                                .shopAddress),
                                        rowDataWidget(
                                            key: 'License no.', value: '71866'),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 13.sp),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Rating :',
                                                style: getRegularStyle(
                                                    fontSize:
                                                        FontSize.mediumExtra,
                                                    color: Colors.black),
                                              ),
                                              RatingBar.builder(
                                                initialRating: 3,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                updateOnDrag: false,
                                                itemSize: 20.sp,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 6.sp),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 19.sp),

                            // Bank Details Card
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorManager.colorLightGrey),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.sp, vertical: 11.sp),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE5E9FF),
                                      border: Border.all(
                                          color: ColorManager.colorLightGrey),
                                    ),
                                    child: Text(
                                      'Bank Details',
                                      style: getBoldStyle(
                                          color: ColorManager.btnColorDarkBlue,
                                          fontSize: FontSize.big),
                                    ),
                                  ),
                                  SizedBox(height: 12.sp),
                                  Padding(
                                    padding: EdgeInsets.all(10.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        rowDataWidget(
                                            key: 'Bank name: ',
                                            value: profileDetailsModel!
                                                .bankDetailsModel!.bankName),
                                        rowDataWidget(
                                            key: 'Branch',
                                            value: profileDetailsModel!
                                                .bankDetailsModel!.branch),
                                        rowDataWidget(
                                            key: 'A/c No',
                                            value: profileDetailsModel!
                                                .bankDetailsModel!.accountNo),
                                        rowDataWidget(
                                            key: 'IFSC Code',
                                            value: profileDetailsModel!
                                                .bankDetailsModel!.ifscCode),
                                        // rowDataWidget(
                                        //     key: 'UPI ID', value: 'name@axis'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 19.sp),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: _showChangeTagDialog,
                                      style: ElevatedButton.styleFrom(
                                        // remove min-width constraint so it wraps its child
                                        minimumSize: Size.zero,
                                        backgroundColor:
                                            ColorManager.btnColorDarkBlue,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.sp, vertical: 14.sp),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.sp),
                                        ),
                                      ),
                                      child: Text(
                                        'Change Tag',
                                        style: getBoldStyle(
                                          color: Colors.white,
                                          fontSize: FontSize.mediumExtra,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rowDataWidget(
      {bool isToShowDivider = false,
      required String key,
      required String value,
      int? keyFlex = 1,
      Color? valueColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.sp),
          child: Row(
            children: [
              Text(
                '$key: ',
                style: getRegularStyle(
                    fontSize: FontSize.mediumExtra, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getRegularStyle(
                      fontSize: FontSize.mediumExtra,
                      color: ColorManager.colorGrey),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.sp),
        isToShowDivider
            ? const Divider(color: Color(0xffE0E0E0), thickness: 2)
            : SizedBox(height: 14.sp),
      ],
    );
  }
}
