import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/craftsman_app/ui/screens/craftsman_home_screen.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/repository/user_repository.dart';
import 'package:ukel/resource/assets_manager.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/dashboard/dashboard_screen.dart';
import 'package:ukel/ui/screens/login/select_role_dropdown.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';
import 'package:ukel/utils/custom_page_transition.dart';
import 'package:ukel/widgets/custom_button_widgets.dart';
import 'package:ukel/widgets/custom_input_fields.dart';

import '../../../admin_app/admin_ui/admin_home/admin_home_screen.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String routeName = "/login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future forgotPassword(
      {required String email, required UserRoleModel role}) async {
    try {
      UserRepository repository = UserRepository();
      var result1 = await repository.searchUser(email, role.roleId);
      List<UserModel> userList = result1[FbConstant.user];
      if (userList.isNotEmpty) {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: email)
            .whenComplete(() {
          AppUtils.showToast("Password reset link sent to email");
        });
      } else {
        AppUtils.showToast('User not found for selected role');
      }
    } catch (err) {
      AppUtils.showToast(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formGlobalKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: Image.asset(ImageAssets.imgDashboardLogo,
                        width: isTablet ? 150.sp : 50.sp),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.all(15.sp),
                    padding: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorManager.colorGrey,
                        width: 3.sp,
                      ),
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Login",
                          style: getBoldStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.largeExtra,
                          ),
                        ),
                        SizedBox(height: 25.sp),
                        SelectRoleDropDownWidget(
                          selectedRole: controller.selectedRole,
                          onSelectedRole: (role) {
                            controller.setSelectedRole(role);
                          },
                        ),
                        SizedBox(height: 20.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email *",
                              style: getRegularStyle(
                                color: ColorManager.textColorGrey,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            TextInputWidget(
                                validator: (val) {
                                  const pattern =
                                      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                                      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                                      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                                      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                                      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                                      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                                      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                                  final regex = RegExp(pattern);

                                  if (val == null || val.isEmpty) {
                                    return 'Email is required';
                                  } else if (!regex.hasMatch(val)) {
                                    return 'Enter valid email';
                                  }
                                  return null;
                                },
                                ignoreInputFormatter: true,
                                controller: controller.emailController),
                            SizedBox(height: 15.sp),
                            GestureDetector(
                              onTap: () {
                                if (controller.selectedRole == null) {
                                  AppUtils.showToast(
                                      'Please enter role to reset password');
                                  return;
                                }
                                if (controller.emailController.text.isEmpty) {
                                  AppUtils.showToast(
                                      'Please enter email address to reset password');
                                  return;
                                }
                                forgotPassword(
                                    email:
                                        controller.emailController.text.trim(),
                                    role: controller.selectedRole!);
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Forgot password?",
                                  style: getRegularStyle(
                                    color: Colors.blue,
                                    fontSize: FontSize.mediumExtra,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.sp),
                            Text(
                              "Password *",
                              style: getRegularStyle(
                                color: ColorManager.textColorGrey,
                                fontSize: FontSize.mediumExtra,
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            TextFormField(
                              controller: controller.passwordController,
                              textInputAction: TextInputAction.done,
                              style: getRegularStyle(
                                color: ColorManager.textColorBlack,
                                fontSize: FontSize.mediumExtra,
                              ),
                              obscureText: controller.pwdToggle,
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
                                    onTap: () => controller.setPwdToggle(),
                                    child: controller.pwdToggle
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
                                  return 'Password is required';
                                }
                                return null;
                              },
                              //autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 15.sp : 20.sp),
                        ButtonWidget(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (controller.selectedRole != null) {
                              controller.onLogin(context).then((status) {
                                if (status == true) {
                                  if (controller.selectedRole?.roleId == "A" ||
                                      controller.selectedRole?.roleId == "D") {
                                    AppUtils.navigateAndRemoveUntil(
                                      context,
                                      CustomPageTransition(
                                        MyApp.myAppKey,
                                        AdminHomeScreen.routeName,
                                      ),
                                    );
                                  } else if (controller.selectedRole?.roleId ==
                                      "B") {
                                    AppUtils.navigateAndRemoveUntil(
                                      context,
                                      CustomPageTransition(
                                        MyApp.myAppKey,
                                        DashboardScreen.routeName,
                                      ),
                                    );
                                  } else {
                                    AppUtils.navigateAndRemoveUntil(
                                      context,
                                      CustomPageTransition(
                                        MyApp.myAppKey,
                                        CraftsmanHomeScreen.routeName,
                                      ),
                                    );
                                  }
                                }
                              });
                            } else {
                              AppUtils.showToast('Please Select a Role');
                            }
                          },
                          title: "Login",
                        ),
                        SizedBox(height: 10.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
