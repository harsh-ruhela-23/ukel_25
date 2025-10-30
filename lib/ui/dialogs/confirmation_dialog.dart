import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/widgets/custom_button_widgets.dart';

class ConfirmationDialog extends StatefulWidget {
  const ConfirmationDialog(
      {Key? key,
      required this.title,
      this.subTitle,
      required this.onPositiveClick,
      required this.onNegativeClick,
      this.negativeLabel,
      this.positiveLabel,
      this.negativeButtonBorder,
      this.positiveButtonBorder,
      this.negativeButtonColor,
      this.positiveButtonColor,
      this.negativeTextColor,
      this.positiveTextColor})
      : super(key: key);

  final String title;
  final String? subTitle;
  final Function() onPositiveClick, onNegativeClick;
  final String? negativeLabel, positiveLabel;
  final BoxBorder? negativeButtonBorder, positiveButtonBorder;
  final Color? negativeButtonColor,
      positiveButtonColor,
      negativeTextColor,
      positiveTextColor;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        insetPadding: EdgeInsets.all(15.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
        ),
        elevation: 10,
        backgroundColor: ColorManager.white,
        child: DialogContent(
          title: widget.title,
          subTitle: widget.subTitle,
          onPositiveClick: widget.onPositiveClick,
          onNegativeClick: widget.onNegativeClick,
          negativeLabel: widget.negativeLabel,
          positiveLabel: widget.positiveLabel,
          negativeButtonBorder: widget.negativeButtonBorder,
          positiveButtonBorder: widget.positiveButtonBorder,
          negativeButtonColor: widget.negativeButtonColor,
          negativeTextColor: widget.negativeTextColor,
          positiveButtonColor: widget.positiveButtonColor,
          positiveTextColor: widget.positiveTextColor,
        ),
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  const DialogContent(
      {Key? key,
      required this.title,
      this.subTitle,
      required this.onPositiveClick,
      required this.onNegativeClick,
      this.negativeLabel,
      this.positiveLabel,
      this.negativeButtonBorder,
      this.positiveButtonBorder,
      this.negativeButtonColor,
      this.positiveButtonColor,
      this.negativeTextColor,
      this.positiveTextColor})
      : super(key: key);

  final String title;
  final String? subTitle;
  final Function() onPositiveClick, onNegativeClick;
  final String? negativeLabel, positiveLabel;
  final BoxBorder? negativeButtonBorder, positiveButtonBorder;
  final Color? negativeButtonColor,
      positiveButtonColor,
      negativeTextColor,
      positiveTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: InkWell(
              //     onTap: () {
              //       AppUtils.navigateUp(context);
              //     },
              //     child: Icon(
              //       Icons.close_sharp,
              //       size: 22.sp,
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(top: 12.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: getBoldStyle(
                        color: ColorManager.textColorBlack,
                        fontSize: 17.5.sp,
                      ),
                    ),
                    subTitle != null
                        ? Column(
                            children: [
                              SizedBox(height: 10.sp),
                              Text(
                                subTitle!,
                                style: getSemiBoldStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.mediumExtra,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    SizedBox(height: 20.sp),
                    DualButtonWidget(
                      negativeLabel: negativeLabel ?? "",
                      positiveLabel: positiveLabel ?? "",
                      negativeClick: onNegativeClick,
                      positiveClick: onPositiveClick,
                      negativeButtonBorder: negativeButtonBorder,
                      positiveButtonBorder: positiveButtonBorder,
                      negativeButtonColor:
                          negativeButtonColor ?? ColorManager.colorDarkBlue,
                      negativeTextColor:
                          negativeTextColor ?? ColorManager.textColorWhite,
                      positiveButtonColor:
                          positiveButtonColor ?? ColorManager.colorRed,
                      positiveTextColor:
                          positiveTextColor ?? ColorManager.textColorWhite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
