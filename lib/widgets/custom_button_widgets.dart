import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

class ButtonWidget extends StatefulWidget {
  final Function onPressed;
  final String title;
  final double? fontSize;
  final Color? btnColor, textColor;
  final BoxDecoration? decoration;
  final BoxBorder? border;

  const ButtonWidget(
      {Key? key,
      required this.onPressed,
      required this.title,
      this.fontSize,
      this.btnColor,
      this.textColor,
      this.decoration,
      this.border})
      : super(key: key);

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12.sp : 14.sp, horizontal: 15.sp),
        decoration: widget.decoration ??
            BoxDecoration(
                color: widget.btnColor ?? ColorManager.btnColorDarkBlue,
                borderRadius: BorderRadius.circular(8.sp),
                border: widget.border),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: getSemiBoldStyle(
                color: widget.textColor ?? ColorManager.textColorWhite,
                fontSize: widget.fontSize ?? FontSize.mediumExtra,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DualButtonWidget extends StatefulWidget {
  const DualButtonWidget(
      {Key? key,
      required this.negativeLabel,
      required this.positiveLabel,
      this.negativeButtonColor,
      this.positiveButtonColor,
      this.negativeTextColor,
      this.positiveTextColor,
      required this.negativeClick,
      required this.positiveClick,
      this.negativeButtonBorder,
      this.positiveButtonBorder})
      : super(key: key);

  final String negativeLabel, positiveLabel;
  final Color? negativeButtonColor,
      positiveButtonColor,
      negativeTextColor,
      positiveTextColor;
  final Function() negativeClick, positiveClick;
  final BoxBorder? negativeButtonBorder, positiveButtonBorder;

  @override
  State<DualButtonWidget> createState() => _DualButtonWidgetState();
}

class _DualButtonWidgetState extends State<DualButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            onPressed: widget.negativeClick,
            title: widget.negativeLabel,
            btnColor: widget.negativeButtonColor,
            textColor: widget.negativeTextColor,
            border: widget.negativeButtonBorder,
          ),
        ),
        SizedBox(width: 20.sp),
        Expanded(
          child: ButtonWidget(
            onPressed: widget.positiveClick,
            title: widget.positiveLabel,
            btnColor: widget.positiveButtonColor,
            textColor: widget.positiveTextColor,
            border: widget.positiveButtonBorder,
          ),
        ),
      ],
    );
  }
}
