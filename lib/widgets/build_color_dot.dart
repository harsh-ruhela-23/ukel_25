import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BuildColorDot extends StatelessWidget {
  const BuildColorDot({Key? key, required this.color, this.size})
      : super(key: key);

  final Color color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size ?? 18.sp),
        border: Border.all(color: color, width: 3.sp),
      ),
      child: Container(
        height: size ?? 18.sp,
        width: size ?? 18.sp,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18.sp),
        ),
      ),
    );
  }
}
