import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import '../../../model/other/notification_item_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  static String routeName = "/notification_screen";

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItemModel> list = [];

  @override
  void initState() {
    super.initState();
    setData();
  }

  setData() {
    list.add(NotificationItemModel("#A002.1 Need to Quality test and packing",
        "Jan 26, 2021 8:30", 0, false));
    list.add(NotificationItemModel(
        "Successfully add a craftman", "Jan 26, 2021 8:30", 1, true));
    list.add(NotificationItemModel("Your order had been successfully placed",
        "Jan 26, 2021 8:30", 0, true));
    list.add(NotificationItemModel(
        "#To-do is over loaded (5-5)", "Jan 26, 2021 8:30", 2, false));
    list.add(NotificationItemModel(
        "Odhana Job is done", "Jan 26, 2021 8:30", 2, true));
    list.add(NotificationItemModel(
        "#A0023.2 Odhana job done by Rinkuba pickup it from Gandhinagar",
        "Jan 26, 2021 8:30",
        1,
        false));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () {
            AppUtils.navigateUp(context);
          },
          title: "Notifications",
        ),
        body: Container(
          margin: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorManager.colorGrey,
              width: 3.sp,
            ),
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return NotificationItemWidget(
                      data: list[index],
                      itemIndex: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget(
      {Key? key, required this.itemIndex, required this.data})
      : super(key: key);

  final int itemIndex;
  final NotificationItemModel data;

  Widget getWidgetByType() {
    if (data.type == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://images.unsplash.com/2/04.jpg?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
                  width: 40.sp,
                  height: 30.sp,
                  fadeInCurve: Curves.easeIn,
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => const SizedBox(),
                  fadeInDuration: const Duration(seconds: 1),
                ),
              ),
              SizedBox(width: 15.sp),
              Expanded(
                child: Text(
                  data.title,
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ),
              !data.isRead
                  ? Row(
                      children: [
                        SizedBox(width: 10.sp),
                        Container(
                          height: 12.sp,
                          width: 12.sp,
                          decoration: BoxDecoration(
                            color: ColorManager.colorBlue,
                            borderRadius: BorderRadius.circular(13.sp),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: 10.sp),
          Text(
            data.date,
            style: getRegularStyle(
              color: ColorManager.textColorGrey,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      );
    } else if (data.type == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(IconAssets.iconNotificationSuccess),
              SizedBox(width: 15.sp),
              Expanded(
                child: Text(
                  data.title,
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ),
              !data.isRead
                  ? Row(
                      children: [
                        SizedBox(width: 10.sp),
                        Container(
                          height: 12.sp,
                          width: 12.sp,
                          decoration: BoxDecoration(
                            color: ColorManager.colorBlue,
                            borderRadius: BorderRadius.circular(13.sp),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: 10.sp),
          Text(
            data.date,
            style: getRegularStyle(
              color: ColorManager.textColorGrey,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ),
              !data.isRead
                  ? Row(
                      children: [
                        SizedBox(width: 10.sp),
                        Container(
                          height: 12.sp,
                          width: 12.sp,
                          decoration: BoxDecoration(
                            color: ColorManager.colorBlue,
                            borderRadius: BorderRadius.circular(13.sp),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: 10.sp),
          Text(
            data.date,
            style: getRegularStyle(
              color: ColorManager.textColorGrey,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15.sp,
        right: 15.sp,
        top: itemIndex == 0 ? 15.sp : 0.sp,
        bottom: 20.sp,
      ),
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                if (kDebugMode) {
                  print("clicked===");
                }
              },
              child: getWidgetByType()),
        ],
      ),
    );
  }
}
