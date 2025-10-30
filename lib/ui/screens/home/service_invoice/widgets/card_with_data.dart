import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/model/job_item_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/widgets/dropdown/dropdown_search.dart';
import 'package:ukel/widgets/dropdown/properties/dropdown_decorator_props.dart';
import 'package:ukel/widgets/dropdown/properties/popup_props.dart';

import '../../../../../widgets/custom_input_fields.dart';
import 'add_job_item_screen.dart';

// class DataWithNew extends StatelessWidget {
//   const DataWithNew({super.key, required this.jobItemModel});
//   final JobItemModel jobItemModel;
//   @override
//   Widget build(BuildContext context) {
//     return  Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//           padding: EdgeInsets.all(15.sp),
//           decoration: BoxDecoration(
//               color: ColorManager.colorLightGrey,
//               borderRadius: BorderRadius.circular(10.sp)),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '#${jobItemModel.jobItemCode}',
//                       style: getBoldStyle(
//                         color: ColorManager.textColorBlack,
//                         fontSize: FontSize.bigExtra,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       AppUtils.parseDate(
//                           jobItemModel.jobItemDueDate, AppConstant.dd_mm_yyyy),
//                       textAlign: TextAlign.right,
//                       style: getBoldStyle(
//                         color: ColorManager.textColorBlack,
//                         fontSize: FontSize.big,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.sp),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       AppUtils().getServiceNameById(
//                           serviceId: jobItemModel.jobItemServiceId),
//                       style: getSemiBoldStyle(
//                         color: ColorManager.textColorBlack,
//                         fontSize: FontSize.big,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       "${jobItemModel.jobItemQty.toString()} X ${(jobItemModel.jobItemTotalCharge / jobItemModel.jobItemQty).toString()} = ${jobItemModel.jobItemQty * (jobItemModel.jobItemTotalCharge / jobItemModel.jobItemQty)}",
//                       textAlign: TextAlign.right,
//                       style: getBoldStyle(
//                         color: ColorManager.textColorGrey,
//                         fontSize: FontSize.mediumExtra,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//     );
//   }
// }

class DataWithServiceDropDownWidget extends StatefulWidget {
  const DataWithServiceDropDownWidget({
    Key? key,
    this.isFieldsEnable,
    this.membersModel,
    this.isForParty,
    required this.jobItemModel,
    required this.serviceViewModel,
  }) : super(key: key);

  final bool? isFieldsEnable, isForParty;
  final MembersModel? membersModel;
  final JobItemModel jobItemModel;
  final ServiceViewModel serviceViewModel;
  @override
  State<DataWithServiceDropDownWidget> createState() =>
      _ServiceDropDownWidgetState();
}

class _ServiceDropDownWidgetState extends State<DataWithServiceDropDownWidget> {
  List<ServiceType> newServiceTypeList = [];
  ServicesListModel? newAddedService;
  @override
  void initState() {
    super.initState();

    Provider.of<ServiceViewModel>(context, listen: false).getServicesList();
    Provider.of<ServiceViewModel>(context, listen: false).getJobItemData(
        widget.jobItemModel.jobId, newServiceTypeList, newAddedService);
     Provider.of<ServiceViewModel>(context, listen: false).getServiceName(widget.jobItemModel.jobId).then(
      (value) {
        newAddedService = value;
      },
    );

    //     .getServiceById(widget.jobItemModel.jobItemServiceId);
    // Provider.of<ServiceViewModel>(context, listen: false)
    //     .getServiceById(widget.jobItemModel.jobItemServiceId);
    // Provider.of<ServiceViewModel>(context, listen: false).newAddedService =
    //     null;

    setState(() {});
  }

  @override
  void dispose() {
    // Provider.of<AddJobItemViewModel>(context, listen: false).dispose();

    super.dispose();
  }

