import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

import 'home_tab/delivery_tab.dart';
import 'home_tab/job_tab.dart';
import 'home_tab/todo_tab.dart';
import 'job_list_by_status/job_list_by_status.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.isHomeScreenRefreshed}) : super(key: key);
  bool isHomeScreenRefreshed;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<StatusItemModel> statusList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Provider.of<HomeViewModel>(context, listen: false).getAllJobItemList();
    setData();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      Provider.of<HomeViewModel>(context, listen: false).getAllJobItemList();
    }, context: context);
  }

  onRefreshClick() {
    Provider.of<HomeViewModel>(context, listen: false).getAllJobItemList();
    setData();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      Provider.of<HomeViewModel>(context, listen: false).getAllJobItemList();
    }, context: context);
    widget.isHomeScreenRefreshed = false;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHomeScreenRefreshed) {
      onRefreshClick();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    FBroadcast.instance().unregister(context);
  }

  setData() {
    statusList.clear();
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent0,
        title: AppConstant.inShop,
        color: const Color(0xFFFFD54F)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent16,
        title: AppConstant.shipment,
        color: const Color(0xFF4FCDFF)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent34,
        title: AppConstant.inProcess,
        color: const Color(0xFF4FCDFF)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent50,
        title: AppConstant.pickUp,
        color: const Color(0xFFA3B0C3)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent84,
        title: AppConstant.packingQt,
        color: const Color(0xFF877EFD)));
    statusList.add(StatusItemModel(
        jobStatusValue: JobPercentConstant.percent99,
        title: AppConstant.tobeDeliver,
        color: const Color(0xFF79CB9D)));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Status Section
                viewModel.isAllJobListFetchingData
                    ? buildLoadingWidget
                    : viewModel.getAllJobItemListError.isNotEmpty
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: 15.sp, bottom: 15.sp),
                            child: SizedBox(
                              height: 40.sp,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: statusList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JobListByStatus(
                                              appBarTitle:
                                                  statusList[index].title,
                                              statusValue: statusList[index]
                                                  .jobStatusValue),
                                        ),
                                      );
                                    },
                                    child: StatusItemWidget(
                                        allJobItemList:
                                            viewModel.allJobItemList,
                                        index: index,
                                        data: statusList[index]),
                                  );
                                },
                              ),
                            ),
                          ),

                // Tab Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.0),
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.3), width: 2.7),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                            color: ColorManager.textColorBlack, width: 6.sp),
                      ),
                      labelColor: ColorManager.textColorBlack,
                      unselectedLabelColor: ColorManager.textColorGrey,
                      labelStyle: getSemiBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.bigExtra),
                      unselectedLabelStyle: getSemiBoldStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.bigExtra),
                      tabs: const [
                        Tab(text: "To Do"),
                        Tab(text: "Delivery"),
                        Tab(text: "Job"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ToDoTab(homeViewModel: viewModel),
                        DeliveryTab(viewModel: viewModel),
                        JobTab(viewModel: viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StatusItemWidget extends StatelessWidget {
  const StatusItemWidget(
      {Key? key,
      required this.index,
      required this.data,
      required this.allJobItemList})
      : super(key: key);

  final int index;
  final StatusItemModel data;
  final List<JobItemModel> allJobItemList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 15.sp : 0.sp, right: 15.sp),
      child: Stack(
        children: [
          Container(
            width: 60.sp,
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
                color: data.color, borderRadius: BorderRadius.circular(15.sp)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: getBoldStyle(
                    color: ColorManager.textColorWhite,
                    fontSize: FontSize.large,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      //data.subTitle,
                      allJobItemList.isNotEmpty
                          ? data.title == AppConstant.inShop
                              ? AppUtils.getTotalInShopJobs(
                                  allJobList: allJobItemList)
                              : data.title == AppConstant.inProcess
                                  ? AppUtils.getTotalInProcessJobs(
                                      allJobList: allJobItemList)
                                  : data.title == AppConstant.shipment
                                      ? AppUtils.getTotalShipmentJobs(
                                          allJobList: allJobItemList)
                                      : data.title == AppConstant.pickUp
                                          ? AppUtils.getTotalPickUpJobs(
                                              allJobList: allJobItemList)
                                          : data.title == AppConstant.packingQt
                                              ? AppUtils.getTotalPackingQtJobs(
                                                  allJobList: allJobItemList)
                                              : data.title ==
                                                      AppConstant.tobeDeliver
                                                  ? AppUtils
                                                      .getTotalToBeDeliveredJobs(
                                                          allJobList:
                                                              allJobItemList)
                                                  : '0 Job'
                          : '0 Job',
                      style: getBoldStyle(
                        color: ColorManager.textColorWhite,
                        fontSize: FontSize.bigExtra,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Go >",
                      style: getBoldStyle(
                        color: ColorManager.textColorWhite,
                        fontSize: FontSize.bigExtra,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -18.sp,
            right: -18.sp,
            child: Container(
              height: 33.sp,
              width: 33.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 8,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StatusItemModel {
  String title;
  String jobStatusValue;
  Color color;

  StatusItemModel(
      {required this.title, required this.color, required this.jobStatusValue});
}
