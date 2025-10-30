import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../resource/color_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/default_button.dart';
import '../../../../widgets/custom_app_bar.dart';

class TellUsScreen extends StatefulWidget {
  const TellUsScreen({Key? key}) : super(key: key);

  static String routeName = "/tell_us_screen";

  @override
  TellUsScreenState createState() => TellUsScreenState();
}

class TellUsScreenState extends State<TellUsScreen> {
  TextEditingController concernController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController branchController = TextEditingController();

  final List<String> _tellUsSubjectList = ['Suggestion', 'Complain', 'Other'];
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "Tell Us",
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
                  Text(
                    'We Feel Connected when you share your valuable input with us.',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(height: 25.sp),
                  // concern
                  Text(
                    'Select Subject *',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),

                  SizedBox(height: 15.sp),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      border: Border.all(
                        color: const Color(0xff3C37FF),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.blue,
                      ),
                      isExpanded: true,
                      hint: const Text('Select Subject *'),
                      value: _selectedSubject,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      },
                      items: _tellUsSubjectList.map((subjects) {
                        return DropdownMenuItem(
                          value: subjects,
                          child: Text(
                            subjects,
                            style: getBoldStyle(
                                fontSize: 16.sp, color: ColorManager.primary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 25.sp),

                  // concern
                  Text(
                    'Describe your concern*',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),

                  buildTextFormField(
                      maxLines: 3,
                      controller: concernController,
                      hintText: 'Describe your concern*'),
                  SizedBox(height: 20.sp),

                  // name
                  Text(
                    'Your name',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                  buildTextFormField(
                      controller: nameController, hintText: 'Your name'),
                  SizedBox(height: 20.sp),

                  // number
                  Text(
                    'Number',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                  buildTextFormField(
                      controller: numberController, hintText: 'Number'),
                  SizedBox(height: 20.sp),

                  // branch
                  Text(
                    'Branch',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: 17.sp,
                    ),
                  ),
                  buildTextFormField(
                      controller: branchController, hintText: 'Branch'),
                  SizedBox(height: 20.sp),
                ],
              ),

              // submit button
              KeyboardVisibilityBuilder(builder: (context, visible) {
                return visible
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(top: 3.h),
                        child: DefaultButton(
                          text: 'Submit',
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

  Widget buildTextFormField(
      {required TextEditingController controller,
      required String hintText,
      int? maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.sp),
          borderSide: BorderSide(
            width: 1.5.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.sp),
          borderSide: BorderSide(
            width: 1.5.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.sp),
          borderSide: BorderSide(
            width: 1.5.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.sp),
          borderSide: BorderSide(
            width: 1.5.sp,
            color: const Color(0xffE4E5E9),
          ),
        ),
        hintText: hintText,
        hintStyle: getRegularStyle(
          color: ColorManager.colorGrey,
          fontSize: 17.sp,
        ),
      ),
    );
  }
}
