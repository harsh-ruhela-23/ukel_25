import 'dart:developer';
import 'dart:math' as math;

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/custom_craftman_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/invoice/invoice_details_screen.dart';
import 'package:ukel/ui/screens/home/invoice/job_status_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/other_widgets.dart';

import 'about_craftsman_screen.dart';
import 'running_done_status_screen.dart';

class CraftManWorkHistoryScreen extends StatefulWidget {
  const CraftManWorkHistoryScreen(
      {Key? key, required this.customCraftsmanModel, required this.workLoad})
      : super(key: key);
  final CustomCraftsmanModel customCraftsmanModel;
  final double workLoad;

  @override
  State<CraftManWorkHistoryScreen> createState() =>
      _CraftManWorkHistoryScreenState();
}

class _CraftManWorkHistoryScreenState extends State<CraftManWorkHistoryScreen> {
  // for craftsman
  List<JobItemModel> jobItemList = [];
  List<JobItemModel> allJobItemList = [];
  bool isJobListFetchingData = false;
  bool isCraftsmanFetchingData = false;
  final homeRepository = HomeRepository();
  String error = '';
  List<String> jobStatuses = [];
  Map<String, List<JobItemModel>> groupedJobItems = {};
  List<String> _serviceCapacityOptions = [];
  String? _selectedJobStatus;
  Map<String, double> _servicePriceMap = {};

  @override
  void initState() {
    super.initState();
    _updateServiceCapacityOptions(triggerSetState: false);
    getJobListByCraftsmanId();
    FBroadcast.instance().register(BroadCastConstant.homeScreenUpdate,
        (value, callback) {
      getJobListByCraftsmanId();
      getCraftsmanDetail();
    }, context: context);

  }

  Map<String, List<JobItemModel>> groupJobsByStatus(List<JobItemModel> jobs) {
    Map<String, List<JobItemModel>> groupedJobs = {};
    for (var job in jobs) {
      String status =
          AppUtils().getServiceNameById(serviceId: job.jobItemServiceId);
      if (!groupedJobs.containsKey(status)) {
        groupedJobs[status] = [];
      }
      groupedJobs[status]!.add(job);
    }
    return groupedJobs;
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(context);
  }

