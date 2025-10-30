import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/craftsman_app/ui/screens/crafstman_job_list_by_status.dart';
import 'package:ukel/craftsman_app/ui/screens/side_navigation_drawer.dart';
import 'package:ukel/craftsman_app/ui/screens/tabs/history_tab.dart';
import 'package:ukel/craftsman_app/ui/screens/tabs/todo_tab.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

class CraftsmanHomeScreen extends StatefulWidget {
  const CraftsmanHomeScreen({Key? key}) : super(key: key);

  static String routeName = "/craftsman_home_screen";

  @override
  State<CraftsmanHomeScreen> createState() => _CraftsmanHomeScreenState();
}

class _CraftsmanHomeScreenState extends State<CraftsmanHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<StatusItemModel> statusList = [
    StatusItemModel(
        status: "A", color: const Color(0xFFFFD54F), title: 'Appointed'),
    StatusItemModel(
        status: "R", color: const Color(0xFF4FCDFF), title: 'Running'),
    StatusItemModel(status: "D", color: const Color(0xFF79CB9D), title: 'Done'),
    StatusItemModel(
        status: "Q", color: const Color(0xFFA3B0C3), title: 'QT Passed'),
  ];

  String? craftsmanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    craftsmanId = Storage.getValue(FbConstant.uid);
    AppUtils().getAndSetGlobalServiceList();
    getJobListByStatusValue("A");
    getJobListByStatusValue("R");
    getJobListByStatusValue("D");
    getJobListByStatusValue("Q");
    if (craftsmanId != null) {
      getCraftsmanDetail(craftsmanId!);
    }
  }

  bool isCraftsmanFetchingData = false;
  final homeRepository = HomeRepository();
  CraftsmanModel? customCraftsmanModel;

  void getCraftsmanDetail(String id) async {
    try {
      if (!isCraftsmanFetchingData) {
        isCraftsmanFetchingData = true;

        await homeRepository.fetchCraftsmanDetail(id: id).then((data) {
          if (data != null) {
            customCraftsmanModel = data;
          }
        });
        isCraftsmanFetchingData = false;
      }
    } catch (e) {
      isCraftsmanFetchingData = false;
    }
    setState(() {});
  }

  int appointedCount = 0;
  int runningCount = 0;
  int doneCount = 0;
  int qtPassedCount = 0;

  Future getJobListByStatusValue(String statusValue) async {
    try {
      List<String> statusList = [];
      if (statusValue == "A") {
        statusList.add(JobPercentConstant.percent0);
        statusList.add(JobPercentConstant.percent16);
      } else if (statusValue == "R") {
        statusList.add(JobPercentConstant.percent34);
      } else if (statusValue == "D") {
        statusList.add(JobPercentConstant.percent50);
        statusList.add(JobPercentConstant.percent68);
        statusList.add(JobPercentConstant.percent84);
      } else if (statusValue == "Q") {
        statusList.add(JobPercentConstant.percent99);
      }

      await homeRepository
          .fetchJobListByCraftsmanStatus(statusList)
          .then((list) {
        if (list.isNotEmpty) {
          if (statusValue == "A") {
            appointedCount = list.length;
          }
          if (statusValue == "R") {
            runningCount = list.length;
          }
          if (statusValue == "D") {
            doneCount = list.length;
          }
          if (statusValue == "Q") {
            qtPassedCount = list.length;
          }
        }
        setState(() {});
      });
    } catch (e) {
      setState(() {});
    }
  }

  refreshScreen() {
    getJobListByStatusValue("A");
    getJobListByStatusValue("R");
    getJobListByStatusValue("D");
    getJobListByStatusValue("Q");
    if (craftsmanId != null) {
      getCraftsmanDetail(craftsmanId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: ColorManager.white,
              toolbarHeight: 32.sp,
              titleTextStyle: getBoldStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.mediumExtra,
              ),
              title: Text(
                'Ukel - Craftsman',
                style: getMediumStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: 18.sp,
                ),
              ),
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.only(left: 18.sp),
                child: GestureDetector(
                  onTap: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                  child: SvgPicture.asset(
                    IconAssets.iconMenu,
                    height: 8.sp,
                    width: 8.sp,
                  ),
                ),
              ),
              leadingWidth: 26.sp,
              actions: [
                //if (isToShowRefreshedIcon)
                GestureDetector(
                  onTap: () {
                    refreshScreen();
                  },
                  child: Icon(
                    Icons.refresh,
                    size: 23.sp,
                  ),
                ),
                SizedBox(
                  width: 15.sp,
                ),
              ],
            ),
            drawer: customCraftsmanModel != null
                ? SideNavigationDrawer(
                    onClose: () {
                      scaffoldKey.currentState!.closeDrawer();
                    },
                    customCraftsmanModel: customCraftsmanModel!,
                  )
                : const SizedBox(),
            body: Column(
              children: [
                // Status Section
                viewModel.isAllJobListFetchingData
                    ? buildLoadingWidget
                    : viewModel.getAllJobItemListError.isNotEmpty
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: 15.sp, bottom: 15.sp),
                            child: RefreshIndicator(
                              onRefresh: () async {
                                getCraftsmanDetail(
                                    await Storage.getValue(FbConstant.uid));
                              },
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
                                            builder: (context) =>
                                                CraftsmanJobListByStatus(
                                              appBarTitle:
                                                  statusList[index].title,
                                              statusValue:
                                                  statusList[index].status,
                                              craftsmanModel:
                                                  customCraftsmanModel,
                                            ),
                                          ),
                                        );
                                      },
                                      child: StatusItemWidget(
                                        index: index,
                                        data: statusList[index],
                                        craftsmanData: customCraftsmanModel,
                                        appointedCount: appointedCount,
                                        runningCount: runningCount,
                                        doneCount: doneCount,
                                        qtPassedCount: qtPassedCount,
                                      ),
                                    );
                                  },
                                ),
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
                        Tab(text: "History"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    child: TabBarView(
                      controller: _tabController,
                      //  physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TodoTab(
                          homeViewModel: viewModel,
                          craftsmanId: Storage.getValue(FbConstant.uid),
                        ),
                        HistoryTab(
                          homeViewModel: viewModel,
                          craftsmanId: Storage.getValue(FbConstant.uid),
                        ),
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
      this.craftsmanData,
      required this.appointedCount,
      required this.runningCount,
      required this.doneCount,
      required this.qtPassedCount})
      : super(key: key);

  final int index, appointedCount, runningCount, doneCount, qtPassedCount;
  final StatusItemModel data;
  final CraftsmanModel? craftsmanData;

  @override
  Widget build(BuildContext context) {
    print(
        "A: $appointedCount, R: $runningCount, D: $doneCount, Q: $qtPassedCount");

    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 15.sp : 0.sp, right: 15.sp),
      child: Stack(
        children: [
          Container(
            width: 60.sp,
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(15.sp),
            ),
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
                      craftsmanData != null
                          ? data.status == "A"
                              ? "$appointedCount Jobs"
                              : data.status == "R"
                                  ? "$runningCount Jobs"
                                  : data.status == "D"
                                      ? "$doneCount Jobs"
                                      : data.status == "Q"
                                          ? "$qtPassedCount Jobs"
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
  String status;
  String title;
  Color color;

  StatusItemModel(
      {required this.status, required this.title, required this.color});
}
