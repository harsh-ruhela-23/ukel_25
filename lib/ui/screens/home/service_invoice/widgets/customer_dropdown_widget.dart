import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/custom_page_transition.dart';
import 'package:ukel/widgets/dropdown/dropdown_search.dart';
import 'package:ukel/widgets/dropdown/properties/custom_widget_props.dart';
import 'package:ukel/widgets/dropdown/properties/dropdown_decorator_props.dart';
import 'package:ukel/widgets/dropdown/properties/popup_props.dart';

import '../service_view_model.dart';
import '../../../../../utils/common_widget.dart';

class CustomerDropDownWidget extends StatefulWidget {
  const CustomerDropDownWidget(
      {Key? key,
      this.hint,
      this.memberList,
      this.selectedMember,
      required this.onChange,
      this.isEnable})
      : super(key: key);

  final String? hint;
  final List<MembersModel>? memberList;
  final MembersModel? selectedMember;
  final Function(MembersModel?) onChange;
  final bool? isEnable;

  @override
  State<CustomerDropDownWidget> createState() => _CustomerDropDownWidgetState();
}

class _CustomerDropDownWidgetState extends State<CustomerDropDownWidget> {
  @override
  void initState() {
    super.initState();
    // Provider.of<ServiceViewModel>(context, listen: false).getCustomersList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(
      builder: (context, provider, child) {
        return DropdownSearch<MembersModel>(
          enabled: widget.isEnable ?? true,
          popupProps: PopupProps.menu(
            showCustomWidget: true,
            fit: FlexFit.loose,
            customWidgetProps: CustomWidgetProps(
              widget: Padding(
                padding: EdgeInsets.only(top: 15.sp, left: 15.sp, right: 15.sp),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Saved Customer",
                            style: getBoldStyle(
                              color: ColorManager.textColorBlack,
                              fontSize: FontSize.mediumExtra,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            AppUtils.navigateUp(context);
                            CustomerModel? result = await AppUtils.navigateTo(
                              context,
                              CustomPageTransition(
                                MyApp.myAppKey,
                                AddNewCustomerScreen.routeName,
                                arguments: {
                                  "customerData": provider.selectedCustomer
                                },
                              ),
                            );
                            if (result != null) {
                              //to do
                            }
                          },
                          child: Text(
                            "+ Add New Member",
                            style: getMediumStyle(
                              color: ColorManager.colorBlue,
                              fontSize: FontSize.small,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    Container(
                      height: 3.sp,
                      decoration: BoxDecoration(
                        color: ColorManager.colorGrey,
                      ),
                      child: const Row(),
                    ),
                    SizedBox(height: 15.sp),
                  ],
                ),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return provider.isCustomersFetchingData == true
                  ? Center(child: buildLoadingWidget)
                  : Container(
                      padding: EdgeInsets.all(15.sp),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name ?? "",
                              style: getMediumStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.medium,
                              ),
                            ),
                          ),
                        ],
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
          items: widget.memberList ?? [],
          selectedItem: widget.selectedMember,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              counterText: "",
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorManager.colorGrey.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorManager.colorGrey.withOpacity(0.3), width: 1),
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
              errorStyle: getMediumStyle(
                color: ColorManager.textColorRed,
                fontSize: FontSize.medium,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.sp, vertical: 0.sp),
              suffixIcon: RotatedBox(
                quarterTurns: 3,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 15.sp,
                ),
              ),
            ),
          ),
          dropdownBuilder: (context, item) {
            return Text(item?.name ?? widget.hint ?? "");
          },
          onChanged: (customerModel) {
            widget.onChange(customerModel);
          },
        );
      },
    );
  }
}
