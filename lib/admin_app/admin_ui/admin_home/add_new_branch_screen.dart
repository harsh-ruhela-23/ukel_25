import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/view_model/add_branch_view_model.dart';
import 'package:ukel/model/branch_model.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/repository/user_repository.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/utils/indicator.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import 'package:provider/provider.dart';

import '../../../services/get_storage.dart';

class AddNewBranchScreen extends StatefulWidget {
  const AddNewBranchScreen({Key? key}) : super(key: key);

  @override
  AddNewBranchScreenState createState() => AddNewBranchScreenState();
}

class AddNewBranchScreenState extends State<AddNewBranchScreen> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserRepository repository = UserRepository();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    Future<String> addBranchUserToUserCollection(UserModel userModel) async {
      String val = await repository.createUser(userModel.toJson());
      return val;
    }

    // add New Branch
    Future<String> addNewBranch({
      required BranchDetailsModel branchDetailsModel,
      required BankDetailsModel bankDetailsModel,
      required String email,
      required String password,
      required String createdBy,
    }) async {
      String apiStatus = AppConstant.somethingWentWrong;

      Indicator.showLoading();

      // register User With Email And Password
      UserCredential? result;
      try {
        result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        Indicator.closeIndicator();
        if (e.code == 'email-already-in-use') {
          apiStatus =
              'The account already exists for that email, please use different email.';
        }
        return apiStatus;
      }

      final User? user = result.user;

      String branchId = user?.uid ?? generateRandomId();

      BranchModel craftsmanModel = BranchModel(
          createdAtDate: DateTime.now().millisecondsSinceEpoch,
          id: branchId,
          createdBy: createdBy,
          branchCode:
              generateBranchCodeByBranchName(branchDetailsModel.ownerAddress),
          bankDetailsModel: bankDetailsModel,
          branchDetailsModel: branchDetailsModel,
          sid: 0,
          tag: "00");

      await HomeRepository()
          .createNewBranch(craftsmanModel.toJson())
          .then((status) async {
        UserModel userModel = UserModel(
          id: branchId,
          role: "B",
          email: email,
        );
        await addBranchUserToUserCollection(userModel);
        Indicator.closeIndicator();
        apiStatus = status;
      });
      return apiStatus;
    }

    return ChangeNotifierProvider<AddBranchViewModel>(
      create: (_) => AddBranchViewModel(),
      child: Consumer<AddBranchViewModel>(builder: (context, vModel, child) {
        return Scaffold(
          appBar: OtherScreenAppBar(
            onBackClick: () => AppUtils.navigateUp(context),
            title: "Add New Branch",
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
                      Text(
                        'Branch Details',
                        style: getBoldStyle(
                          color: ColorManager.colorDarkBlue,
                          fontSize: FontSize.large,
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Container(
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: ColorManager.colorLightGrey),
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner name
                            textFormFieldTitleWidget(
                              text: 'Owner name *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Owner name';
                                    }
                                    return null;
                                  },
                                  controller: vModel.ownerNameController,
                                  hintText: 'Owner name'),
                            ),

                            // Phone Number
                            textFormFieldTitleWidget(
                              text: 'Mobile Number *',
                              child: TextInputWidget(
                                  maxLength: 10,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Mobile Number';
                                    }
                                    return null;
                                  },
                                  textInputType: TextInputType.phone,
                                  controller: vModel.mobileNumberController,
                                  hintText: 'Mobile Number *'),
                            ),

                            // Phone Number
                            textFormFieldTitleWidget(
                              text: 'Phone Number *',
                              child: TextInputWidget(
                                  maxLength: 10,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Phone Number';
                                    }
                                    return null;
                                  },
                                  textInputType: TextInputType.phone,
                                  controller: vModel.phoneNoController,
                                  hintText: 'Phone Number *'),
                            ),

                            // Email
                            textFormFieldTitleWidget(
                              text: 'Email*',
                              child: TextInputWidget(
                                ignoreInputFormatter: true,
                                validator: validateEmail,
                                textInputType: TextInputType.emailAddress,
                                controller: vModel.emailController,
                                hintText: 'Email',
                              ),
                            ),

                            // Date of birth
                            textFormFieldTitleWidget(
                              text: 'Date of birth *',
                              child: InkWell(
                                onTap: () => vModel.getDatePicker(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.sp),
                                      border: Border.all(
                                          color: ColorManager.colorGrey
                                              .withOpacity(0.5),
                                          width: 1)),
                                  child: Text(
                                    vModel.dateOfBirthDate == null
                                        ? 'dd/mm/yyyy'
                                        : AppUtils.parseDate(
                                            vModel.dateOfBirthDate!,
                                            AppConstant.dd_mm_yyyy),
                                  ),
                                ),
                              ),
                            ),

                            Text(
                              "Gender *",
                              style: getRegularStyle(
                                color: ColorManager.grey,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorManager.colorGrey,
                                  width: 3.sp,
                                ),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text(
                                        "Male",
                                        style: getBoldStyle(
                                          color: ColorManager.textColorBlack,
                                          fontSize: FontSize.big,
                                        ),
                                      ),
                                      value: AppConstant.male,
                                      groupValue: vModel.genderTypeRadioValue,
                                      onChanged: (value) {
                                        vModel.setGenderValue(value.toString());
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text(
                                        "Female",
                                        style: getBoldStyle(
                                          color: ColorManager.textColorBlack,
                                          fontSize: FontSize.big,
                                        ),
                                      ),
                                      value: AppConstant.female,
                                      groupValue: vModel.genderTypeRadioValue,
                                      onChanged: (value) {
                                        vModel.setGenderValue(value.toString());
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 15.sp),

                            // Home town
                            textFormFieldTitleWidget(
                              text: 'Home town *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Home town';
                                    }
                                    return null;
                                  },
                                  controller: vModel.homeTownController,
                                  hintText: 'Home town *'),
                            ),

                            // Shop Address
                            textFormFieldTitleWidget(
                              text: 'Shop Address *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Shop Address';
                                    }
                                    return null;
                                  },
                                  controller: vModel.shopAddressController,
                                  hintText: 'Shop Address *'),
                            ),

                            // Address
                            textFormFieldTitleWidget(
                              text: 'Owner Address *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Owner Address';
                                    }
                                    return null;
                                  },
                                  controller: vModel.ownerAddressController,
                                  hintText: 'Owner Address *'),
                            ),

                            // Aadhaar no.
                            textFormFieldTitleWidget(
                              text: 'Owner Aadhaar no. *',
                              child: TextInputWidget(
                                  maxLength: 12,
                                  validator: (String? val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Aadhaar no';
                                    } else if (val.length != 12) {
                                      return 'Enter valid Aadhaar no';
                                    }
                                    return null;
                                  },
                                  textInputType: TextInputType.number,
                                  controller: vModel.aadhaarNoController,
                                  hintText: 'Owner Aadhaar no. *'),
                            ),

                            // Pan no.
                            textFormFieldTitleWidget(
                              text: 'Owner Pan no. *',
                              child: TextInputWidget(
                                  maxLength: 10,
                                  validator: (String? id) {
                                    if (id != null) {
                                      id = id.trim();
                                    }
                                    if (id == null || id.isEmpty) {
                                      return 'Please enter PAN no';
                                    } else if (id.length != 10) {
                                      return 'Enter valid PAN no';
                                    }
                                    return null;
                                  },
                                  controller: vModel.panNoController,
                                  hintText: 'Owner Pan no. *'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),

                      // Bank Details
                      Text(
                        'Bank Details',
                        style: getBoldStyle(
                          color: ColorManager.colorDarkBlue,
                          fontSize: FontSize.large,
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Container(
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: ColorManager.colorLightGrey),
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        child: Column(
                          children: [
                            // Bank name
                            textFormFieldTitleWidget(
                              text: 'Bank name *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Bank name';
                                    }
                                    return null;
                                  },
                                  controller: vModel.bankNameController,
                                  hintText: 'Bank name *'),
                            ),

                            // Branch
                            textFormFieldTitleWidget(
                              text: 'Branch *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Branch';
                                    }
                                    return null;
                                  },
                                  controller: vModel.branchController,
                                  hintText: 'Branch *'),
                            ),

                            // Branch
                            textFormFieldTitleWidget(
                              text: 'Account holder\'s name *',
                              child: TextInputWidget(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Account holder\'s name';
                                    }
                                    return null;
                                  },
                                  controller:
                                      vModel.accountHolderNameController,
                                  hintText: 'Account holder\'s name *'),
                            ),

                            // A/c No.
                            textFormFieldTitleWidget(
                              text: 'A/c No. *',
                              child: TextInputWidget(
                                  maxLength: 20,
                                  textInputType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter A/c No';
                                    }
                                    return null;
                                  },
                                  controller: vModel.accountNoController,
                                  hintText: 'A/c No. *'),
                            ),

                            // IFSC Code*
                            textFormFieldTitleWidget(
                              text: 'IFSC Code *',
                              child: TextInputWidget(
                                  maxLength: 11,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter IFSC Code';
                                    }
                                    return null;
                                  },
                                  controller: vModel.ifscCodeController,
                                  hintText: 'IFSC Code *'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),

                      // Service info
                      Text(
                        'Account info',
                        style: getBoldStyle(
                          color: ColorManager.colorDarkBlue,
                          fontSize: FontSize.large,
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Container(
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: ColorManager.colorLightGrey),
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Password *
                            textFormFieldTitleWidget(
                              text: 'Password *',
                              child: TextFormField(
                                controller: vModel.passwordController,
                                textInputAction: TextInputAction.next,
                                style: getRegularStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.mediumExtra,
                                ),
                                obscureText: vModel.pwd1Toggle,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  hintText: 'Password *',
                                  labelText: "Password",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.5),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.3),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.5),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorRed, width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorRed, width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  errorStyle: getMediumStyle(
                                    color: ColorManager.textColorRed,
                                    fontSize: FontSize.medium,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15.sp, vertical: 0.sp),
                                  suffixIcon: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                    child: GestureDetector(
                                      onTap: () => vModel.setPwd1Toggle(),
                                      child: vModel.pwd1Toggle
                                          ? const Icon(
                                              Icons.visibility_rounded,
                                              size: 24,
                                            )
                                          : const Icon(
                                              Icons.visibility_off_rounded,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Password';
                                  }
                                  if (val.length < 6) {
                                    return 'Password should be at least 6 characters';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),

                            // Confirm Password *
                            textFormFieldTitleWidget(
                              text: 'Confirm Password *',
                              child: TextFormField(
                                controller: vModel.confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                style: getRegularStyle(
                                  color: ColorManager.textColorBlack,
                                  fontSize: FontSize.mediumExtra,
                                ),
                                obscureText: vModel.pwd2Toggle,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  hintText: 'Confirm Password *',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.5),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.3),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorGrey
                                            .withOpacity(0.5),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorRed, width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.colorRed, width: 1),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  errorStyle: getMediumStyle(
                                    color: ColorManager.textColorRed,
                                    fontSize: FontSize.medium,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15.sp, vertical: 0.sp),
                                  suffixIcon: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                    child: GestureDetector(
                                      onTap: () => vModel.setPwd2Toggle(),
                                      child: vModel.pwd2Toggle
                                          ? const Icon(
                                              Icons.visibility_rounded,
                                              size: 24,
                                            )
                                          : const Icon(
                                              Icons.visibility_off_rounded,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Confirm password';
                                  }
                                  if (vModel.passwordController.text !=
                                      vModel.confirmPasswordController.text) {
                                    return 'Password & Confirm password doesn\'t match';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(height: 10.sp),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.sp),
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
              if (vModel.dateOfBirthDate == null) {
                AppUtils.showToast('Please Select date of birth');
                return;
              }
              if (vModel.genderTypeRadioValue.isEmpty) {
                AppUtils.showToast('Please Select gender');
                return;
              }
              if (formKey.currentState!.validate()) {
                setState(() {
                  _isSaving = true;
                });

                try {
                  final value = await addNewBranch(
                    email: vModel.emailController.text.trim(),
                    password: vModel.passwordController.text.trim(),
                    createdBy: Storage.getValue(FbConstant.uid),
                    branchDetailsModel: BranchDetailsModel(
                      phoneNumber: vModel.phoneNoController.text,
                      ownerName: vModel.ownerNameController.text,
                      mobileNumber: vModel.mobileNumberController.text,
                      email: vModel.emailController.text,
                      dateOfBirth: vModel.dateOfBirthDate!,
                      gender: vModel.genderTypeRadioValue,
                      homeTown: vModel.homeTownController.text,
                      shopAddress: vModel.shopAddressController.text,
                      ownerAddress: vModel.ownerAddressController.text,
                      aadhaarNo: vModel.aadhaarNoController.text,
                      panNo: vModel.panNoController.text,
                    ),
                    bankDetailsModel: BankDetailsModel(
                      accountHolderName: vModel.accountHolderNameController.text,
                      bankName: vModel.bankNameController.text,
                      branch: vModel.branchController.text,
                      accountNo: vModel.accountNoController.text,
                      ifscCode: vModel.ifscCodeController.text,
                    ),
                  );

                  if (!mounted) return;
                  if (value == AppConstant.success) {
                    AppUtils.showToast(AppConstant.newBranchAddedSuccess);
                    Navigator.pop(context, true);
                  } else {
                    AppUtils.showToast(value);
                  }
                } catch (error) {
                  AppUtils.showToast('Failed to add branch. Please try again.');
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
      }),
    );
  }
}

Widget textFormFieldTitleWidget({required String text, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: getRegularStyle(
          color: ColorManager.grey,
          fontSize: FontSize.mediumExtra,
        ),
      ),
      SizedBox(height: 10.sp),
      child,
      SizedBox(height: 15.sp),
    ],
  );
}
