import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/employee_model.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import '../../../../resource/color_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/indicator.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../home/service_invoice/widgets/add_new_customer_screen.dart';
import '../viewModel/add_emp_view_model.dart';
import 'package:provider/provider.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  static String routeName = "/add_employee_screen";

  @override
  AddEmployeeScreenState createState() => AddEmployeeScreenState();
}

class AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    // add Employee
    Future<String> addEmployee({
      required PersonalDetailsModel personalDetailsModel,
      required BankDetailsModel bankDetailsModel,
    }) async {
      String apiStatus = AppConstant.somethingWentWrong;

      Indicator.showLoading();

      EmployeeModel employeeModel = EmployeeModel(
        createdAtDate: DateTime.now().millisecondsSinceEpoch,
        id: generateRandomId(),
        bankDetailsModel: bankDetailsModel,
        personalDetailsModel: personalDetailsModel,
      );

      await HomeRepository().addEmployee(employeeModel.toJson()).then((status) {
        Indicator.closeIndicator();
        apiStatus = status;
      });
      return apiStatus;
    }

    return ChangeNotifierProvider<AddEmployeeViewModel>(
      create: (_) => AddEmployeeViewModel(),
      child: Consumer<AddEmployeeViewModel>(builder: (context, vModel, child) {
        return Scaffold(
          appBar: OtherScreenAppBar(
            onBackClick: () => AppUtils.navigateUp(context),
            title: "Add Employee",
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
                        'Personal Details',
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
                                hintText: 'Phone Number *',
                              ),
                            ),

                            // name
                            textFormFieldTitleWidget(
                              text: 'Employee name *',
                              child: TextInputWidget(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Employee name';
                                  }
                                  return null;
                                },
                                controller: vModel.employeeNameController,
                                hintText: 'Employee name',
                              ),
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
                                hintText: 'Mobile Number *',
                              ),
                            ),

                            // Email
                            textFormFieldTitleWidget(
                              text: 'Email',
                              child: TextInputWidget(
                                ignoreInputFormatter: true,
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
                                        width: 1),
                                  ),
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
                                hintText: 'Home town *',
                              ),
                            ),

                            // Working location
                            textFormFieldTitleWidget(
                              text: 'Working location *',
                              child: TextInputWidget(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Working location';
                                  }
                                  return null;
                                },
                                controller: vModel.workingLocationController,
                                hintText: 'Working location *',
                              ),
                            ),

                            // Address
                            textFormFieldTitleWidget(
                              text: 'Address *',
                              child: TextInputWidget(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Address';
                                  }
                                  return null;
                                },
                                controller: vModel.addressController,
                                hintText: 'Address *',
                              ),
                            ),

                            // Aadhaar no.
                            textFormFieldTitleWidget(
                              text: 'Aadhaar no. *',
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
                                hintText: 'Aadhaar no. *',
                              ),
                            ),

                            // Pan no.
                            textFormFieldTitleWidget(
                              text: 'Pan no. *',
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
                                hintText: 'Pan no. *',
                              ),
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
                                hintText: 'Bank name *',
                              ),
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
                                hintText: 'Branch *',
                              ),
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
                                controller: vModel.accountHolderNameController,
                                hintText: 'Account holder\'s name *',
                              ),
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
                                hintText: 'A/c No. *',
                              ),
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
                                hintText: 'IFSC Code *',
                              ),
                            ),
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
                  final value = await addEmployee(
                    personalDetailsModel: PersonalDetailsModel(
                        phoneNumber: vModel.phoneNoController.text,
                        name: vModel.employeeNameController.text,
                        mobileNumber: vModel.mobileNumberController.text,
                        email: vModel.emailController.text,
                        dateOfBirth: vModel.dateOfBirthDate!,
                        gender: vModel.genderTypeRadioValue,
                        homeTown: vModel.homeTownController.text,
                        workingLocation: vModel.workingLocationController.text,
                        address: vModel.addressController.text,
                        aadhaarNo: vModel.aadhaarNoController.text,
                        panNo: vModel.panNoController.text),
                    bankDetailsModel: BankDetailsModel(
                        accountHolderName:
                            vModel.accountHolderNameController.text,
                        bankName: vModel.bankNameController.text,
                        branch: vModel.branchController.text,
                        accountNo: vModel.accountNoController.text,
                        ifscCode: vModel.ifscCodeController.text),
                  );

                  if (!mounted) return;
                  if (value == AppConstant.success) {
                    AppUtils.showToast(AppConstant.craftsmanAddedSuccess);
                    Navigator.pop(context, true);
                  } else {
                    AppUtils.showToast(value);
                  }
                } catch (error) {
                  AppUtils.showToast('Failed to save employee. Please try again.');
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

  Widget textFormFieldTitleWidget(
      {required String text, required Widget child}) {
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
}
