import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_repository.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/dropdown/dropdown_search.dart';
import 'package:ukel/widgets/dropdown/properties/dropdown_decorator_props.dart';
import 'package:ukel/widgets/dropdown/properties/popup_props.dart';

class ServiceTypeDropDownWidget extends StatefulWidget {
  const ServiceTypeDropDownWidget(
      {Key? key,
      required this.onServiceSelected,
      required this.selectedServiceType})
      : super(key: key);
  final void Function(ServicesListModel?)? onServiceSelected;
  final ServicesListModel? selectedServiceType;

  @override
  State<ServiceTypeDropDownWidget> createState() =>
      _ServiceTypeDropDownWidgetState();
}

class _ServiceTypeDropDownWidgetState extends State<ServiceTypeDropDownWidget> {
  List<ServicesListModel> servicesTypeDropdownList = [];

  @override
  void initState() {
    super.initState();
    getServiceList();
  }

  getServiceList() async {
    Map<String, dynamic> result =
        await ServiceInvoiceRepository().fetchServices();

    List<ServicesListModel> servicesList = result[FbConstant.service];

    if (servicesList.isNotEmpty) {
      servicesTypeDropdownList.addAll(servicesList);
    }
  }

  @override
  void dispose() {
    servicesTypeDropdownList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownSearch<ServicesListModel>(
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            itemBuilder: (context, item, isSelected) {
              return Container(
                padding: EdgeInsets.fromLTRB(13.sp, 13.sp, 13.sp, 10.sp),
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
          items: servicesTypeDropdownList,
          selectedItem: widget.selectedServiceType,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select Service Type *',
              hintStyle: getSemiBoldStyle(
                color: ColorManager.textColorGrey,
                fontSize: FontSize.medium,
              ),
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorManager.colorGrey.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorManager.colorGrey.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorManager.colorRed, width: 1),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorManager.colorRed, width: 1),
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
              item?.name ?? 'Select Service *',
            );
          },
          onChanged: (service) {
            if (service != null) {
              // selectedServiceType = service;
              widget.onServiceSelected!(service);
            }
          },
        ),
      ],
    );
  }
}
