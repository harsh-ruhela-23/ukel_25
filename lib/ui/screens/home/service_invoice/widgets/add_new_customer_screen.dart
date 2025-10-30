import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:ukel/widgets/custom_input_fields.dart';
import 'package:ukel/services/get_storage.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({Key? key}) : super(key: key);

  static String routeName = "/add_new_customer_screen";

  @override
  State<AddNewCustomerScreen> createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  late ServiceViewModel viewModel;
  final formKey = GlobalKey<FormState>();
  CustomerModel? customerData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final arguments =
          (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>);
      String? phone = arguments["phone"] as String?;
      customerData = arguments["customerData"] as CustomerModel?;
      setPrefilledData();
      if (phone != null) {
        viewModel.addCustomerPhoneNoController.text = phone;
      }
    });
  }

  void setPrefilledData() {
    if (customerData != null) {
      viewModel.addCustomerPhoneNoController.text = customerData!.phone;
      viewModel.addCustomerNameController.text = customerData!.name;
      viewModel.addCustomerVillageController.text = customerData!.village;

      if (customerData!.membersData != null) {
        for (int i = 0; i < customerData!.membersData!.length; i++) {
          Widget memberWidget = const SizedBox();
          if (i == 0) {
            memberWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.sp),
                Text(
                  "Member #${memberWidgetList.length + 1}",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                Row(
                  children: [
                    Expanded(
                      child: TextInputWidget(
                        textInputType: TextInputType.text,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'field should not be empty';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                            text: customerData!.membersData![i].name),
                        onChange: (value) {
                          int index = memberWidgetList.indexOf(memberWidget);
                          membersData[index].name = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            memberWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.sp),
                Text(
                  "Member #${i + 1}",
                  style: getRegularStyle(
                    color: ColorManager.textColorGrey,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 10.sp),
                Row(
                  children: [
                    Expanded(
                      child: TextInputWidget(
                        textInputType: TextInputType.text,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'field should not be empty';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                            text: customerData!.membersData![i].name),
                        onChange: (value) {
                          int index = memberWidgetList.indexOf(memberWidget);
                          membersData[index].name = value;
                        },
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     membersData
                    //         .removeAt(memberWidgetList.indexOf(memberWidget));
                    //     memberWidgetList.remove(memberWidget);
                    //     setState(() {});
                    //   },
                    //   child: Container(
                    //     height: 25.sp,
                    //     width: 25.sp,
                    //     padding: EdgeInsets.all(5.sp),
                    //     margin: EdgeInsets.only(left: 10.sp),
                    //     decoration: BoxDecoration(
                    //       color: ColorManager.colorRed,
                    //       borderRadius: BorderRadius.circular(20.sp),
                    //     ),
                    //     child: Icon(
                    //       Icons.close_outlined,
                    //       color: ColorManager.white,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            );
          }
          memberWidgetList.add(memberWidget);
          membersData.add(customerData!.membersData![i]);
          setState(() {});
        }
      }
    } else {
      addInitialMember();
    }
  }

  @override
  void dispose() {
    viewModel.addCustomerNameController.clear();
    viewModel.addCustomerPhoneNoController.clear();
    viewModel.addCustomerVillageController.clear();
    super.dispose();
  }

  List<Widget> memberWidgetList = [];
  List<MembersModel> membersData = [];
  bool _isSaving = false;

  void addInitialMember() {
    Widget memberWidget = const SizedBox();
    memberWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.sp),
        Text(
          "Member #${memberWidgetList.length + 1}",
          style: getRegularStyle(
            color: ColorManager.textColorGrey,
            fontSize: FontSize.medium,
          ),
        ),
        SizedBox(height: 10.sp),
        Row(
          children: [
            Expanded(
              child: TextInputWidget(
                textInputType: TextInputType.text,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'field should not be empty';
                  }
                  return null;
                },
                controller: TextEditingController(),
                onChange: (value) {
                  int index = memberWidgetList.indexOf(memberWidget);
                  membersData[index].name = value;
                },
              ),
            ),
          ],
        ),
      ],
    );
    memberWidgetList.add(memberWidget);
    membersData.add(MembersModel());
    setState(() {});
  }

  void onAddMemberClick() {
    Widget memberWidget = const SizedBox();
    memberWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.sp),
        Text(
          "Member #${memberWidgetList.length + 1}",
          style: getRegularStyle(
            color: ColorManager.textColorGrey,
            fontSize: FontSize.medium,
          ),
        ),
        SizedBox(height: 10.sp),
        Row(
          children: [
            Expanded(
              child: TextInputWidget(
                textInputType: TextInputType.text,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'field should not be empty';
                  }
                  return null;
                },
                controller: TextEditingController(),
                onChange: (value) {
                  int index = memberWidgetList.indexOf(memberWidget);
                  membersData[index].name = value;
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                membersData.removeAt(memberWidgetList.indexOf(memberWidget));
                memberWidgetList.remove(memberWidget);
                setState(() {});
              },
              child: Container(
                height: 25.sp,
                width: 25.sp,
                padding: EdgeInsets.all(5.sp),
                margin: EdgeInsets.only(left: 10.sp),
                decoration: BoxDecoration(
                  color: ColorManager.colorRed,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Icon(
                  Icons.close_outlined,
                  color: ColorManager.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    memberWidgetList.add(memberWidget);
    membersData.add(MembersModel());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ServiceViewModel>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () => AppUtils.navigateUp(context),
          title: "Add New Customer",
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.sp),
                    margin: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorManager.colorGrey,
                        width: 3.sp,
                      ),
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phone Number *",
                          style: getRegularStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.medium,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        TextInputWidget(
                            textInputType: TextInputType.phone,
                            maxLength: 10,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'phone number should not be empty';
                              }
                              return null;
                            },
                            controller: viewModel.addCustomerPhoneNoController),
                        SizedBox(height: 15.sp),
                        Text(
                          "Customer name*",
                          style: getRegularStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.medium,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        TextInputWidget(
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'customer name should not be empty';
                            }
                            return null;
                          },
                          controller: viewModel.addCustomerNameController,
                        ),
                        SizedBox(height: 15.sp),
                        Text(
                          "Village *",
                          style: getRegularStyle(
                            color: ColorManager.textColorGrey,
                            fontSize: FontSize.medium,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        TextInputWidget(
                          isLastField: true,
                          controller: viewModel.addCustomerVillageController,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'village should not be empty';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.sp),
                        GestureDetector(
                          onTap: () {
                            onAddMemberClick();
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "+ Add Members",
                              style: getRegularStyle(
                                color: ColorManager.colorBlue,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                          ),
                        ),
                        ...memberWidgetList,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomView(
          isProcessing: _isSaving,
          onSaveClick: () async {
            if (_isSaving) return;
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              FocusScope.of(context).unfocus();

              if (membersData.isNotEmpty) {
                setState(() {
                  _isSaving = true;
                });

                try {
                  if (customerData != null) {
                    customerData!.name =
                        viewModel.addCustomerNameController.text;
                    customerData!.village =
                        viewModel.addCustomerVillageController.text;
                    customerData!.phone =
                        viewModel.addCustomerPhoneNoController.text;
                    customerData!.membersData = membersData;
                    customerData!.branchId =
                        Storage.getValue(FbConstant.uid);
                    final value = await viewModel.updateCustomer(customerData!);
                    if (!mounted) return;
                    if (value == AppConstant.success) {
                      viewModel.getCustomersList();
                      AppUtils.showToast(
                          AppConstant.newCustomerAddedSuccessfully);
                      Navigator.pop(context, customerData);
                    } else {
                      AppUtils.showToast(value);
                    }
                  } else {
                    final value = await viewModel.onAddCustomer(membersData);
                    if (!mounted) return;
                    if (value["result"] == AppConstant.success) {
                      viewModel.getCustomersList();
                      AppUtils.showToast(
                          AppConstant.newCustomerAddedSuccessfully);
                      Navigator.pop(context, value["data"] as CustomerModel);
                    } else {
                      AppUtils.showToast(value["result"]);
                    }
                  }
                } catch (error) {
                  AppUtils.showToast(
                      'Failed to save customer. Please try again.');
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              } else {
                AppUtils.showToast('Please add at least one member');
              }
            }
          },
          onCancelClick: () {
            if (_isSaving) return;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class BottomView extends StatelessWidget {
  const BottomView({
    Key? key,
    required this.onSaveClick,
    required this.onCancelClick,
    this.isProcessing = false,
    this.saveLabel = 'Save',
    this.processingLabel = 'Saving...',
  }) : super(key: key);

  final Function() onSaveClick, onCancelClick;
  final bool isProcessing;
  final String saveLabel;
  final String processingLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isProcessing ? null : onCancelClick,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
                decoration: BoxDecoration(color: ColorManager.btnColorWhite),
                child: Text(
                  "Cancel",
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.mediumExtra,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isProcessing ? null : onSaveClick,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
                decoration:
                    BoxDecoration(color: ColorManager.btnColorDarkBlue),
                child: isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.textColorWhite,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          Text(
                            processingLabel,
                            textAlign: TextAlign.center,
                            style: getBoldStyle(
                              color: ColorManager.textColorWhite,
                              fontSize: FontSize.mediumExtra,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        saveLabel,
                        textAlign: TextAlign.center,
                        style: getBoldStyle(
                          color: ColorManager.textColorWhite,
                          fontSize: FontSize.mediumExtra,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
