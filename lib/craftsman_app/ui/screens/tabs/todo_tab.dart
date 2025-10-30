import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';

class TodoTab extends StatefulWidget {
  const TodoTab(
      {Key? key, required this.homeViewModel, required this.craftsmanId})
      : super(key: key);

  final HomeViewModel homeViewModel;
  final String craftsmanId;

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  List<JobItemModel> todoJobList = [];

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  void getTodoList() async {
    await widget.homeViewModel
        .getAllJobsCraftsman(widget.craftsmanId);
    todoJobList.clear();
    print("todolist = ${todoJobList.length}");
    todoJobList =
        await widget.homeViewModel.getAllTodoJobsCraftsman(widget.craftsmanId);
    print("todolist = ${todoJobList.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return todoJobList.isEmpty
        ? Center(
            child: Text(
              'No TODO Available!!',
              style: getBoldStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.bigExtra),
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              getTodoList();
            },
            child: Column(
              children: [
                Expanded(
                  child: GroupedListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    elements: todoJobList,
                    groupBy: (element) => AppUtils.parseDate(
                        element.jobItemCreatedAtDate, AppConstant.yMMMMd),
                    groupSeparatorBuilder: (String groupByValue) => Padding(
                      padding: EdgeInsets.only(top:15.sp, bottom: 5.sp),
                      child: Text(
                        groupByValue,
                        style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.big),
                      ),
                    ),
                    indexedItemBuilder: (context, element, index) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobStatusScreen(
                              jobItemModel: todoJobList[index],
                            ),
                          ),
                        );
                      },
                      child: ToDoItems(item: todoJobList[index]),
                    ),
                    itemComparator: (item1, item2) => item1
                        .jobItemCreatedAtDate
                        .compareTo(item2.jobItemCreatedAtDate),
                    order: GroupedListOrder.DESC,
                  ),
                  // ListView.builder(
                  //   physics: const AlwaysScrollableScrollPhysics(),
                  //   shrinkWrap: true,
                  //   itemCount: historyJobList.length,
                  //   itemBuilder: (context, index) {
                  //     return Padding(
                  //       padding: EdgeInsets.only(
                  //           bottom:
                  //               index == historyJobList.length - 1 ? 40.sp : 0),
                  //       child: InkWell(
                  //         onTap: () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => JobStatusScreen(
                  //                 jobItemModel: historyJobList[index],
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //         child: HistoryItems(item: historyJobList[index]),
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
              ],
            ),
          );
  }
}

// Job Item
class ToDoItems extends StatelessWidget {
  const ToDoItems({Key? key, required this.item}) : super(key: key);
  final JobItemModel item;

  int getPercentage(double value) {
    return (value * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15.sp),
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ColorManager.colorGrey,
          width: 2.sp,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularPercentIndicator(
            radius: 22.sp,
            lineWidth: 5.0,
            percent: AppUtils.getPercentageForIndicator(item.jobItemPercentage),
            center: Text(
              "${item.jobItemPercentage}%",
              style: getMediumStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.small,
              ),
            ),
            progressColor:
                AppUtils.getProgressIndicatorColor(item.jobItemPercentage),
            backgroundColor:
                AppUtils.getProgressIndicatorColor(item.jobItemPercentage)
                    .withOpacity(0.3),
          ),
          SizedBox(width: 15.sp),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.customerModel.name,
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                    ),
                    Text(
                      '#${item.jobItemCode}',
                      style: getMediumStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: FontSize.medium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.selectedCraftsmanName.isEmpty
                            ? '-'
                            : item.selectedCraftsmanName,
                        style: getMediumStyle(
                          color: ColorManager.textColorGrey,
                          fontSize: FontSize.medium,
                        ),
                      ),
                    ),
                    Text(
                      AppUtils.getJobStatusName(item.jobItemPercentage),
                      style: getMediumStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.medium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Due:",
                            style: getMediumStyle(
                              color: ColorManager.textColorBlack,
                              fontSize: FontSize.medium,
                            ),
                          ),
                          Text(
                            AppUtils.parseDate(
                                item.jobItemDueDate, AppConstant.yMMMMd),
                            style: getMediumStyle(
                              color: ColorManager.textColorGrey,
                              fontSize: FontSize.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppUtils.parseDate(
                          item.jobItemCreatedAtDate, AppConstant.yMMMMd),
                      style: getMediumStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
