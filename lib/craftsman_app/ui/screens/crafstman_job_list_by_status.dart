import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/home_tab/todo_tab.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

class CraftsmanJobListByStatus extends StatefulWidget {
  const CraftsmanJobListByStatus(
      {Key? key,
      required this.appBarTitle,
      required this.statusValue,
      this.craftsmanModel})
      : super(key: key);

  final String appBarTitle;
  final String statusValue;
  final CraftsmanModel? craftsmanModel;

  @override
  State<CraftsmanJobListByStatus> createState() =>
      _CraftsmanJobListByStatusState();
}

class _CraftsmanJobListByStatusState extends State<CraftsmanJobListByStatus> {
  List<JobItemModel> jobListByStatus = [];
  bool isGetJobListFetchingData = false;
  String error = '';

  HomeRepository homeRepository = HomeRepository();

  @override
  void initState() {
    super.initState();
    getJobListByStatusValue();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      getJobListByStatusValue();
    }, context: context);
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  Future getJobListByStatusValue() async {
    try {
      jobListByStatus.clear();
      if (!isGetJobListFetchingData) {
        isGetJobListFetchingData = true;

        List<String> statusList = [];
        if (widget.statusValue == "A") {
          statusList.add(JobPercentConstant.percent0);
          statusList.add(JobPercentConstant.percent16);
        } else if (widget.statusValue == "R") {
          statusList.add(JobPercentConstant.percent34);
        } else if (widget.statusValue == "D") {
          statusList.add(JobPercentConstant.percent50);
          statusList.add(JobPercentConstant.percent68);
          statusList.add(JobPercentConstant.percent84);
        } else if (widget.statusValue == "Q") {
          statusList.add(JobPercentConstant.percent99);
        }

        await homeRepository
            .fetchJobListByCraftsmanStatus(statusList)
            .then((list) {
          if (list.isNotEmpty) {
            jobListByStatus.addAll(list);
          }
        });

        error = '';
        isGetJobListFetchingData = false;
        setState(() {});
      }
    } catch (e) {
      isGetJobListFetchingData = false;
      error = e.toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () => AppUtils.navigateUp(context),
          title: widget.appBarTitle,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 15.sp, right: 15.sp, bottom: 20.sp),
          child: isGetJobListFetchingData
              ? buildLoadingWidget
              : error.isNotEmpty
                  ? buildErrorWidget(error)
                  : jobListByStatus.isEmpty
                      ? buildEmptyDataWidget('No Jobs Available!!')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: jobListByStatus.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobStatusScreen(
                                      jobItemModel: jobListByStatus[index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: index == jobListByStatus.length - 1
                                        ? 40.sp
                                        : 0),
                                child: ToDoItems(item: jobListByStatus[index]),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
