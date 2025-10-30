import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/dropdown/dropdown_search.dart';
import 'package:ukel/widgets/dropdown/properties/dropdown_decorator_props.dart';
import 'package:ukel/widgets/dropdown/properties/popup_props.dart';

class SelectRoleDropDownWidget extends StatefulWidget {
  const SelectRoleDropDownWidget(
      {Key? key, required this.onSelectedRole, required this.selectedRole})
      : super(key: key);
  final Function(UserRoleModel) onSelectedRole;
  final UserRoleModel? selectedRole;

  @override
  State<SelectRoleDropDownWidget> createState() =>
      _SelectRoleDropDownWidgetState();
}

class _SelectRoleDropDownWidgetState extends State<SelectRoleDropDownWidget> {
  List<UserRoleModel> roleList = [
    UserRoleModel(roleName: AppConstant.admin, roleId: "A"),
    UserRoleModel(roleName: AppConstant.subAdmin, roleId: "D"),
    UserRoleModel(roleName: AppConstant.branch, roleId: "B"),
    UserRoleModel(roleName: AppConstant.craftsman, roleId: "C"),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<UserRoleModel>(
      popupProps: PopupProps.menu(
        fit: FlexFit.loose,
        itemBuilder: (context, item, isSelected) {
          return Container(
            padding: EdgeInsets.fromLTRB(13.sp, 13.sp, 13.sp, 10.sp),
            child: Text(
              item.roleName,
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
      items: roleList,
      selectedItem: widget.selectedRole,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: 'Select Role*',
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
          item?.roleName ?? 'Select Role*',
        );
      },
      onChanged: (role) {
        widget.onSelectedRole(role!);
      },
    );
  }
}

class UserRoleModel {
  String roleName;
  String roleId;

  UserRoleModel({required this.roleName, required this.roleId});
}
