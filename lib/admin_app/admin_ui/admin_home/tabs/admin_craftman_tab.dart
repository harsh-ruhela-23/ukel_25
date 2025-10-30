import 'dart:core';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/other/custom_craftman_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/branch_management/widgets/craftman_work_history_screen.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/title_value_card_widget.dart';

class AdminCraftManTab extends StatefulWidget {
  const AdminCraftManTab({Key? key, this.branchId}) : super(key: key);

  final String? branchId;

  @override
  State<AdminCraftManTab> createState() => _AdminCraftManTabState();
}

class _AdminCraftManTabState extends State<AdminCraftManTab> {
  // for craftsman
  bool isCraftsmanListFetchingData = false;
  final homeRepository = HomeRepository();
  String error = '';
  double totalPayment = 0.0;

  List<CustomCraftsmanModel> searchResult = [];
  TextEditingController searchController = TextEditingController();

  List<CustomCraftsmanModel> craftsmanList = [];

  @override
  void initState() {
    super.initState();
    getCraftsmanList();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      getCraftsmanList();
    }, context: context);
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  void getCraftsmanList() async {
    craftsmanList.clear();
    totalPayment = 0;
    try {
      if (!isCraftsmanListFetchingData) {
        isCraftsmanListFetchingData = true;
        print("widget.branchId");
        print(widget.branchId);
        await homeRepository
            .fetchCraftsmanList(branchId: widget.branchId)
            .then((list) {
          if (list.isNotEmpty) {
            for (var element in list) {
              totalPayment = totalPayment +
                  (element.qtPassed * element.serviceInfoModel.serviceCharges);
              craftsmanList.add(CustomCraftsmanModel(
                model: element,
                remainingDays:
                    AppUtils.calculateCraftsmanIndividualRemainingDays(
                                element) ==
                            null
                        ? 0
                        : AppUtils.calculateCraftsmanIndividualRemainingDays(
                            element)!,
              ));
            }
          }
        });

        error = '';
        isCraftsmanListFetchingData = false;
      }
    } catch (e) {
      isCraftsmanListFetchingData = false;
      error = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('craftsmanList ${craftsmanList.length}');
    print('errro ${error}');
    print('isCraftsmanListFetchingData ${isCraftsmanListFetchingData}');

    return RefreshIndicator(
      onRefresh: () async {
        isCraftsmanListFetchingData = false;
        error = '';
        setState(() {});
        getCraftsmanList();
      },
      child: SafeArea(
        child: Scaffold(
          body: ListView(
            children: [
              SizedBox(height: 15.sp),

              // Craftsman
              isCraftsmanListFetchingData
                  ? buildLoadingWidget
                  : error.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.38,
                          ),
                          child: buildEmptyDataWidget(error.toString()),
                        )
                      : craftsmanList.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.38,
                              ),
                              child: buildEmptyDataWidget(
                                  "No Craftsman Available!!"),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TitleValueCardWidget(
                                        title: craftsmanList.isNotEmpty
                                            ? craftsmanList.length.toString()
                                            : '0',
                                        value: 'Working Craftsman',
                                      ),
                                    ),
                                    SizedBox(width: 15.sp),
                                    Expanded(
                                      child: TitleValueCardWidget(
                                        title: totalPayment.toStringAsFixed(2),
                                        value: 'Total Payment',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.sp),
                                searchResult.isNotEmpty ||
                                        searchController.text.isNotEmpty
                                    ? buildSearchResultList()
                                    : buildCraftsmanList(),
                              ],
                            ),
              SizedBox(height: 30.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchResultList() {
    return searchResult.isEmpty
        ? buildEmptyDataWidget("No Result Found!!")
        : SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResult.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.sp),
                  child: craftManItemCard(searchResult, searchResult[index]),
                );
              },
            ),
          );
  }

  Widget buildCraftsmanList() {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: craftsmanList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 15.sp),
            child: craftManItemCard(craftsmanList, craftsmanList[index]),
          );
        },
      ),
    );
  }

  Widget buildSearchCraftMan() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            autofocus: false,
            controller: searchController,
            onChanged: (val) => onSearchTextChanged(val),
            decoration: InputDecoration(
              suffixIcon: searchController.text.isEmpty
                  ? const SizedBox()
                  : InkWell(
                      child: const Icon(Icons.close, color: Colors.black),
                      onTap: () {
                        searchController.clear();
                        onSearchTextChanged('');
                      },
                    ),
              contentPadding: isTablet
                  ? EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp)
                  : EdgeInsets.symmetric(horizontal: 15.sp),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: BorderSide(
                  width: 2.sp,
                  color: Colors.grey,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: BorderSide(
                  width: 2.sp,
                  color: Colors.grey,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: BorderSide(
                  width: 2.sp,
                  color: Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: BorderSide(
                  width: 2.sp,
                  color: Colors.grey,
                ),
              ),
              hintText: 'Search Craftsman',
              hintStyle: getRegularStyle(
                color: ColorManager.colorGrey,
                fontSize: FontSize.mediumExtra,
              ),
            ),
          ),
        ),
        SizedBox(width: 13.sp),
        SvgPicture.asset(IconAssets.iconSearchCraftman, height: 28.sp),
      ],
    );
  }

  onSearchTextChanged(String text) async {
    searchResult.clear();
    // if (text.isEmpty) {
    //   setState(() {});
    //   return;
    // }

    for (var craftsmanDetail in craftsmanList) {
      if (craftsmanDetail.model.personalDetailsModel.name.contains(text) ||
          craftsmanDetail.model.personalDetailsModel.name
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          craftsmanDetail.model.serviceInfoModel.serviceType.contains(text) ||
          craftsmanDetail.model.serviceInfoModel.serviceType
              .toLowerCase()
              .contains(text.toLowerCase())) {
        searchResult.add(craftsmanDetail);
      }
    }

    setState(() {});
  }

  // craftManItemCard
  Widget craftManItemCard(List<CustomCraftsmanModel> customCraftsmanList,
      CustomCraftsmanModel customCraftsmanModel) {
    double workLoad = AppUtils.getCraftsmanWorkLoad(
        customCraftsmanList,
        customCraftsmanModel.remainingDays,
        customCraftsmanModel.model.serviceInfoModel.serviceType);

    return InkWell(
      onTap: () {
        // navigate to workHistory Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CraftManWorkHistoryScreen(
              customCraftsmanModel: customCraftsmanModel,
              workLoad: workLoad,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(17.sp),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorManager.colorLightGrey,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Column(
          children: [
            craftManCardRowText(
                key: customCraftsmanModel.model.personalDetailsModel.name,
                value: (customCraftsmanModel.model.qtPassed *
                        customCraftsmanModel
                            .model.serviceInfoModel.serviceCharges)
                    .toStringAsFixed(2),
                valueColor: ColorManager.textColorBlack),
            SizedBox(height: 5.sp),
            // craftManCardRowText(
            //     key: customCraftsmanModel.model.serviceInfoModel.serviceType,
            //     value: 'Appointed : ${customCraftsmanModel.model.appointed}',
            //     keyTextSize: FontSize.mediumExtra,
            //     valueColor: ColorManager.textColorGrey),
            // SizedBox(height: 5.sp),
            craftManCardRowText(
                key:
                    customCraftsmanModel.model.serviceInfoModel.workingLocation,
                value: 'Running : ${customCraftsmanModel.model.running}',
                keyTextSize: FontSize.mediumExtra,
                valueColor: ColorManager.textColorGrey),
            SizedBox(height: 5.sp),
            craftManCardRowText(
                key: customCraftsmanModel.model.serviceInfoModel.serviceType,
                value: 'Done : ${customCraftsmanModel.model.done}',
                keyTextSize: FontSize.mediumExtra,
                valueColor: ColorManager.textColorBlack),
            SizedBox(height: 5.sp),
            craftManCardRowText(
                key:
                    'Working Capacity : ${customCraftsmanModel.model.serviceInfoModel.workCapacity.toString()} Days',
                value: 'QT Passed : ${customCraftsmanModel.model.qtPassed}',
                keyTextSize: FontSize.mediumExtra,
                valueColor: ColorManager.textColorBlack),
            SizedBox(height: 5.sp),
            craftManCardRowText(
                key: 'Work Load',
                value: '${(workLoad * 100).toStringAsFixed(2)}%',
                keyTextSize: FontSize.mediumExtra,
                valueColor: ColorManager.textColorGrey),
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

  Widget craftManCardRowText(
      {required String key,
      required String value,
      required Color valueColor,
      double? keyTextSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: getMediumStyle(
            color: ColorManager.textColorBlack,
            fontSize: keyTextSize ?? FontSize.bigExtra,
          ),
        ),
        Text(
          value,
          style: getMediumStyle(
            color: valueColor,
            fontSize: FontSize.mediumExtra,
          ),
        ),
      ],
    );
  }
}
