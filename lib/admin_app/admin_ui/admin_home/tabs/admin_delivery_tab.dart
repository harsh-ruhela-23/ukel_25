import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../resource/color_manager.dart';
import '../../../../resource/fonts_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../ui/screens/home/home_screen.dart';
import '../../../../ui/screens/home/home_tab/job_tab.dart';
import '../../../../ui/screens/home/home_view_model.dart';
import '../../../../ui/screens/home/invoice/invoice_details_screen.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/common_widget.dart';
import '../../../../utils/constants.dart';

class AdminDeliveryTab extends StatefulWidget {
  const AdminDeliveryTab({super.key, this.branchId});

  final String? branchId;

  @override
  State<AdminDeliveryTab> createState() => _AdminDeliveryTabState();
}

class _AdminDeliveryTabState extends State<AdminDeliveryTab> {
  List<StatusItemModel> statusList = [];

  @override
  void initState() {
    super.initState();
    Provider.of<HomeViewModel>(context, listen: false)
        .getJobList(branchId: widget.branchId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: viewModel.isJobListFetchingData
                ? buildLoadingWidget
                : viewModel.getJobListApiError.isNotEmpty
                    ? buildErrorWidget(viewModel.getJobListApiError)
                    : viewModel.jobList.isEmpty
                        ? buildEmptyDataWidget('No Jobs Available!!')
                        : Padding(
                            padding: EdgeInsets.only(top: 18.sp),
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await viewModel.getJobList();
                                setState(() {});
                              },
                              child: GroupedListView(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                elements: viewModel.jobList,
                                groupBy: (element) => AppUtils.parseDate(
                                    element.serviceInvoiceDueDate
                                        .millisecondsSinceEpoch,
                                    AppConstant.yMMMMd),
                                groupSeparatorBuilder: (String groupByValue) =>
                                    Padding(
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
                                    // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                                    if (element.serviceInvoiceStatusValue ==
                                        -1) {
                                      AppUtils.showToast(
                                          'This Job is Incomplete');
                                    } else {
                                      // navigate to InvoiceDetailScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InvoiceDetailsScreen(
                                                  model: element),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index ==
                                                viewModel.jobList.length - 1
                                            ? 28.sp
                                            : 0),
                                    child: DeliveryJobItem(
                                        allJobList: viewModel.allJobItemList,
                                        serviceInvoiceModel: element),
                                  ),
                                ),
                                itemComparator: (item1, item2) => item1
                                    .serviceInvoiceDueDate
                                    .compareTo(item2.serviceInvoiceDueDate),
                                order: GroupedListOrder.DESC,
                              ),
                            ),
                          ),
          ),
        );
      },
    );
  }
}
