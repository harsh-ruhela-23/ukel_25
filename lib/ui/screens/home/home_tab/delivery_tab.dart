import 'package:collection/collection.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_tab/job_tab.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';
import 'package:ukel/ui/screens/home/invoice/invoice_details_screen.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

import '../../../../model/service_invoice_model.dart';

class DeliveryTab extends StatefulWidget {
  const DeliveryTab({Key? key, required this.viewModel}) : super(key: key);
  final HomeViewModel viewModel;

  @override
  State<DeliveryTab> createState() => _DeliveryTabState();
}

class _DeliveryTabState extends State<DeliveryTab> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.getJobList();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      widget.viewModel.getJobList();
      widget.viewModel.getAllJobItemList();
    }, context: context);
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  @override
  Widget build(BuildContext context) {
  //  widget.viewModel.jobList.sort((a, b) => b.jobItemDueDate.compareTo(a.jobItemDueDate));
    return widget.viewModel.isJobListFetchingData
        ? buildLoadingWidget
        : widget.viewModel.getJobListApiError.isNotEmpty
            ? buildErrorWidget(widget.viewModel.getJobListApiError)
            : widget.viewModel.jobList.isEmpty
                ? buildEmptyDataWidget('No Jobs Available!!')
                : Padding(
                    padding: EdgeInsets.only(top: 18.sp),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await widget.viewModel.getJobList();
                        setState(() {});
                      },
                      child: GroupedListView(
                        //reverse: true,
                        sort: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        elements: widget.viewModel.jobList,
                        groupBy: (element) {
                          return AppUtils.parseDate(
                              element
                                  .serviceInvoiceDueDate.millisecondsSinceEpoch,
                              AppConstant.yMMMMd);
                        },
                        groupSeparatorBuilder: (String groupByValue) => Padding(
                          padding: EdgeInsets.only(bottom: 18.sp),
                          child: Text(
                            groupByValue,
                            style: getBoldStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.big),
                          ),
                        ),
                        indexedItemBuilder: (context, element, index) =>
                            InkWell(
                          onTap: () {
                            print('id ${element.serviceInvoiceId}');

                            // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                            if (element.serviceInvoiceStatusValue == -1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceInvoiceScreen(
                                      model: element, isUpdate: true),
                                ),
                              );
                            } else {
                              // navigate to InvoiceDetailScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InvoiceDetailsScreen(model: element),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  widget.viewModel.getJobList();
                                  setState(() {});
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == widget.viewModel.jobList.length - 1
                                        ? 28.sp
                                        : 0),
                            child: DeliveryJobItem(
                                allJobList: widget.viewModel.allJobItemList,
                                serviceInvoiceModel: element),
                          ),
                        ),
                        itemComparator: (item1, item2) => item1
                            .serviceInvoiceDueDate
                            .compareTo(item2.serviceInvoiceDueDate),
                        order: GroupedListOrder.DESC,
                      ),
                      //  child: buildGroupedListView(widget.viewModel.jobList),
                    ),
                  );
  }

  Widget buildGroupedListView(List<ServiceInvoiceModel> jobList) {
    Map<int, List<ServiceInvoiceModel>> groupByDate = groupBy(
        widget.viewModel.jobList, (obj) => obj.serviceInvoiceDueDate.seconds);
var sortedKeys = groupByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (BuildContext context, int index) {


        var date = sortedKeys[index];

        var list = groupByDate.values.toList()[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(bottom: 18.sp, left: 6.0),
              child: Text(
                AppUtils.parseDate(date, AppConstant.yMMMMd),
                style: getBoldStyle(
                    color: ColorManager.textColorBlack, fontSize: FontSize.big),
              ),
            ),

            // Group
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                var listItem = list[index];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == list.length - 1 ? 8.sp : 0),
                  child: InkWell(
                    onTap: () {
                      // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                      if (listItem.serviceInvoiceStatusValue == -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceInvoiceScreen(
                                model: listItem, isUpdate: true),
                          ),
                        );
                      } else {
                        // navigate to InvoiceDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoiceDetailsScreen(model: listItem),
                          ),
                        ).then((value) {
                          if (value == true) {
                            widget.viewModel.getJobList();
                            setState(() {});
                          }
                        });
                      }
                    },
                    child: DeliveryJobItem(
                      allJobList: widget.viewModel.allJobItemList,
                      serviceInvoiceModel: listItem,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
