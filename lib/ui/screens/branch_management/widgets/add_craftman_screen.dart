import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/AddNewServicesPage.dart';
import 'package:ukel/model/crafsman_model.dart';
import 'package:ukel/model/other/services_list_model.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/branch_management/viewModel/add_craftfsman_view_model.dart';
import 'package:ukel/ui/screens/home/craftsman/service_type_dropdown_widget.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/generate_id.dart';
import 'package:ukel/utils/indicator.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import 'package:ukel/repository/user_repository.dart';
import 'package:ukel/services/get_storage.dart';

import '../../../../SelectServicesPage.dart';
import '../../../../main.dart';
import '../../../../utils/custom_page_transition.dart';
import '../../drawer_item_screens/privacy_policy/privacy_policy_screen.dart';
import '../../home/service_invoice/service_invoice_repository.dart';

class AddCraftsManScreen extends StatefulWidget {
  const AddCraftsManScreen({Key? key}) : super(key: key);

  static String routeName = "/add_craftsman_screen";

  @override
  AddCraftsManScreenState createState() => AddCraftsManScreenState();
}

class AddCraftsManScreenState extends State<AddCraftsManScreen> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserRepository repository = UserRepository();
  List<ServicesListModel> servicesTypeDropdownList = [];
  List<ServicesListModel> _selectedServices = [];
  final ServiceInvoiceRepository _serviceInvoiceRepository =
      ServiceInvoiceRepository();
  final Map<String, List<_ServiceOptionSelection>> _serviceOptionSelections = {};
  final Set<String> _loadingServiceOptions = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    getServiceList();
  }

  Future<void> getServiceList() async {
    Map<String, dynamic> result =
        await _serviceInvoiceRepository.fetchServices();

    List<ServicesListModel> servicesList = result[FbConstant.service];

    if (servicesList.isNotEmpty) {
      servicesTypeDropdownList.addAll(servicesList);
    }
  }

  @override
  void dispose() {
    for (final selections in _serviceOptionSelections.values) {
      for (final selection in selections) {
        selection.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<String> addCraftsmanToUserCollection(UserModel userModel) async {
      String val = await repository.createUser(userModel.toJson());
      return val;
    }

    // createCraftsman
    Future<String> createCraftsman({
      required PersonalDetailsModel personalDetailsModel,
      required BankDetailsModel bankDetailsModel,
      required ServiceInfoModel serviceInfoModel,
      required AddCraftsmanViewModel viewModel,
    }) async {
      String apiStatus = AppConstant.somethingWentWrong;

      Indicator.showLoading();

      // register User With Email And Password
      UserCredential? result;
      try {
        result = await _auth.createUserWithEmailAndPassword(
          email: viewModel.emailController.text.trim(),
          password: viewModel.passwordController.text.trim(),
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

      String craftsmanId = user?.uid ?? generateRandomId();

      CraftsmanModel craftsmanModel = CraftsmanModel(
          branchId: Storage.getValue(FbConstant.uid),
          inJobIdsList: [],
          outJobIdsList: [],
          createdAtDate: DateTime.now().millisecondsSinceEpoch,
          appointed: 0,
          running: 0,
          qtPassed: 0,
          done: 0,
          id: craftsmanId,
          bankDetailsModel: bankDetailsModel,
          personalDetailsModel: personalDetailsModel,
          serviceInfoModel: serviceInfoModel);

      await HomeRepository()
          .createCraftsman(craftsmanModel.toJson())
          .then((status) async {
        UserModel userModel = UserModel(
          id: craftsmanId,
          role: "C",
          email: viewModel.emailController.text.trim(),
        );
        await addCraftsmanToUserCollection(userModel);
        Indicator.closeIndicator();
        apiStatus = status;
      });
      return apiStatus;
    }

    return ChangeNotifierProvider<AddCraftsmanViewModel>(
      create: (_) => AddCraftsmanViewModel(),
      child: Consumer<AddCraftsmanViewModel>(builder: (context, vModel, child) {
        return Scaffold(
          appBar: OtherScreenAppBar(
            onBackClick: () => AppUtils.navigateUp(context),
            title: "Add Craftsman",
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
                              text: 'Craftsman name *',
                              child: TextInputWidget(
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter Craftsman name';
                                  }
                                  return null;
                                },
                                controller: vModel.craftsmanNameController,
                                hintText: 'Craftsman name',
                              ),
                            ),
                            SizedBox(height: 10.sp),

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

                            // Email
                            textFormFieldTitleWidget(
                              text: 'Email *',
                              child: TextInputWidget(
                                  ignoreInputFormatter: true,
                                  textInputType: TextInputType.emailAddress,
                                  controller: vModel.emailController,
                                  hintText: 'Email'),
                            ),
                            SizedBox(height: 10.sp),

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
                            SizedBox(height: 20.sp),

                            // Home town
                            // textFormFieldTitleWidget(
                            //   text: 'Home town*',
                            //   child: TextInputWidget(
                            //       validator: (val) {
                            //         if (val == null || val.isEmpty) {
                            //           return 'Please enter Home town';
                            //         }
                            //         return null;
                            //       },
                            //       controller: vModel.homeTownController,
                            //       hintText: 'Home town *'),
                            // ),
                            SizedBox(height: 10.sp),

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
                                  hintText: 'Working location *'),
                            ),
                            SizedBox(height: 10.sp),

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
                                  inputFormatterRegex: "[a-zA-Z0-9, ]",
                                  hintText: 'Address *'),
                            ),
                            SizedBox(height: 10.sp),

                            // Aadhaar no.
                            // textFormFieldTitleWidget(
                            //   text: 'Aadhaar no. *',
                            //   child: TextInputWidget(
                            //       maxLength: 12,
                            //       validator: (String? val) {
                            //         if (val == null || val.isEmpty) {
                            //           return 'Please enter Aadhaar no';
                            //         } else if (val.length != 12) {
                            //           return 'Enter valid Aadhaar no';
                            //         }
                            //         return null;
                            //       },
                            //       textInputType: TextInputType.number,
                            //       controller: vModel.aadhaarNoController,
                            //       hintText: 'Aadhaar no. *'),
                            // ),

                            // Pan no.
                            // textFormFieldTitleWidget(
                            //   text: 'Pan no. *',
                            //   child: TextInputWidget(
                            //       maxLength: 10,
                            //       validator: (String? id) {
                            //         if (id != null) {
                            //           id = id.trim();
                            //         }
                            //         if (id == null || id.isEmpty) {
                            //           return 'Please enter PAN no';
                            //         } else if (id.length != 10) {
                            //           return 'Enter valid PAN no';
                            //         }
                            //         return null;
                            //       },
                            //       controller: vModel.panNoController,
                            //       hintText: 'Pan no. *'),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),

                      // Bank Details
                      // Text(
                      //   'Bank Details',
                      //   style: getBoldStyle(
                      //     color: ColorManager.colorDarkBlue,
                      //     fontSize: FontSize.large,
                      //   ),
                      // ),
                      // SizedBox(height: 15.sp),
                      // Container(
                      //   padding: EdgeInsets.all(20.sp),
                      //   decoration: BoxDecoration(
                      //     border:
                      //         Border.all(color: ColorManager.colorLightGrey),
                      //     borderRadius: BorderRadius.circular(10.sp),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       // Bank name
                      //       textFormFieldTitleWidget(
                      //         text: 'Bank name *',
                      //         child: TextInputWidget(
                      //             validator: (val) {
                      //               if (val == null || val.isEmpty) {
                      //                 return 'Please enter Bank name';
                      //               }
                      //               return null;
                      //             },
                      //             controller: vModel.bankNameController,
                      //             hintText: 'Bank name *'),
                      //       ),
                      //       SizedBox(height: 10.sp),
                      //
                      //       // Branch
                      //       textFormFieldTitleWidget(
                      //         text: 'Branch *',
                      //         child: TextInputWidget(
                      //             validator: (val) {
                      //               if (val == null || val.isEmpty) {
                      //                 return 'Please enter Branch';
                      //               }
                      //               return null;
                      //             },
                      //             controller: vModel.branchController,
                      //             hintText: 'Branch *'),
                      //       ),
                      //       SizedBox(height: 10.sp),
                      //
                      //       // Branch
                      //       textFormFieldTitleWidget(
                      //         text: 'Account holder\'s name *',
                      //         child: TextInputWidget(
                      //             validator: (val) {
                      //               if (val == null || val.isEmpty) {
                      //                 return 'Please enter Account holder\'s name';
                      //               }
                      //               return null;
                      //             },
                      //             controller:
                      //                 vModel.accountHolderNameController,
                      //             hintText: 'Account holder\'s name *'),
                      //       ),
                      //       SizedBox(height: 10.sp),
                      //
                      //       // A/c No.
                      //       textFormFieldTitleWidget(
                      //         text: 'A/c No. *',
                      //         child: TextInputWidget(
                      //             maxLength: 20,
                      //             textInputType: TextInputType.number,
                      //             validator: (val) {
                      //               if (val == null || val.isEmpty) {
                      //                 return 'Please enter A/c No';
                      //               }
                      //               return null;
                      //             },
                      //             controller: vModel.accountNoController,
                      //             hintText: 'A/c No. *'),
                      //       ),
                      //       SizedBox(height: 10.sp),
                      //
                      //       // IFSC Code*
                      //       textFormFieldTitleWidget(
                      //         text: 'IFSC Code *',
                      //         child: TextInputWidget(
                      //             maxLength: 11,
                      //             validator: (val) {
                      //               if (val == null || val.isEmpty) {
                      //                 return 'Please enter IFSC Code';
                      //               }
                      //               return null;
                      //             },
                      //             controller: vModel.ifscCodeController,
                      //             hintText: 'IFSC Code *'),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(height: 20.sp),

                      // Service info
                      Text(
                        'Service info',
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
                            // Work Capacity *
                            // textFormFieldTitleWidget(
                            //   text: 'Work Capacity * (Job per day)',
                            //   child: TextInputWidget(
                            //       validator: (val) {
                            //         if (val == null || val.isEmpty) {
                            //           return 'Please enter Work Capacity';
                            //         }
                            //         return null;
                            //       },
                            //       textInputType: TextInputType.number,
                            //       controller: vModel.workCapacityController,
                            //       hintText: 'Work Capacity *'),
                            // ),

                            SizedBox(height: 10.sp),
                            // Replace MultiSelectDialogField with this GestureDetector
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SelectServicesPage(
                                            items: servicesTypeDropdownList,
                                            initiallySelected: _selectedServices,
                                          ),
                                        ),
                                      );

                                      if (result != null &&
                                          result is List<ServicesListModel>) {
                                        setState(() {
                                          _selectedServices = result;
                                        });
                                        _syncServiceOptionSelections();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: ColorManager.colorGrey.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Select Services",
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                          const Icon(Icons.arrow_drop_down, color: Colors.black),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddNewServicesPage()),
                                    );
                                    if (result != null &&
                                        result is ServicesListModel) {
                                      // First update the list
                                      servicesTypeDropdownList.add(result);

                                      // Then rebuild both list + selected
                                      setState(() {
                                        _selectedServices =
                                            List.from(_selectedServices)
                                              ..add(result);
                                      });
                                      _syncServiceOptionSelections();
                                    }
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, top: 12.0),
                                    child: Icon(Icons.add, color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            ..._buildServiceInputFields(_selectedServices),

                            // ServiceTypeDropDownWidget(
                            //   selectedServiceType: vModel.selectedServiceType,
                            //   onServiceSelected: (p0) {
                            //     vModel.setServiceTypeValue(p0!);
                            //   },
                            // ),
                            // SizedBox(height: 20.sp),

                            // Connected branch*
                            textFormFieldTitleWidget(
                              text: 'Connected branch *',
                              child: TextInputWidget(
                                  isEnable: false,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter Connected branch';
                                    }
                                    return null;
                                  },
                                  controller: vModel.connectedBranchController,
                                  hintText: 'Connected branch *'),
                            ),
                            SizedBox(height: 15.sp),

                            // Working location*
                            // textFormFieldTitleWidget(
                            //   text: 'Working location *',
                            //   child: TextInputWidget(
                            //       validator: (val) {
                            //         if (val == null || val.isEmpty) {
                            //           return 'Please enter Working location';
                            //         }
                            //         return null;
                            //       },
                            //       controller: vModel
                            //           .serviceInfoWorkingLocationController,
                            //       hintText: 'Working location *'),
                            // ),
                            // SizedBox(height: 15.sp),
                            //
                            // // Connected branch*
                            // textFormFieldTitleWidget(
                            //   text: 'Service Charges * (Per Piece)',
                            //   child: TextInputWidget(
                            //     isLastField: true,
                            //     textInputType: TextInputType.number,
                            //     ignoreInputFormatter: true,
                            //     validator: (val) {
                            //       if (val == null || val.isEmpty) {
                            //         return 'Please enter Service Charges';
                            //       }
                            //       return null;
                            //     },
                            //     controller: vModel.serviceChargesController,
                            //     hintText: 'Service Charges *',
                            //   ),
                            // ),
                            // SizedBox(height: 20.sp),

                            Text(
                              'Account info',
                              style: getBoldStyle(
                                color: ColorManager.colorDarkBlue,
                                fontSize: FontSize.large,
                              ),
                            ),
                            SizedBox(height: 15.sp),
                            Container(
                              padding: EdgeInsets.all(15.sp),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorManager.colorLightGrey),
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
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorGrey
                                                  .withOpacity(0.3),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorGrey
                                                  .withOpacity(0.5),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorRed,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorRed,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        errorStyle: getMediumStyle(
                                          color: ColorManager.textColorRed,
                                          fontSize: FontSize.medium,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 15.sp, vertical: 0.sp),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 4, 0),
                                          child: GestureDetector(
                                            onTap: () => vModel.setPwd1Toggle(),
                                            child: vModel.pwd1Toggle
                                                ? const Icon(
                                                    Icons.visibility_rounded,
                                                    size: 24,
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .visibility_off_rounded,
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
                                  SizedBox(height: 15.sp),

                                  // Confirm Password *
                                  textFormFieldTitleWidget(
                                    text: 'Confirm Password *',
                                    child: TextFormField(
                                      controller:
                                          vModel.confirmPasswordController,
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
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorGrey
                                                  .withOpacity(0.3),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorGrey
                                                  .withOpacity(0.5),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorRed,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorManager.colorRed,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        errorStyle: getMediumStyle(
                                          color: ColorManager.textColorRed,
                                          fontSize: FontSize.medium,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 15.sp, vertical: 0.sp),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 4, 0),
                                          child: GestureDetector(
                                            onTap: () => vModel.setPwd2Toggle(),
                                            child: vModel.pwd2Toggle
                                                ? const Icon(
                                                    Icons.visibility_rounded,
                                                    size: 24,
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .visibility_off_rounded,
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
                                            vModel.confirmPasswordController
                                                .text) {
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
              if (vModel.dateOfBirthDate == null) {
                AppUtils.showToast('Please Select date of birth');
                return;
              }
              if (vModel.genderTypeRadioValue.isEmpty) {
                AppUtils.showToast('Please Select gender');
                return;
              }
              if (formKey.currentState!.validate()) {
                if (_selectedServices.isEmpty) {
                  AppUtils.showToast('Please select at least one service');
                  return;
                }

                final List<String> selectedNames = [];
                final List<String> selectedPrices = [];
                final List<String> selectedCapacities = [];

                for (final service in _selectedServices) {
                  final optionSelections = _serviceOptionSelections[service.id];

                  if (optionSelections != null && optionSelections.isNotEmpty) {
                    final chosenOptions = optionSelections
                        .where((option) => option.isSelected)
                        .toList();

                    if (chosenOptions.isEmpty) {
                      AppUtils.showToast(
                          'Please select at least one option for ${service.name}');
                      return;
                    }

                    for (final option in chosenOptions) {
                      final price = option.priceController.text.trim();
                      final capacity = option.capacityController.text.trim();

                      if (price.isEmpty || capacity.isEmpty) {
                        AppUtils.showToast(
                            'Enter price and capacity for ${service.name} - ${option.option.label}');
                        return;
                      }

                      selectedNames
                          .add('${service.name} - ${option.option.label}');
                      selectedPrices.add(price);
                      selectedCapacities.add(capacity);
                    }
                  } else {
                    final price = service.price?.trim() ?? '';
                    final capacity = service.capacity?.trim() ?? '';

                    if (price.isEmpty || capacity.isEmpty) {
                      AppUtils.showToast(
                          'Enter price and capacity for ${service.name}');
                      return;
                    }

                    selectedNames.add(service.name);
                    selectedPrices.add(price);
                    selectedCapacities.add(capacity);
                  }
                }

                if (selectedNames.isEmpty) {
                  AppUtils.showToast('Please select at least one service');
                  return;
                }

                setState(() {
                  _isSaving = true;
                });

                try {
                  final value = await createCraftsman(
                    personalDetailsModel: PersonalDetailsModel(
                        phoneNumber: vModel.phoneNoController.text,
                        name: vModel.craftsmanNameController.text,
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
                    serviceInfoModel: ServiceInfoModel(
                        workCapacity: 1,
                        serviceType: " Not ",
                        connectedBranch: vModel.connectedBranchController.text,
                        workingLocation:
                            vModel.serviceInfoWorkingLocationController.text,
                        serviceCharges: 0,
                        selectedServiceNames: selectedNames,
                        selectedServicePrice: selectedPrices,
                        selectedServiceCapacity: selectedCapacities),
                    viewModel: vModel,
                  );

                  if (!mounted) return;
                  if (value == AppConstant.success) {
                    AppUtils.showToast(AppConstant.craftsmanAddedSuccess);
                    Navigator.pop(context, true);
                  } else {
                    AppUtils.showToast(value);
                  }
                } catch (error) {
                  AppUtils.showToast('Failed to save craftsman. Please try again.');
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

  void _syncServiceOptionSelections() {
    final selectedIds = _selectedServices.map((service) => service.id).toSet();

    final idsToRemove = _serviceOptionSelections.keys
        .where((id) => !selectedIds.contains(id))
        .toList();

    for (final id in idsToRemove) {
      final selections = _serviceOptionSelections.remove(id);
      if (selections != null) {
        for (final selection in selections) {
          selection.dispose();
        }
      }
    }

    _loadingServiceOptions.removeWhere((id) => !selectedIds.contains(id));

    for (final service in _selectedServices) {
      if (!_serviceOptionSelections.containsKey(service.id)) {
        _initializeServiceOptions(service);
      }
    }
  }

  Future<void> _initializeServiceOptions(ServicesListModel service) async {
    if (_serviceOptionSelections.containsKey(service.id) ||
        _loadingServiceOptions.contains(service.id)) {
      return;
    }

    _loadingServiceOptions.add(service.id);
    if (mounted) {
      setState(() {});
    }

    final List<_ServiceOptionSelection> optionSelections = [];

    try {
      final List<ServiceType> serviceTypes =
          await _serviceInvoiceRepository.resolveServiceTypes(service);

      for (final serviceType in serviceTypes) {
        if (serviceType.type.toLowerCase() == 'radio' &&
            serviceType.option != null) {
          optionSelections.addAll(serviceType.option!
              .map((option) => _ServiceOptionSelection(option: option)));
        }
      }
    } finally {
      _loadingServiceOptions.remove(service.id);
    }

    if (!mounted) {
      for (final option in optionSelections) {
        option.dispose();
      }
      return;
    }

    if (!_selectedServices.any((element) => element.id == service.id)) {
      for (final option in optionSelections) {
        option.dispose();
      }
      return;
    }

    setState(() {
      _serviceOptionSelections[service.id] = optionSelections;
    });
  }

  List<Widget> _buildServiceInputFields(
      List<ServicesListModel> selectedServices) {
    return selectedServices.map((service) {
      final optionSelections = _serviceOptionSelections[service.id];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: getBoldStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.large,
            ),
          ),
          SizedBox(height: 10.sp),
          if (_loadingServiceOptions.contains(service.id))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (optionSelections != null && optionSelections.isNotEmpty)
            Column(
              children: optionSelections.map((selection) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selection.isSelected,
                      onChanged: (value) {
                        setState(() {
                          selection.isSelected = value ?? false;
                        });
                      },
                      title: Text(
                        '${selection.option.label} (₹${selection.option.charges})',
                        style: getRegularStyle(
                          color: ColorManager.textColorBlack,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
                    ),
                    if (selection.isSelected)
                      Row(
                        children: [
                          Expanded(
                            child: textFormFieldTitleWidget(
                              text: 'Price *',
                              child: TextFormField(
                                controller: selection.priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 15.sp),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorManager.colorGrey
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorManager.colorGrey
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.sp),
                          Expanded(
                            child: textFormFieldTitleWidget(
                              text: 'Capacity *',
                              child: TextFormField(
                                controller: selection.capacityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 15.sp),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorManager.colorGrey
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorManager.colorGrey
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10.sp),
                  ],
                );
              }).toList(),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: textFormFieldTitleWidget(
                    text: 'Price *',
                    child: TextFormField(
                      initialValue: service.price ?? '',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15.sp),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorManager.colorGrey.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorManager.colorGrey.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                      onChanged: (v) => setState(() => service.price = v),
                    ),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: textFormFieldTitleWidget(
                    text: 'Capacity *',
                    child: TextFormField(
                      initialValue: service.capacity,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15.sp),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorManager.colorGrey.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorManager.colorGrey.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                      onChanged: (v) => setState(() => service.capacity = v),
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 15.sp),
        ],
      );
    }).toList();
  }

// Widget buildTextFormField(
//     {required TextEditingController controller,
//     required String hintText,
//     TextInputType? keyboardType = TextInputType.name,
//     int? maxLines = 1}) {
//   return TextField(
//     maxLines: maxLines,
//     controller: controller,
//     keyboardType: keyboardType,
//     decoration: InputDecoration(
//       contentPadding: EdgeInsets.zero,
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.sp),
//         borderSide: BorderSide(
//           width: 2.sp,
//           color: Colors.grey.withOpacity(0.8),
//         ),
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.sp),
//         borderSide: BorderSide(
//           width: 2.sp,
//           color: Colors.grey.withOpacity(0.8),
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.sp),
//         borderSide: BorderSide(
//           width: 2.sp,
//           color: Colors.grey.withOpacity(0.8),
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.sp),
//         borderSide: BorderSide(
//           width: 2.sp,
//           color: Colors.grey.withOpacity(0.8),
//         ),
//       ),
//       // hintText: hintText,
//       // hintStyle: getRegularStyle(
//       //   color: ColorManager.colorGrey,
//       //   fontSize: 17.sp,
//       // ),
//     ),
//   );
// }
}

class _ServiceOptionSelection {
  _ServiceOptionSelection({required this.option})
      : priceController = TextEditingController(),
        capacityController = TextEditingController();

  final ServiceOptionModel option;
  bool isSelected = false;
  final TextEditingController priceController;
  final TextEditingController capacityController;

  void dispose() {
    priceController.dispose();
    capacityController.dispose();
  }
}
