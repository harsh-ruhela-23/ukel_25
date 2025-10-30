import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/constants.dart';
import '../../../../utils/app_utils.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../home/invoice/invoice_details_screen.dart';
import '../../home/invoice/job_status_screen.dart';

class RunningDoneStatusScreen extends StatefulWidget {
  const RunningDoneStatusScreen(
      {Key? key, required this.status, required this.jobList})
      : super(key: key);
  final String status;
  final List<JobItemModel> jobList;

  @override
  State<RunningDoneStatusScreen> createState() =>
      _RunningDoneStatusScreenState();
}

class _RunningDoneStatusScreenState extends State<RunningDoneStatusScreen> {
  List<JobItemModel> jobListByStatus = [];

  @override
  void initState() {
    super.initState();

    setData();
    setState(() {});
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
            (value, callback) {
              setData();
              setState(() {});
        }, context: context);
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  setData() {
    if (widget.jobList.isNotEmpty) {
      for (var element in widget.jobList) {
        print('element.jobItemPercentage ${element.jobItemPercentage}');
        if (widget.status == 'Appointed') {
          if (element.jobItemPercentage == '0' ||
              element.jobItemPercentage == '16') {
            jobListByStatus.add(element);
          }
        } else if (widget.status == 'Running') {
          if (element.jobItemPercentage == '34') {
            jobListByStatus.add(element);
          }
        } else if (widget.status == 'Done') {
          if (element.jobItemPercentage == '50' ||
              element.jobItemPercentage == '68' ||
              element.jobItemPercentage == '84' ||
              element.jobItemPercentage == '99' ||
              element.jobItemPercentage == '100') {
            jobListByStatus.add(element);
          }
        } else if (widget.status == 'QT') {
          if (element.jobItemPercentage == '99' ||
              element.jobItemPercentage == '100') {
            jobListByStatus.add(element);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () => AppUtils.navigateUp(context),
        title: "Work History",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.sp),

            Text(
              widget.status,
              style: getBoldStyle(
                color: ColorManager.btnColorDarkBlue,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 20.sp),

            // Text(
            //   '6, Tuesday',
            //   style: getRegularStyle(
            //     color: ColorManager.grey,
            //     fontSize: 15.5.sp,
            //   ),
            // ),
            // SizedBox(height: 5.sp),

            // Work History Status List
            jobListByStatus.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 35.sp),
                    child: const Center(
                      child: Text('No Jobs Available'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: jobListByStatus.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.sp),
                        child: JobItems(
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobStatusScreen(
                                    jobItemModel: jobListByStatus[index]),
                              ),
                            );
                          },
                          jobItemModel: jobListByStatus[index],
                        ),
                      );
                    },
                  ),
            SizedBox(height: 30.sp),
          ],
        ),
      ),
    );
  }
}