  List<Widget> getServiceTypeWidget(
      ServiceViewModel provider, List<ServiceType> serviceTypeList) {
    List<Widget> widgetList = [];
    int sequenceCount = 0;
    try {
      for (int i = 0; i < serviceTypeList.length; i++) {
        final String type = serviceTypeList[i].type.toLowerCase();
        if (type == "radio") {
          provider.serviceRadioId = serviceTypeList[i].id;
          provider.serviceRadioValue = serviceTypeList[i].value ?? "";
          List<ServiceOptionModel>? radioOptions = serviceTypeList[i].option;
          List<Widget> radioGroupWidgetList = [];
          if (radioOptions != null) {
            for (int j = 0; j < radioOptions.length; j++) {
              radioGroupWidgetList.add(Expanded(
                child: RadioListTile(
                  visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    radioOptions[j].name,
                    style: getMediumStyle(
                      color: ColorManager.textColorBlack,
                      fontSize: FontSize.mediumExtra,
                    ),
                  ),
                  value: radioOptions[j].label,
                  groupValue: provider.serviceRadioValue,
                  onChanged: (value) {
                    if (widget.isFieldsEnable ?? true) {
                      provider.serviceRadioValue = value.toString();
                      serviceTypeList[i].value = value.toString();
                      provider.calculateJobItemTotal();
                    }
                  },
                ),
              ));
            }
            widgetList.add(
              Column(
                children: [
                  SizedBox(height: 15.sp),
                  Row(
                    children: [...radioGroupWidgetList],
                  ),
                ],
              ),
            );
          }
        } else {
          widgetList.add(NewServiceDetailWidget(
            data: serviceTypeList[i],
            viewModelProvider: provider,
            index: sequenceCount,
            isFieldsEnable: widget.isFieldsEnable,
            newServiceTypeList: newServiceTypeList,
          ));
          sequenceCount++;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("errr==$e");
      }
    }
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(
      builder: (context, provider, child) {
        //log(" ${provider.newServiceTypeList[0].id}");
        return Column(
          children: [
            DropdownSearch<ServicesListModel>(
              popupProps: PopupProps.menu(
                fit: FlexFit.loose,
                itemBuilder: (context, item, isSelected) {
                  return provider.isServicesFetchingData == true
                      ? Center(child: buildLoadingWidget)
                      : Container(
                          padding:
                              EdgeInsets.fromLTRB(13.sp, 13.sp, 13.sp, 10.sp),
                          child: Text(
                            item.name,
                            style: getMediumStyle(
                              color: ColorManager.btnColorDarkBlue,
                              fontSize: FontSize.mediumExtra,
                            ),
                          ),
                        );
                },
                containerBuilder: (context, popupWidget) {
                  return Container(
                    margin: EdgeInsets.only(top: 15.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorManager.colorGrey,
                        width: 3.sp,
                      ),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: popupWidget,
                  );
                },
              ),
              items: provider.servicesModelList,
              selectedItem: newAddedService,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: 'Select Service*',
                  hintStyle: getSemiBoldStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorManager.colorGrey.withOpacity(0.5),
                        width: 1),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorManager.colorGrey.withOpacity(0.5),
                        width: 1),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorManager.colorRed, width: 1),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorManager.colorRed, width: 1),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  errorStyle: getSemiBoldStyle(
                    color: ColorManager.textColorRed,
                    fontSize: FontSize.medium,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 0.sp),
                ),
              ),
              dropdownBuilder: (context, item) {
                return Text(
                  item?.name ?? 'Select Service*',
                );
              },
              onChanged: (service) {
                provider.setSelectedService(service!, false);
              },
            ),
            if (newServiceTypeList.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 15.sp),
                  Container(
                    padding: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(
                        color: ColorManager.colorGrey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   itemCount: provider
                        //       .selectedService?.serviceTypeModelList.length,
                        //   itemBuilder: (context, index) {
                        //     return ServiceDetailWidget(
                        //       title: provider
                        //           .selectedService!.serviceTypeModelList[index],
                        //       index: index,
                        //     );
                        //   },
                        // ),
                        ...getServiceTypeWidget(provider, newServiceTypeList),
                      ],
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}

class NewServiceDetailWidget extends StatelessWidget {
  const NewServiceDetailWidget(
      {Key? key,
      required this.data,
      required this.index,
      required this.viewModelProvider,
      this.isFieldsEnable,
      required this.newServiceTypeList})
      : super(key: key);

  final ServiceType data;
  final ServiceViewModel viewModelProvider;
  final List<ServiceType> newServiceTypeList;
  final int index;
  final bool? isFieldsEnable;

  @override
  Widget build(BuildContext context) {
    int pos = newServiceTypeList.indexOf(data);
    final String unitLabel =
        (newServiceTypeList[pos].unit?.trim().isNotEmpty ?? false)
            ? newServiceTypeList[pos].unit!.trim()
            : 'Inch';
    final String fieldName =
        newServiceTypeList[pos].name ?? 'Measurement';

    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0.sp : 10.sp),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${index + 1}. $fieldName",
              style: getMediumStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.mediumExtra,
              ),
            ),
          ),
          SizedBox(width: 15.sp),
          SizedBox(
            width: 35.sp,
            height: 22.sp,
            child: TextInputWidget(
              isEnable: isFieldsEnable ?? true,
              textInputType: TextInputType.number,
              controller:
                  TextEditingController(text: newServiceTypeList[pos].value),
              isLastField: false,
              inputFormatterRegex: "[0-9. -]",
              onChange: (value) {
                newServiceTypeList[pos].value = value;
              },
            ),
          ),
          SizedBox(width: 15.sp),
          Text(
            unitLabel,
            style: getMediumStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      ),
    );
  }
}
