import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/color_model.dart';
import 'package:ukel/repository/user_repository.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/utils/indicator.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_input_fields.dart';

import '../../../services/get_storage.dart';
import 'add_new_branch_screen.dart';

class AddNewColorScreen extends StatefulWidget {
  const AddNewColorScreen({Key? key}) : super(key: key);

  @override
  AddNewColorScreenState createState() => AddNewColorScreenState();
}

class AddNewColorScreenState extends State<AddNewColorScreen> {
  final formKey = GlobalKey<FormState>();
  UserRepository repository = UserRepository();

  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    // add Color
    Future<String> addColor() async {
      String apiStatus = AppConstant.somethingWentWrong;

      Indicator.showLoading();

      CustomColorModel colorModel = CustomColorModel(
          id: generateRandomId(),
          colorCode: codeController.text,
          branchId: Storage.getValue(FbConstant.uid),
          name: nameController.text);

      await HomeRepository()
          .addColorToFirebase(colorModel.toJson())
          .then((status) async {
        Indicator.closeIndicator();
        apiStatus = status;
      });
      return apiStatus;
    }

    Color pickerColor = Color(0xff443a49);
    Color currentColor = Color(0xff443a49);
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () => AppUtils.navigateUp(context),
        title: "Add New Color",
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 18.sp),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.sp),
                  Container(
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorManager.colorLightGrey),
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Color name
                        textFormFieldTitleWidget(
                          text: 'Color Name *',
                          child: TextInputWidget(
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter Color name';
                                }
                                return null;
                              },
                              controller: nameController,
                              hintText: 'Color Name *'),
                        ),

                        // Color Code
                        textFormFieldTitleWidget(
                          text: 'Color Code *',
                          child: TextInputWidget(
                              isLastField: true,
                              // ignoreInputFormatter: false,
                              // inputFormatterRegex: r'^0xff[0-9a-fA-F]{0,6}$',
                              //textCapitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter Color Code in proper format';
                                }
                                if (!RegExp(r'^0xff[0-9a-fA-F]{6}$')
                                    .hasMatch(val)) {
                                  return 'Invalid color code format';
                                }
                                return null;
                              },
                              controller: codeController,
                              hintText: 'Color Code (0xff000000) *'),
                        ),
                        ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: changeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomView(
        isProcessing: _isSaving,
        onSaveClick: () async {
          if (_isSaving) return;
          if (formKey.currentState!.validate()) {
            setState(() {
              _isSaving = true;
            });

            try {
              final value = await addColor();
              if (!mounted) return;
              if (value == AppConstant.success) {
                AppUtils.showToast(AppConstant.newColorAddedSuccess);
                Navigator.pop(context, true);
              } else {
                AppUtils.showToast(value);
              }
            } catch (error) {
              AppUtils.showToast('Failed to add color. Please try again.');
            } finally {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            }
          }
        },
        onCancelClick: () {
          if (_isSaving) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  void changeColor(Color color) {
    print("Color code: 0x${color.value.toRadixString(16).padLeft(8, '0')}");
    codeController.text = "0x${color.value.toRadixString(16).padLeft(8, '0')}";
  }
}
