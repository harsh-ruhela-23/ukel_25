import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';

class TextInputWidget extends StatelessWidget {
  const TextInputWidget(
      {Key? key,
      required this.controller,
      this.textStyle,
      this.hintStyle,
      this.hintText,
      this.inputDecoration,
      this.validator,
      this.errorStyle,
      this.contentPadding,
      this.textInputType = TextInputType.text,
      this.textCapitalization = TextCapitalization.none,
      this.maxLength,
      this.isLastField,
      this.inputFormatterRegex,
      this.ignoreInputFormatter,
      this.onChange,
      this.preFixText,
      this.prefixStyle,
      this.isToShowCounterText,
      this.isEnable})
      : super(key: key);

  final TextEditingController controller;
  final TextStyle? textStyle, hintStyle, errorStyle;
  final String? hintText;
  final InputDecoration? inputDecoration;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isLastField, isEnable;
  final TextInputType? textInputType;
  final int? maxLength;
  final String? inputFormatterRegex;
  final bool? ignoreInputFormatter;
  final Function(String)? onChange;
  final String? preFixText;
  final TextStyle? prefixStyle;
  final bool? isToShowCounterText;
  final TextCapitalization? textCapitalization;

  @override
  Widget build(BuildContext context) {
    bool ignoreFormatter = ignoreInputFormatter ?? false;

    return TextFormField(
      key: key,
      maxLength: maxLength,
      keyboardType: textInputType,
      textCapitalization: textCapitalization!,
      controller: controller,
      enabled: isEnable ?? true,
      textInputAction:
          isLastField ?? false ? TextInputAction.done : TextInputAction.next,
      style: textStyle ??
          getRegularStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
      decoration: inputDecoration ??
          textFieldInputDecoration(
            hintText: hintText ?? '',
            isToShowCounterText: isToShowCounterText,
            preFixText: preFixText,
            prefixStyle: prefixStyle,
            errorStyle: errorStyle,
            contentPadding: contentPadding,
          ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: ignoreFormatter
          ? null
          : <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(inputFormatterRegex ?? "[a-zA-Z0-9 ]")),
            ],
      onChanged: onChange,
    );
  }
}

class TextAreaInputWidget extends StatelessWidget {
  const TextAreaInputWidget(
      {Key? key,
      this.maxLines,
      required this.controller,
      this.textStyle,
      this.hintStyle,
      this.errorStyle,
      this.hintText,
      this.inputDecoration,
      this.validator,
      this.contentPadding,
      this.preFixText,
      this.maxLength,
      this.isToShowCounterText,
      this.prefixStyle,
      this.autofocus = false})
      : super(key: key);

  final TextEditingController controller;
  final TextStyle? textStyle, hintStyle, errorStyle;
  final String? hintText;
  final InputDecoration? inputDecoration;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final String? preFixText;
  final TextStyle? prefixStyle;
  final int? maxLength;
  final bool? isToShowCounterText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.start,
      maxLength: maxLength,
      autofocus: autofocus,
      style: textStyle ??
          getRegularStyle(
            color: ColorManager.textColorBlack,
            fontSize: FontSize.mediumExtra,
          ),
      decoration: inputDecoration ??
          textFieldInputDecoration(
            hintText: hintText ?? '',
            isToShowCounterText: isToShowCounterText,
            prefixStyle: prefixStyle,
            preFixText: preFixText,
            errorStyle: errorStyle,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
          ),
      maxLines: maxLines ?? 3,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

InputDecoration textFieldInputDecoration(
    {String? preFixText,
    TextStyle? prefixStyle,
    TextStyle? errorStyle,
    bool? isToShowCounterText = false,
    required String hintText,
    EdgeInsetsGeometry? contentPadding}) {
  return InputDecoration(
    counterText: isToShowCounterText == false ? "" : null,
    prefixText: preFixText ?? '',
    prefixStyle: prefixStyle,
    alignLabelWithHint: true,
    hintText: hintText,
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
  );
}
