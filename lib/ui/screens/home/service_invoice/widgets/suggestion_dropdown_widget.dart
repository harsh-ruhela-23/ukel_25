import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/custom_page_transition.dart';
import 'package:ukel/widgets/typeahed/flutter_typeahead.dart';

class SuggestionDropdownWidget extends StatefulWidget {
  const SuggestionDropdownWidget(
      {Key? key,
      required this.controller,
      this.textStyle,
      this.hintStyle,
      this.errorStyle,
      this.inputDecoration,
      this.validator,
      this.contentPadding,
      this.isLastField,
      this.textInputType,
      this.maxLength,
      this.isFromJobItem = false,
      this.onCustomerSelected,
      this.inputFormatters,
      this.isEnable})
      : super(key: key);

  final TextEditingController controller;
  final TextStyle? textStyle, hintStyle, errorStyle;
  final InputDecoration? inputDecoration;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isLastField;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  //TextInputType.text
  final int? maxLength;
  final bool? isFromJobItem, isEnable;
  final Function(CustomerModel)? onCustomerSelected;

  @override
  State<SuggestionDropdownWidget> createState() =>
      _SuggestionDropdownWidgetState();
}

class _SuggestionDropdownWidgetState extends State<SuggestionDropdownWidget> {
  String? searchPhone;

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceViewModel>(builder: (context, provider, child) {
      return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          enabled: widget.isEnable ?? true,
          textAlign: TextAlign.start,
          keyboardType:  widget.textInputType ?? TextInputType.phone,
          controller: widget.controller,
          inputFormatters: widget.inputFormatters,
          style: widget.textStyle ??
              getRegularStyle(
                color: ColorManager.textColorBlack,
                fontSize: FontSize.mediumExtra,
              ),
          decoration: widget.inputDecoration ??
              textFieldInputDecoration(
                errorStyle: widget.errorStyle,
                contentPadding: widget.contentPadding,
              ),
          onChanged: (value) {
            searchPhone = value;
            provider.customerNameController.text = "";
            provider.villageController.text = "";
            provider.selectedCustomer = null;
          },
        ),
        suggestionsCallback: provider.searchCustomer,
        itemBuilder: (context, CustomerModel item, int index) {
          if (index == 0) {
            return Column(
              children: [
                defaultWidget(provider),
                Container(
                  padding: EdgeInsets.all(15.sp),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: getMediumStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.medium,
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 5.sp),
                                Text(
                                  item.phone,
                                  style: getMediumStyle(
                                    color: ColorManager.textColorGrey,
                                    fontSize: FontSize.small,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                          quarterTurns: 3,
                          child: SvgPicture.asset(IconAssets.iconArrowDown))
                    ],
                  ),
                ),
              ],
            );
          }
          return Container(
            padding: EdgeInsets.all(15.sp),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: getMediumStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.medium,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 5.sp),
                          Text(
                            item.phone,
                            style: getMediumStyle(
                              color: ColorManager.textColorGrey,
                              fontSize: FontSize.small,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                RotatedBox(
                    quarterTurns: 3,
                    child: SvgPicture.asset(IconAssets.iconArrowDown))
              ],
            ),
          );
        },
        noItemsFoundBuilder: (context) {
          return Column(
            children: [
              defaultWidget(provider),
              Container(
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "No customer found",
                        textAlign: TextAlign.center,
                        style: getRegularStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.big,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        errorBuilder: (context, error) {
          return const SizedBox();
        },
        onSuggestionSelected: (CustomerModel item) {
          if (widget.isFromJobItem == true) {
            widget.onCustomerSelected!(item);
          } else {
            if (widget.onCustomerSelected != null) {
              widget.onCustomerSelected!(item);
            }
            provider.phoneController.text = item.phone;
            provider.customerNameController.text = item.name;
            provider.villageController.text = item.village;
            provider.selectedCustomer = item;
            if (item.membersData != null) {
              if (item.membersData!.isNotEmpty) {
                provider.selectedMember = item.membersData![0];
              }
            }
          }
        },
      );
    });
  }

  Widget defaultWidget(ServiceViewModel provider) {
    return Padding(
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
                  CustomerModel? result =  await AppUtils.navigateTo(
                    context,
                    CustomPageTransition(
                      MyApp.myAppKey,
                      AddNewCustomerScreen.routeName,
                      arguments: {"phone": searchPhone},
                    ),
                  );
                  if (result != null) {
                    if (widget.isFromJobItem == true) {
                      widget.onCustomerSelected!(result);
                    } else {
                      if (widget.onCustomerSelected != null) {
                        widget.onCustomerSelected!(result);
                      }
                      //provider.phoneController.text = result.phone;
                     // provider.customerNameController.text = result.name;
                      //provider.villageController.text = result.village
                      provider.selectedCustomer = result;
                      if (result.membersData != null) {
                        if (result.membersData!.isNotEmpty) {
                          provider.isQueryAllSnapshotAssigned = false;
                          //provider.selectedMember = result.membersData![0];
                        }
                      }
                    }
                  }
                },
                child: Text(
                  "+ Add New",
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
    );
  }
}

InputDecoration textFieldInputDecoration(
    {TextStyle? errorStyle, EdgeInsetsGeometry? contentPadding}) {
  return InputDecoration(
    counterText: "",
    alignLabelWithHint: true,
    enabledBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: ColorManager.colorGrey.withOpacity(0.5), width: 1),
      borderRadius: BorderRadius.circular(8.sp),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: ColorManager.colorGrey.withOpacity(0.3), width: 1),
      borderRadius: BorderRadius.circular(8.sp),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: ColorManager.colorGrey.withOpacity(0.5), width: 1),
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
    errorStyle: errorStyle ??
        getMediumStyle(
          color: ColorManager.textColorRed,
          fontSize: FontSize.medium,
        ),
    contentPadding: contentPadding ??
        EdgeInsets.symmetric(horizontal: 15.sp, vertical: 0.sp),
    suffixIcon: RotatedBox(
      quarterTurns: 3,
      child: Icon(
        Icons.arrow_back_ios_outlined,
        size: 15.sp,
      ),
    ),
  );
}
