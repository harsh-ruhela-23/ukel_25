import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../resource/assets_manager.dart';
import '../../../../resource/color_manager.dart';
import '../../../../resource/fonts_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/default_button.dart';
import '../../../../widgets/custom_app_bar.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static String routeName = "/note_screen";

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "Note",
      ),
      body: Padding(
        padding: EdgeInsets.all(18.sp),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 18.sp),
                        child: noteItem(),
                      );
                    },
                  ),
                  SizedBox(height: 35.sp),
                ],
              ),

              // submit button
              KeyboardVisibilityBuilder(builder: (context, visible) {
                return visible
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(top: 3.h),
                        child: DefaultButton(
                          icon: SvgPicture.asset(IconAssets.iconNewNote,
                              color: Colors.white),
                          text: 'New Note',
                          onPress: () {},
                        ),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget noteItem() {
    return Slidable(
      key: const ValueKey(0),
      closeOnScroll: false,
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {},
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(15.sp, 15.sp, 0, 15.sp),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE4E5E9),
            width: 1.0,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service Odhana",
              style: getBoldStyle(
                color: ColorManager.primary,
                fontSize: FontSize.big,
              ),
            ),
            SizedBox(height: 15.sp),
            Text(
              "Jan 21, 18:03",
              style: getMediumStyle(
                color: ColorManager.colorGrey,
                fontSize: FontSize.big,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
