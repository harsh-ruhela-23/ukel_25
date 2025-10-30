import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/custom_craftman_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class SelectCraftsmanScreen extends StatefulWidget {
  const SelectCraftsmanScreen(
      {Key? key,
      required this.craftsmanList,
      required this.jobItemModel,
      required this.isChange,
      this.currentCraftsman})
      : super(key: key);
  final List<CraftsmanModel> craftsmanList;
  final JobItemModel jobItemModel;
  final bool isChange;
  final CraftsmanModel? currentCraftsman;

  @override
  State<SelectCraftsmanScreen> createState() => _SelectCraftsmanScreenState();
}

class _SelectCraftsmanScreenState extends State<SelectCraftsmanScreen> {
  // List<CraftsmanModel> craftsmanList = [];
  // bool isCraftsmanListFetchingData = false;
  // final homeRepository = HomeRepository();
  // String error = '';
  //
  // @override
  // void initState() {
  //   super.initState();
  //   getCraftsmanList();
  // }
  //
  // void getCraftsmanList() async {
  //   craftsmanList.clear();
  //   try {
  //     if (!isCraftsmanListFetchingData) {
  //       isCraftsmanListFetchingData = true;
  //
  //       await homeRepository.fetchCraftsmanList().then((list) {
  //         if (list.isNotEmpty) {
  //           craftsmanList.addAll(list);
  //         }
  //       });
  //       error = '';
  //       isCraftsmanListFetchingData = false;
  //     }
  //   } catch (e) {
  //     isCraftsmanListFetchingData = false;
  //     error = e.toString();
  //   }
  //   setState(() {});
  // }

  // updateJobItemCraftsmanId to Firebase
  // set selected CraftmanId to JobModel
  updateJobItemCraftsmanId(JobItemModel model) async {
    await FirebaseFirestore.instance
        .collection(FbConstant.jobItem)
        .doc(model.jobId)
        .set(model.toJson());
  }

  // updateCraftsmanWorkStatus to Firebase
  // increase appointed by 1
  updateCraftsmanWorkStatus(CraftsmanModel craftsmanModel) async {
    print("change: ${craftsmanModel.id}");
    await FirebaseFirestore.instance
        .collection(FbConstant.craftsman)
        .doc(craftsmanModel.id)
        .set(craftsmanModel.toJson());
  }

  List<CustomCraftsmanModel> customCraftsmanList = [];

  @override
  void initState() {
    super.initState();
    setData();
  }

  void setData() async {
    if (widget.craftsmanList.isNotEmpty) {
      for (var element in widget.craftsmanList) {
        customCraftsmanList.add(CustomCraftsmanModel(
          model: element,
          remainingDays: AppUtils.calculateCraftsmanIndividualRemainingDays(
                      element) ==
                  null
              ? 0
              : AppUtils.calculateCraftsmanIndividualRemainingDays(element)!,
        ));
      }
      customCraftsmanList
          .sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () => AppUtils.navigateUp(context),
          title: "Craftsman",
        ),
        body: widget.craftsmanList.isEmpty
            ? const Center(
                child: Text('No Craftsman Available'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: customCraftsmanList.length,
                itemBuilder: (context, index) {
                  return craftsmanItem(customCraftsmanList[index]);
                },
              ),
      ),
    );
  }

  // craftsmanItem
  Widget craftsmanItem(CustomCraftsmanModel customCraftsmanModel) {
    double workLoad = AppUtils.getCraftsmanWorkLoad(
        customCraftsmanList,
        customCraftsmanModel.remainingDays,
        customCraftsmanModel.model.serviceInfoModel.serviceType);

    return InkWell(
      onTap: () {
        // if (workLoad == 1) {
        //   AppUtils.showToast(
        //       'This craftsman has 100% workload, so not available currently.');
        //   return;
        // }

        if (widget.jobItemModel.selectedCraftsmanId ==
            customCraftsmanModel.model.id) {
          AppUtils.showToast('You have already selected this Craftsman');
        } else {
          if (widget.isChange) {
            print("new cr: ${customCraftsmanModel.model.id}");

            if (widget.jobItemModel.jobItemPercentage ==
                    JobPercentConstant.percent0 ||
                widget.jobItemModel.jobItemPercentage ==
                    JobPercentConstant.percent16) {
              customCraftsmanModel.model.appointed =
                  customCraftsmanModel.model.appointed + 1;
              if (widget.currentCraftsman != null) {
                print("curr cr: ${widget.currentCraftsman!.id}");
                widget.currentCraftsman!.appointed =
                    widget.currentCraftsman!.appointed - 1;
                updateCraftsmanWorkStatus(widget.currentCraftsman!);
              }
            } else if (widget.jobItemModel.jobItemPercentage ==
                JobPercentConstant.percent34) {
              customCraftsmanModel.model.running =
                  customCraftsmanModel.model.running + 1;
              customCraftsmanModel.model.inJobIdsList
                  .add(widget.jobItemModel.jobId);
              if (widget.currentCraftsman != null) {
                widget.currentCraftsman!.running =
                    widget.currentCraftsman!.running - 1;
                widget.currentCraftsman!.inJobIdsList
                    .remove(widget.jobItemModel.jobId);
                updateCraftsmanWorkStatus(widget.currentCraftsman!);
              }
            }
          } else {
            customCraftsmanModel.model.appointed =
                customCraftsmanModel.model.appointed + 1;
          }

          widget.jobItemModel.selectedCraftsmanId =
              customCraftsmanModel.model.id;
          widget.jobItemModel.selectedCraftsmanName =
              customCraftsmanModel.model.personalDetailsModel.name;
          // widget.craftsmanList[index].appointed =
          //     customCraftsmanModel.model.appointed + 1;
          updateJobItemCraftsmanId(widget.jobItemModel);
          updateCraftsmanWorkStatus(customCraftsmanModel.model);
          Navigator.pop(context, customCraftsmanModel.model);
        }
      },
      child: Container(
        padding: EdgeInsets.all(15.sp),
        margin: EdgeInsets.only(top: 15.sp, left: 15.sp, right: 15.sp),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorManager.colorGrey,
            width: 5.sp,
          ),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customCraftsmanModel.model.personalDetailsModel.name,
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.bigExtra,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
                  decoration: BoxDecoration(
                      color: ColorManager.colorRed,
                      borderRadius: BorderRadius.circular(10.sp)),
                  child: Text(
                    customCraftsmanModel.remainingDays < 1
                        ? '<1 Day'
                        : customCraftsmanModel.remainingDays == 1
                            ? '1 Day'
                            : '${customCraftsmanModel.remainingDays.toStringAsFixed(1)} Days',
                    style: getMediumStyle(
                      color: ColorManager.textColorWhite,
                      fontSize: FontSize.medium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Text(
                      "Pending Job",
                      style: getRegularStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.small,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      '${(customCraftsmanModel.model.appointed + customCraftsmanModel.model.running) < 0 ? 0 : (customCraftsmanModel.model.appointed + customCraftsmanModel.model.running)}',
                      style: getMediumStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.big,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Working Capacity",
                      style: getRegularStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.small,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      customCraftsmanModel.model.serviceInfoModel.workCapacity
                          .toString(),
                      style: getMediumStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.big,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(workLoad * 100).toStringAsFixed(2)}%',
                  textAlign: TextAlign.right,
                  style: getMediumStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 10.sp,
              percent: workLoad.toDouble(),
              backgroundColor: ColorManager.colorLightWhite,
              progressColor: ColorManager.colorBlack,
              barRadius: Radius.circular(10.sp),
            ),
          ],
        ),
      ),
    );
  }
}
