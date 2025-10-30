import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/coupon_model.dart';
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

class AddNewCouponScreen extends StatefulWidget {
  const AddNewCouponScreen({Key? key}) : super(key: key);

  @override
  AddNewCouponScreenState createState() => AddNewCouponScreenState();
}

class AddNewCouponScreenState extends State<AddNewCouponScreen> {
  final formKey = GlobalKey<FormState>();
  UserRepository repository = UserRepository();

  TextEditingController codeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    // add Coupon
    Future<String> addCoupon() async {
      String apiStatus = AppConstant.somethingWentWrong;

      Indicator.showLoading();

      CouponModel couponModel = CouponModel(
          id: generateRandomId(),
          amount: amountController.text,
          branchId: Storage.getValue(FbConstant.uid),
          code: codeController.text);

      await HomeRepository()
          .addCouponToFirebase(couponModel.toJson())
          .then((status) async {
        Indicator.closeIndicator();
        apiStatus = status;
      });
      return apiStatus;
    }

    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () => AppUtils.navigateUp(context),
        title: "Add New Coupon",
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
                          text: 'Coupon code *',
                          child: TextInputWidget(
                              maxLength: 6,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter coupon code';
                                }
                                return null;
                              },
                              controller: codeController,
                              hintText: 'Coupon code *'),
                        ),

                        // Color Code
                        textFormFieldTitleWidget(
                          text: 'Amount *',
                          child: TextInputWidget(
                              isLastField: true,
                              textInputType: TextInputType.number,
                              // ignoreInputFormatter: false,
                              // inputFormatterRegex: r'^0xff[0-9a-fA-F]{0,6}$',
                              //textCapitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter amount';
                                }
                                return null;
                              },
                              controller: amountController,
                              hintText: 'Amount *'),
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
              final value = await addCoupon();
              if (!mounted) return;
              if (value == AppConstant.success) {
                AppUtils.showToast(AppConstant.newCouponAddedSuccess);
                Navigator.pop(context, true);
              } else {
                AppUtils.showToast(value);
              }
            } catch (error) {
              AppUtils.showToast('Failed to add coupon. Please try again.');
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
}
