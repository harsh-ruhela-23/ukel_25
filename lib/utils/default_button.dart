import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton(
      {Key? key, required this.text, required this.onPress, this.icon})
      : super(key: key);

  final String text;
  final Function onPress;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress,
      child: Container(
        height: 30.sp,
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: ColorManager.primary,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? const SizedBox(),
            icon == null ? const SizedBox() : SizedBox(width: 13.sp),
            Text(
              text,
              style: getBoldStyle(color: Colors.white, fontSize: 17.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class TextIconButton extends StatelessWidget {
  const TextIconButton(
      {Key? key,
      required this.text,
      required this.onPress,
      required this.iconWidget})
      : super(key: key);

  final String text;
  final Widget iconWidget;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress,
      child: Container(
        height: 30.sp,
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorManager.primary,
            width: 1.5,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            Text(
              text,
              style: getBoldStyle(color: ColorManager.primary, fontSize: 17.sp),
            ),
          ],
        ),
      ),
    );
  }
}

//globalKey
GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

BuildContext get globalContext => globalKey.currentContext!;