  void getJobListByCraftsmanId() async {
    jobItemList.clear();
    allJobItemList.clear();
    try {
      if (!isJobListFetchingData) {
        isJobListFetchingData = true;
        print("customCraftsmanModel");
        print(widget.customCraftsmanModel.model.id);
        await homeRepository
            .fetchJobListByCraftsmanId(widget.customCraftsmanModel.model.id)
            .then((list) {
          if (list.isNotEmpty) {
            print("groupJobsByStatus");
            allJobItemList
              ..clear()
              ..addAll(list);
            if (mounted) {
              setState(() {
                _applyJobGrouping(list);
              });
            }
          } else {
            if (mounted) {
              setState(() {
                allJobItemList.clear();
                jobItemList.clear();
                jobStatuses = [];
                groupedJobItems = {};
                _selectedJobStatus = null;
                _recalculateTotalSalary();
              });
            }
          }
          print("groupJobsByStatus1");
        });
        error = '';
        isJobListFetchingData = false;
      }
    } catch (e) {
      isJobListFetchingData = false;
      error = e.toString();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void getCraftsmanDetail() async {
    try {
      if (!isCraftsmanFetchingData) {
        isCraftsmanFetchingData = true;

        await homeRepository
            .fetchCraftsmanDetail(id: widget.customCraftsmanModel.model.id)
            .then((data) {
          if (data != null) {
            setState(() {
              widget.customCraftsmanModel.model = data;
              _updateServiceCapacityOptions(triggerSetState: false);
              _recalculateTotalSalary();
            });
          }
        });
        error = '';
        isCraftsmanFetchingData = false;
      }
    } catch (e) {
      isCraftsmanFetchingData = false;
      error = e.toString();
    }
    if (mounted) {
      setState(() {});
    }
  }
  RxDouble amountTotal = 0.0.obs;

  void _updateServiceCapacityOptions({bool triggerSetState = true}) {
    final options = _generateServiceCapacityOptions();
    final priceMap = _buildServicePriceMap();

    if (triggerSetState) {
      setState(() {
        _serviceCapacityOptions = options;
        _servicePriceMap = priceMap;
      });
    } else {
      _serviceCapacityOptions = options;
      _servicePriceMap = priceMap;
    }

    _recalculateTotalSalary();
  }

  List<String> _generateServiceCapacityOptions() {
    final serviceInfo = widget.customCraftsmanModel.model.serviceInfoModel;
    final serviceNames = serviceInfo.selectedServiceNames ?? [];
    final serviceCapacities = serviceInfo.selectedServiceCapacity ?? [];
    final options = <String>[];

    final maxLength = math.max(serviceNames.length, serviceCapacities.length);
    for (var i = 0; i < maxLength; i++) {
      final name = i < serviceNames.length ? serviceNames[i].trim() : '';
      final capacityRaw =
          i < serviceCapacities.length ? serviceCapacities[i].trim() : '';

      if (name.isEmpty && capacityRaw.isEmpty) {
        continue;
      }

      final capacityLabel = _formatCapacityLabel(capacityRaw);
      final optionLabel = name.isNotEmpty && capacityLabel.isNotEmpty
          ? '$name - $capacityLabel'
          : name.isNotEmpty
              ? name
              : capacityLabel;

      options.add(optionLabel);
    }

    return options;
  }

  String _formatCapacityLabel(String capacity) {
    if (capacity.isEmpty) {
      return '';
    }

    final trimmed = capacity.trim();
    if (num.tryParse(trimmed) != null) {
      return trimmed;
    }

    return trimmed;
  }

  Map<String, double> _buildServicePriceMap() {
    final serviceInfo = widget.customCraftsmanModel.model.serviceInfoModel;
    final serviceNames = serviceInfo.selectedServiceNames ?? [];
    final servicePrices = serviceInfo.selectedServicePrice ?? [];
    final priceMap = <String, double>{};

    final maxLength = math.max(serviceNames.length, servicePrices.length);
    for (var i = 0; i < maxLength; i++) {
      final name = i < serviceNames.length ? serviceNames[i].trim() : '';
      final priceRaw =
          i < servicePrices.length ? servicePrices[i].trim() : '';

      if (name.isEmpty || priceRaw.isEmpty) {
        continue;
      }

      final sanitizedPrice =
          priceRaw.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll(',', '');
      final parsedPrice = double.tryParse(sanitizedPrice);

      if (parsedPrice != null) {
        priceMap[name.toLowerCase()] = parsedPrice;
      }
    }

    return priceMap;
  }

  void _applyJobGrouping(List<JobItemModel> jobs) {
    groupedJobItems = groupJobsByStatus(jobs);
    jobStatuses = groupedJobItems.keys.toList();
    jobItemList
      ..clear()
      ..addAll(jobs);

    if (jobStatuses.isNotEmpty) {
      if (_selectedJobStatus == null ||
          !jobStatuses.contains(_selectedJobStatus)) {
        _selectedJobStatus = jobStatuses.first;
      }
    } else {
      _selectedJobStatus = null;
    }

    _recalculateTotalSalary();
  }

  void _recalculateTotalSalary() {
    final selectedStatus = _selectedJobStatus;
    List<JobItemModel> relevantJobs;

    if (selectedStatus != null &&
        groupedJobItems.containsKey(selectedStatus)) {
      relevantJobs = groupedJobItems[selectedStatus]!;
    } else {
      relevantJobs = jobItemList;
    }

    double total = 0.0;

    for (final job in relevantJobs) {
      if (job.jobItemPercentage == JobPercentConstant.percent100) {
        final serviceName = AppUtils()
            .getServiceNameById(serviceId: job.jobItemServiceId)
            .trim();

        final price = _servicePriceMap[serviceName.toLowerCase()];
        if (price != null) {
          total += price;
        } else {
          total += job.jobItemTotalCharge.toDouble();
        }
      }
    }

    amountTotal.value = total;
  }

  void _filterJobListByStatus(String? inOutValue) {
    List<JobItemModel> filtered;

    if (inOutValue == 'IN') {
      filtered = allJobItemList
          .where((job) => !_hasFourthCheckCompleted(job))
          .toList();
    } else if (inOutValue == 'OUT') {
      filtered =
          allJobItemList.where(_hasFourthCheckCompleted).toList();
    } else {
      filtered = List<JobItemModel>.from(allJobItemList);
    }

    if (mounted) {
      setState(() {
        _applyJobGrouping(filtered);
      });
    }
  }

  bool _hasFourthCheckCompleted(JobItemModel job) {
    final timeline = job.timelineStatusObj;
    if (timeline != null) {
      final hasCompletedTimeline = timeline.any((status) =>
          status.statusPer == JobPercentConstant.percent68 &&
          status.isComplete == true);
      if (hasCompletedTimeline) {
        return true;
      }
    }

    final jobPercentage = int.tryParse(job.jobItemPercentage);
    final fourthCheckPercentage = int.tryParse(JobPercentConstant.percent68);
    if (jobPercentage != null &&
        fourthCheckPercentage != null &&
        jobPercentage >= fourthCheckPercentage) {
      return true;
    }

    return false;
  }

  Widget _buildStatusDropdown() {
    final dropdownItems = jobStatuses
        .map((status) => DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
                style: getRegularStyle(
                  color: ColorManager.textColorBlack,
                  fontSize: FontSize.mediumExtra,
                ),
              ),
            ))
        .toList();

    return DropdownButtonFormField<String>(
      value: jobStatuses.contains(_selectedJobStatus) ? _selectedJobStatus : null,
      items: dropdownItems,
      onChanged: dropdownItems.isEmpty
          ? null
          : (value) {
              setState(() {
                _selectedJobStatus = value;
                _recalculateTotalSalary();
              });
            },
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(color: ColorManager.colorLightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(color: ColorManager.colorLightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(color: ColorManager.primary),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: jobStatuses.isEmpty ? 'No Work History' : 'Select Work History',
        hintStyle: getRegularStyle(
          color: ColorManager.textColorGrey,
          fontSize: FontSize.medium,
        ),
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down),
    );
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
            SizedBox(height: 15.sp),

            // Work History Item card
            workHistoryCard(
                name:
                    widget.customCraftsmanModel.model.personalDetailsModel.name,
                location: widget.customCraftsmanModel.model.serviceInfoModel
                    .workingLocation,
                phoneNo: widget.customCraftsmanModel.model.personalDetailsModel
                    .phoneNumber,
                mobileNo: widget.customCraftsmanModel.model.personalDetailsModel
                        .mobileNumber ??
                    '',
                service: widget.customCraftsmanModel.model.serviceInfoModel
                                .selectedServiceNames !=
                            null &&
                        widget.customCraftsmanModel.model.serviceInfoModel
                            .selectedServiceNames!.isNotEmpty
                    ? widget.customCraftsmanModel.model.serviceInfoModel
                        .selectedServiceNames!
                        .map((service) => service)
                        .join(', ')
                    : widget.customCraftsmanModel.model.serviceInfoModel
                        .serviceType,
                onPressAbout: () {
                  // About Employee Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutCraftsmanScreen(
                          craftsmanModel: widget.customCraftsmanModel.model),
                    ),
                  );
                }),
            SizedBox(height: 18.sp),

            rowCard(
              remainingDaysValue:
                  AppUtils.calculateCraftsmanIndividualRemainingDays(
                              widget.customCraftsmanModel.model) ==
                          null
                      ? '-'
                      : AppUtils.calculateCraftsmanIndividualRemainingDays(
                                  widget.customCraftsmanModel.model)! <
                              1
                          ? '<1'
                          : AppUtils.calculateCraftsmanIndividualRemainingDays(
                                  widget.customCraftsmanModel.model)!
                              .toStringAsFixed(1),
            ),
            SizedBox(height: 20.sp),

            workCapacitySummaryCard(options: _serviceCapacityOptions),
            SizedBox(height: 20.sp),

            // runningDone Card
            runningDoneCard(
              onTapQT: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RunningDoneStatusScreen(
                      jobList: allJobItemList,
                      status: 'QT',
                    ),
                  ),
                );
              },
              onTapAppointed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RunningDoneStatusScreen(
                      jobList: allJobItemList,
                      status: 'Appointed',
                    ),
                  ),
                );
              },
              onTapRunning: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RunningDoneStatusScreen(
                      jobList: allJobItemList,
                      status: 'Running',
                    ),
                  ),
                );
              },
              onTapDone: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RunningDoneStatusScreen(
                      jobList: allJobItemList,
                      status: 'Done',
                    ),
                  ),
                );
              },
              appointedValue:
                  widget.customCraftsmanModel.model.appointed.toString(),
              runningValue:
                  widget.customCraftsmanModel.model.running.toString(),
              doneValue: widget.customCraftsmanModel.model.done.toString(),
              qTValue: widget.customCraftsmanModel.model.qtPassed.toString(),
            ),
            SizedBox(height: 20.sp),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Load',
                  style: getMediumStyle(
                    color: ColorManager.colorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
                Text(
                  '${(widget.workLoad * 100).toStringAsFixed(2)}%',
                  style: getRegularStyle(
                    color: ColorManager.grey,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 10.sp,
              percent: widget.workLoad.toDouble(),
              backgroundColor: ColorManager.colorLightWhite,
              progressColor: ColorManager.colorBlack,
              barRadius: Radius.circular(10.sp),
            ),
            SizedBox(height: 20.sp),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppUtils.parseDate(
                      DateTime.now().millisecondsSinceEpoch, 'MMMM'),
                  style: getBoldStyle(
                    color: ColorManager.primary,
                    fontSize: FontSize.large,
                  ),
                ),
                Row(
                  children: [
                    // SvgPicture.asset(IconAssets.iconPrevious, height: 20.sp),
                    // SizedBox(width: 10.sp),
                    // SvgPicture.asset(IconAssets.iconNext, height: 20.sp)

                    PopupMenuButton<int>(
                      offset: const Offset(-33, 28),
                      onSelected: (item) {
                        if (item == 0) {
                          getJobListByCraftsmanId();
                        } else if (item == 1) {
                          _filterJobListByStatus('IN');
                        } else if (item == 2) {
                          _filterJobListByStatus('OUT');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          padding: EdgeInsets.only(top: 5.sp),
                          height: 15.sp,
                          value: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'All',
                                style: getBoldStyle(
                                    fontSize: 16.5.sp,
                                    color: ColorManager.colorBlack),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          padding: EdgeInsets.only(top: 15.sp),
                          height: 15.sp,
                          value: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'In',
                                style: getBoldStyle(
                                    fontSize: 16.5.sp,
                                    color: ColorManager.colorBlack),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          padding: EdgeInsets.only(top: 15.sp),
                          height: 15.sp,
                          value: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Out',
                                style: getBoldStyle(
                                    fontSize: 16.5.sp,
                                    color: ColorManager.colorBlack),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 15.sp),

            // Text(
            //   '6, Tuesday',
            //   style: getRegularStyle(
            //     color: ColorManager.grey,
            //     fontSize: FontSize.mediumExtra,
            //   ),
            // ),
            // SizedBox(height: 5.sp),

            // Job List
            isJobListFetchingData
                ? buildLoadingWidget
                : error.isNotEmpty
                    ? Center(
                        child: Text(error.toString()),
                      )
                    : jobStatuses.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusDropdown(),
                              SizedBox(height: 20.sp),
                              if (_selectedJobStatus != null)
                                buildJobListView(
                                    groupedJobItems[_selectedJobStatus] ?? [])
                              else
                                const SizedBox.shrink(),
                            ],
                          )
                        : Text("No Data Found"),
          ],
        ),
      ),
    );
  }

  Widget buildJobListView(List<JobItemModel> jobs) {
    // amountTotal = 0;
    // for (int i = 0;
    //     i <
    //         widget.customCraftsmanModel.model.serviceInfoModel
    //             .selectedServicePrice!.length;
    //     i++) {
    //   final name = widget
    //       .customCraftsmanModel.model.serviceInfoModel.selectedServiceNames?[i];
    //   final price = widget
    //       .customCraftsmanModel.model.serviceInfoModel.selectedServicePrice?[i];
    //   for (int i = 0; i < jobs.length; i++) {
    //     final jobItem = jobs[i];
    //     ;
    //     print(
    //         "--Job $i → ${AppUtils().getServiceNameById(serviceId: jobItem.jobItemServiceId)}");
    //     if (AppUtils()
    //             .getServiceNameById(serviceId: jobItem.jobItemServiceId) ==
    //         name) {
    //       amountTotal = amountTotal + int.parse(price.toString());
    //       print("--price $amountTotal");
    //     }
    //   }
    //   setState(() {});
    // }
    return jobs.isEmpty
        ? Center(
            child: Text(
                'No Jobs Available for this status'), // Empty state message for each tab
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            itemBuilder: (BuildContext context, int index) {
              final jobItem = jobs[index];

              return Padding(
                padding: EdgeInsets.only(bottom: 15.sp),
                child: JobItems(
                  onClick: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobStatusScreen(jobItemModel: jobItem),
                      ),
                    );
                  },
                  jobItemModel: jobItem,
                ),
              );
            },
          );
  }

  Widget statusCard({required String key, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 17.sp),
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
          Text(
            key,
            style: getBoldStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.medium,
            ),
          ),
          SizedBox(height: 10.sp),
          Text(
            value,
            style: getBoldStyle(
              color: ColorManager.colorGrey,
              fontSize: FontSize.large,
            ),
          ),
        ],
      ),
    );
  }

  Widget workHistoryCard(
      {required String name,
      required String location,
      required String phoneNo,
      required String mobileNo,
      required String service,
      required Function onPressAbout}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getBoldStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.large,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    SvgPicture.asset(IconAssets.iconWorkHistory, height: 18.sp),
                  ],
                ),
                SizedBox(height: 14.sp),
                _workHistoryInfoTile(
                  label: 'Location',
                  value: location,
                ),
                _workHistoryInfoTile(
                  label: 'Mobile Number',
                  value: mobileNo,
                  onTap: () => makePhoneCall(mobileNo),
                ),
                _workHistoryInfoTile(
                  label: 'Phone Number',
                  value: phoneNo,
                  onTap: () => makePhoneCall(phoneNo),
                ),
                _workHistoryInfoTile(
                  label: 'Service',
                  value: service,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.sp),
          InkWell(
            onTap: () => onPressAbout(),
            child: SvgPicture.asset(IconAssets.iconAbout),
          ),
        ],
      ),
    );
  }

  Widget _workHistoryInfoTile({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getBoldStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
        ),
        SizedBox(height: 4.sp),
        Text(
          value,
          style: getRegularStyle(
            color: ColorManager.textColorGrey,
            fontSize: FontSize.medium,
          ),
        ),
        SizedBox(height: 10.sp),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }

  Widget runningDoneCard(
      {required String runningValue,
      required String doneValue,
      required String qTValue,
      required Function onTapAppointed,
      required Function onTapRunning,
      required Function onTapDone,
      required Function onTapQT,
      required String appointedValue}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        children: [
          // Appointed
          Expanded(
            child: InkWell(
              onTap: () => onTapAppointed(),
              child: Column(
                children: [
                  Text(
                    'Appointed',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    appointedValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Running
          Expanded(
            child: InkWell(
              onTap: () => onTapRunning(),
              child: Column(
                children: [
                  Text(
                    'Running',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    runningValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Done
          Expanded(
            child: InkWell(
              onTap: () => onTapDone(),
              child: Column(
                children: [
                  Text(
                    'Done',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    doneValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),

          // QT
          Expanded(
            child: InkWell(
              onTap: () => onTapQT(),
              child: Column(
                children: [
                  Text(
                    'QT',
                    style: getBoldStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.medium,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    qTValue,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rowCard({
    required String remainingDaysValue,
  }) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        children: [
          // Remaining Days
          Expanded(
            child: Column(
              children: [
                Text(
                  'Remaining Days',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  remainingDaysValue,
                  style: getBoldStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.large,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.sp),
          Container(
            height: 30.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Total Salary
          Expanded(
            child: Column(
              children: [
                Text(
                  'Total Salary',
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 12.sp),
                Obx(() {
                  final totalValue = amountTotal.value;
                  final formattedTotal = totalValue % 1 == 0
                      ? totalValue.toStringAsFixed(0)
                      : totalValue.toStringAsFixed(2);

                  return Text(
                    formattedTotal,
                    style: getBoldStyle(
                      color: ColorManager.colorGrey,
                      fontSize: FontSize.large,
                    ),
                  );
                }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget workCapacitySummaryCard({required List<String> options}) {
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work capacity',
            style: getBoldStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.medium,
            ),
          ),
          SizedBox(height: 12.sp),
          if (options.isNotEmpty)
            ...List.generate(options.length, (index) {
              final entry = options[index];
              final double bottomPadding =
                  index == options.length - 1 ? 0.0 : 8.sp;
              return Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Text(
                  entry,
                  style: getRegularStyle(
                    color: ColorManager.colorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
              );
            })
          else
            Text(
              'No services assigned',
              style: getRegularStyle(
                color: ColorManager.colorGrey,
                fontSize: FontSize.medium,
              ),
            ),
        ],
      ),
    );
  }

  Widget attendanceItemCheckInCheckOutButton(
      {required String checkInTime1,
      required String checkInTime2,
      required String checkOutTime1,
      required String checkOutTime2,
      required String date,
      required String day}) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.all(17.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColorManager.colorLightGrey),
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 15.sp),
            decoration: BoxDecoration(
              color: const Color(0xffE5E9FF),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              children: [
                Text(
                  date,
                  style: getBoldStyle(
                      color: ColorManager.primary, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  day,
                  style: getRegularStyle(
                      color: ColorManager.primary, fontSize: 16.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.sp),
          // Container(
          //   height: 30.sp,
          //   width: 5.sp,
          //   color: ColorManager.colorLightGrey,
          // ),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Check In',
                  style: getBoldStyle(
                      color: ColorManager.colorGrey, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime1,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkInTime2,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
              ],
            ),
          ),
          Container(
            height: 35.sp,
            width: 5.sp,
            color: ColorManager.colorLightGrey,
          ),
          SizedBox(width: 15.sp),

          // Leave
          Expanded(
            child: Column(
              children: [
                Text(
                  'Check Out',
                  style: getBoldStyle(
                      color: ColorManager.colorGrey, fontSize: 16.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime1,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
                SizedBox(height: 12.sp),
                Text(
                  checkOutTime2,
                  style: getRegularStyle(
                      color: ColorManager.colorGrey, fontSize: 16.5.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
