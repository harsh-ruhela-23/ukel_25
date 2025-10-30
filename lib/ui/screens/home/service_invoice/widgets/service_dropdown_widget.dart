import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/widgets/dropdown/dropdown_search.dart';
import 'package:ukel/widgets/dropdown/properties/dropdown_decorator_props.dart';
import 'package:ukel/widgets/dropdown/properties/popup_props.dart';

import 'add_job_item_screen.dart';

class ServiceDropDownWidget extends StatefulWidget {
  const ServiceDropDownWidget({
    Key? key,
    this.isFieldsEnable,
    this.membersModel,
    this.isForParty,
  }) : super(key: key);

  final bool? isFieldsEnable, isForParty;
  final MembersModel? membersModel;

  @override
  State<ServiceDropDownWidget> createState() => _ServiceDropDownWidgetState();
}

class _ServiceDropDownWidgetState extends State<ServiceDropDownWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<ServiceViewModel>(context, listen: false).getServicesList();
    Provider.of<ServiceViewModel>(context, listen: false).selectedService =
    null;
    setState(() {});
  }

  @override
  void dispose() {
    // Provider.of<AddJobItemViewModel>(context, listen: false).dispose();
    super.dispose();
  }

  List<Widget> getServiceTypeWidget(
      ServiceViewModel provider, List<ServiceType> serviceTypeList) {
    final List<Widget> measurementWidgets = [];
    final List<Widget> optionWidgets = [];
    int sequenceCount = 0;

    try {
      for (int i = 0; i < serviceTypeList.length; i++) {
        final String type = serviceTypeList[i].type.toLowerCase();

        if (type == "both") {
          provider.serviceRadioId = serviceTypeList[i].id;
          provider.serviceRadioValue = serviceTypeList[i].value ?? "";
          final List<ServiceOptionModel>? radioOptions = serviceTypeList[i].option;

          if (radioOptions != null && radioOptions.isNotEmpty) {
            final List<Widget> radioGroupWidgetList = [];

            for (int j = 0; j < radioOptions.length; j++) {
              radioGroupWidgetList.add(
                Expanded(
                  child: RadioListTile(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
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
                ),
              );
            }

            optionWidgets.add(
              Column(
                children: [
                  SizedBox(height: 15.sp),
                  Row(children: [...radioGroupWidgetList]),
                ],
              ),
            );
          }
          measurementWidgets.add(
            ServiceDetailWidget(
              data: serviceTypeList[i],
              viewModelProvider: provider,
              index: sequenceCount,
              isFieldsEnable: widget.isFieldsEnable,
            ),
          );
          sequenceCount++;
        }else if (type == "radio") {
          provider.serviceRadioId = serviceTypeList[i].id;
          provider.serviceRadioValue = serviceTypeList[i].value ?? "";
          final List<ServiceOptionModel>? radioOptions = serviceTypeList[i].option;

          if (radioOptions != null && radioOptions.isNotEmpty) {
            final List<Widget> radioGroupWidgetList = [];

            for (int j = 0; j < radioOptions.length; j++) {
              radioGroupWidgetList.add(
                Expanded(
                  child: RadioListTile(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
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
                ),
              );
            }

            optionWidgets.add(
              Column(
                children: [
                  SizedBox(height: 15.sp),
                  Row(children: [...radioGroupWidgetList]),
                ],
              ),
            );
          }
        } else {
          measurementWidgets.add(
            ServiceDetailWidget(
              data: serviceTypeList[i],
              viewModelProvider: provider,
              index: sequenceCount,
              isFieldsEnable: widget.isFieldsEnable,
            ),
          );
          sequenceCount++;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("errr==$e");
      }
    }

    return [...measurementWidgets, ...optionWidgets];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(
      builder: (context, provider, child) {

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
              selectedItem: provider.selectedService,
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
            if (provider.selectedService != null &&
                provider.serviceTypeList.isNotEmpty)
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
                        ...getServiceTypeWidget(
                            provider, provider.serviceTypeList),
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