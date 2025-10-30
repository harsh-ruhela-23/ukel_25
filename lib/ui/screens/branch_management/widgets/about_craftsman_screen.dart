import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/constants.dart';

import '../../../../utils/app_utils.dart';
import '../../../../widgets/custom_app_bar.dart';

class AboutCraftsmanScreen extends StatelessWidget {
  const AboutCraftsmanScreen({Key? key, required this.craftsmanModel})
      : super(key: key);
  final CraftsmanModel craftsmanModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "About Craftsman",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
        child: craftsmanDetailsCard(),
      ),
    );
  }

  Widget craftsmanDetailsCard() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Text(
          //       'Inactive',
          //       style: getMediumStyle(
          //           color: ColorManager.colorGrey, fontSize: FontSize.big),
          //     ),
          //     SizedBox(width: 11.sp),
          //     SvgPicture.asset(IconAssets.iconEmpStatus, height: 17.sp)
          //   ],
          // ),
          // const CircleAvatar(
          //   radius: 40, // Image radius
          //   backgroundImage: NetworkImage(
          //       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTj9ySx6w03MteA7LmBWIqr5C7rhqOdC8xY2SLkoAN03bMZfXmTVpRmcH3ewSR_pFpxqJM&usqp=CAU'),
          // ),
          // SizedBox(height: 16.sp),
          // Text(
          //   'Kartik Patel',
          //   style: getBoldStyle(color: Colors.black, fontSize: FontSize.large),
          // ),
          // SizedBox(height: 8.sp),
          // Text(
          //   'Manager',
          //   style: getMediumStyle(
          //       color: ColorManager.colorGrey, fontSize: FontSize.big),
          // ),
          // SizedBox(height: 19.sp),

          // Service Info Card
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.colorLightGrey),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 11.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E9FF),
                    border: Border.all(color: ColorManager.colorLightGrey),
                  ),
                  child: Text(
                    'Service info',
                    style: getBoldStyle(
                        color: ColorManager.btnColorDarkBlue,
                        fontSize: FontSize.big),
                  ),
                ),
                SizedBox(height: 12.sp),
                Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowDataWidget(
                          key: 'Working Capacity',
                          value:
                              '${craftsmanModel.serviceInfoModel.workCapacity} Days'),
                      rowDataWidget(
                          key: 'Service type',
                          value:craftsmanModel.serviceInfoModel.selectedServiceNames !=
                        
                        null && craftsmanModel.serviceInfoModel.selectedServiceNames!.isNotEmpty
                    ?craftsmanModel.serviceInfoModel.selectedServiceNames!
                        .map((service) => service)
                        .join(', ')
                    : craftsmanModel.serviceInfoModel.serviceType,),
                      rowDataWidget(
                          key: 'Connected Branch',
                          value:
                              craftsmanModel.serviceInfoModel.connectedBranch),
                      rowDataWidget(
                          key: 'Working Location',
                          value:
                              craftsmanModel.serviceInfoModel.workingLocation),
                      rowDataWidget(
                          key: 'Service Charges',
                          value:craftsmanModel.serviceInfoModel.selectedServicePrice !=
                        
                        null && craftsmanModel.serviceInfoModel.selectedServicePrice!.isNotEmpty
                    ?craftsmanModel.serviceInfoModel.selectedServicePrice!
                        .map((service) => service)
                        .join(', ')
                    : '${craftsmanModel.serviceInfoModel.serviceCharges} per/piece',),
                              
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 19.sp),

          // Personal Details Card
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.colorLightGrey),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 11.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E9FF),
                    border: Border.all(color: ColorManager.colorLightGrey),
                  ),
                  child: Text(
                    'Personal Details',
                    style: getBoldStyle(
                        color: ColorManager.btnColorDarkBlue,
                        fontSize: FontSize.big),
                  ),
                ),
                SizedBox(height: 12.sp),
                Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // rowDataWidget(key: 'EID', value: 'AE03'),
                      rowDataWidget(
                          key: 'Phone Number',
                          value:
                              craftsmanModel.personalDetailsModel.phoneNumber),
                      rowDataWidget(
                          key: 'Mobile Number',
                          value: craftsmanModel
                              .personalDetailsModel.mobileNumber
                              .toString()),
                      rowDataWidget(
                          key: 'Email',
                          value:
                              craftsmanModel.personalDetailsModel.email.isEmpty
                                  ? '-'
                                  : craftsmanModel.personalDetailsModel.email),
                      rowDataWidget(
                          key: 'Date of Birth',
                          value: AppUtils.parseDate(
                              craftsmanModel.personalDetailsModel.dateOfBirth,
                              AppConstant.yMMMMd)),
                      rowDataWidget(
                          key: 'Gender',
                          value: craftsmanModel.personalDetailsModel.gender),
                      rowDataWidget(
                          key: 'Home town',
                          value: craftsmanModel.personalDetailsModel.homeTown),
                      rowDataWidget(
                          key: 'Working location',
                          value: craftsmanModel
                              .personalDetailsModel.workingLocation),
                      rowDataWidget(
                          key: 'Address',
                          value: craftsmanModel.personalDetailsModel.address),
                      rowDataWidget(
                          key: 'Aadhaar No.',
                          value: formatAadhaarNumber(
                              craftsmanModel.personalDetailsModel.aadhaarNo)),
                      rowDataWidget(
                          key: 'PAN No.',
                          value: craftsmanModel.personalDetailsModel.panNo),
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
              border: Border.all(color: ColorManager.colorLightGrey),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 11.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E9FF),
                    border: Border.all(color: ColorManager.colorLightGrey),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowDataWidget(
                          key: 'Bank name',
                          value: craftsmanModel.bankDetailsModel.bankName),
                      rowDataWidget(
                          key: 'Branch',
                          value: craftsmanModel.bankDetailsModel.branch),
                      rowDataWidget(
                          key: 'A/c Holder Name',
                          value: craftsmanModel
                              .bankDetailsModel.accountHolderName),
                      rowDataWidget(
                          key: 'A/c No',
                          value: craftsmanModel.bankDetailsModel.accountNo),
                      rowDataWidget(
                          key: 'IFSC Code',
                          value: craftsmanModel.bankDetailsModel.ifscCode),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.sp),
        ],
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
                    fontSize: FontSize.mediumExtra,
                    color: const Color(0xff131835)),
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
