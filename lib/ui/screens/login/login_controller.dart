import 'package:flutter/cupertino.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/repository/user_repository.dart';
import 'package:ukel/ui/screens/login/select_role_dropdown.dart';
import 'package:ukel/utils/constants.dart';

import '../../../services/authentication_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/indicator.dart';

class LoginController extends ChangeNotifier {
  final formGlobalKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  UserRoleModel? selectedRole;

  bool pwdToggle = true;

  void setPwdToggle() {
    pwdToggle = !pwdToggle;
    notifyListeners();
  }

  setSelectedRole(UserRoleModel role) {
    emailController.clear();
    passwordController.clear();
    selectedRole = role;
    notifyListeners();
  }

  Future<bool> onLogin(BuildContext context) async {
    if (formGlobalKey.currentState!.validate()) {
      Indicator.showLoading();

      String result = await _authService.userLogin(
          selectedRole!.roleId, emailController.text, passwordController.text);

      if (result == AppConstant.success) {
        UserRepository repository = UserRepository();
        var result1 = await repository.searchUser(
            emailController.text, selectedRole!.roleId);
        List<UserModel> userList = result1[FbConstant.user];
        if (userList.isNotEmpty) {
          Indicator.closeIndicator();
          AppUtils.showToast('Login Successfully');
          return true;
        } else {
          Indicator.closeIndicator();
          AppUtils.showToast('User not found for selected role');
          return false;
        }
      } else {
        Indicator.closeIndicator();
        AppUtils.showToast(result);
        return false;
      }
    }
    return false;
  }
}
