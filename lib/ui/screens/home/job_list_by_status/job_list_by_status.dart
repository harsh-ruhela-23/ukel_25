import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/home_tab/todo_tab.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/widgets/custom_app_bar.dart';

import '../../../../utils/constants.dart';

class JobListByStatus extends StatefulWidget {
  const JobListByStatus(
      {Key? key,
      required this.appBarTitle,
      required this.statusValue,
      this.branchId})
      : super(key: key);
  final String appBarTitle;
  final String statusValue;
  final String? branchId;

  @override
  State<JobListByStatus> createState() => _JobListByStatusState();
}

class _JobListByStatusState extends State<JobListByStatus> {
  List<JobItemModel> jobListByStatus = [];
  bool isGetJobListFetchingData = false;
  String error = '';

  HomeRepository homeRepository = HomeRepository();

  @override
  void initState() {
    super.initState();
    getJobListByStatusValue();
    if (widget.statusValue == JobPercentConstant.percent16) {
      isGetJobListFetchingData = false;
      getShipmentJobList();
    }
  }

  // getJobListByStatusValue
  Future getJobListByStatusValue() async {
    try {
      jobListByStatus.clear();
      if (!isGetJobListFetchingData) {
        isGetJobListFetchingData = true;

        await homeRepository
            .fetchJobListByJobStatus(
                status: widget.statusValue, branchId: widget.branchId)
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

  // getShipmentJobList
  Future getShipmentJobList() async {
    try {
      if (!isGetJobListFetchingData) {
        isGetJobListFetchingData = true;

        await homeRepository
            .fetchJobListByJobStatus(
                status: JobPercentConstant.percent68, branchId: widget.branchId)
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
  void dispose() {
    super.dispose();
    jobListByStatus.clear();
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
