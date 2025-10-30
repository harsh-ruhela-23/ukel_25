import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../resource/assets_manager.dart';
import '../resource/color_manager.dart';
import '../resource/fonts_manager.dart';
import '../resource/styles_manager.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar(
      {Key? key,
      required this.onMenuClick,
      required this.onNotificationClick,
      required this.onScannerClick,
      required this.onSearchClick,
      required this.onRefreshClick,
      required this.isToShowRefreshedIcon})
      : super(key: key);

  final Function() onMenuClick,
      onNotificationClick,
      onScannerClick,
      onSearchClick,
      onRefreshClick;
  final bool isToShowRefreshedIcon;

  @override
  Widget build(BuildContext context) {
    TextStyle style = getBoldStyle(
      color: ColorManager.textColorBlack,
      fontSize: FontSize.mediumExtra,
    );

    return AppBar(
      backgroundColor: ColorManager.white,
      toolbarHeight: 32.sp,
      titleTextStyle: style,
      centerTitle: true,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 18.sp),
        child: GestureDetector(
          onTap: onMenuClick,
          child: SvgPicture.asset(
            IconAssets.iconMenu,
            height: 8.sp,
            width: 8.sp,
          ),
        ),
      ),
      leadingWidth: 26.sp,
      actions: [
        Row(
          children: [
            if (isToShowRefreshedIcon)
              GestureDetector(
                onTap: onRefreshClick,
                child: Icon(
                  Icons.refresh,
                  size: 23.sp,
                ),
              ),
            if (isToShowRefreshedIcon) SizedBox(width: 18.sp),
            GestureDetector(
              onTap: onSearchClick,
              child: SvgPicture.asset(
                IconAssets.iconSearch,
                height: 19.sp,
                width: 19.sp,
              ),
            ),
            SizedBox(width: 18.sp),
            GestureDetector(
              onTap: onScannerClick,
              child: SvgPicture.asset(
                IconAssets.iconScanner,
                height: 19.sp,
                width: 19.sp,
              ),
            ),
            SizedBox(width: 18.sp),
            // GestureDetector(
            //   onTap: onNotificationClick,
            //   child: SvgPicture.asset(
            //     IconAssets.iconNotification,
            //     height: 19.sp,
            //     width: 19.sp,
            //   ),
            // ),
            // SizedBox(width: 18.sp),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(32.sp);
}

class OtherScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OtherScreenAppBar(
      {Key? key,
      required this.onBackClick,
      this.title,
      this.actionIcon,
      this.onActionIconClick})
      : super(key: key);

  final Function() onBackClick;
  final String? title;
  final String? actionIcon;
  final Function()? onActionIconClick;

  @override
  Widget build(BuildContext context) {
    TextStyle style = getBoldStyle(
      color: ColorManager.textColorBlack,
      fontSize: FontSize.large,
    );

    return AppBar(
      backgroundColor: ColorManager.white,
      toolbarHeight: 32.sp,
      titleTextStyle: style,
      centerTitle: false,
      elevation: 0,
      title: Text(
        title ?? "",
        style: getBoldStyle(
          color: ColorManager.textColorBlack,
          fontSize: FontSize.large,
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(left: 15.sp),
        child: GestureDetector(
          onTap: onBackClick,
          child: SvgPicture.asset(
            IconAssets.iconBack,
            height: 10.sp,
            width: 10.sp,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 15.sp),
          child: Row(
            children: [
              actionIcon != null
                  ? GestureDetector(
                      onTap: onActionIconClick,
                      child: SvgPicture.asset(actionIcon!),
                    )
                  : const SizedBox(),
            ],
          ),
        )
      ],
      leadingWidth: 26.sp,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(32.sp);
}
