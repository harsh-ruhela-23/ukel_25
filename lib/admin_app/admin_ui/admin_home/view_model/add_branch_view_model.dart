import 'package:flutter/material.dart';

class AddBranchViewModel extends ChangeNotifier {
  // TextEditingController
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController homeTownController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();
  TextEditingController ownerAddressController = TextEditingController();
  TextEditingController aadhaarNoController = TextEditingController();
  TextEditingController panNoController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool pwd1Toggle = true;
  bool pwd2Toggle = true;

  void setPwd1Toggle() {
    pwd1Toggle = !pwd1Toggle;
    notifyListeners();
  }

  void setPwd2Toggle() {
    pwd2Toggle = !pwd2Toggle;
    notifyListeners();
  }

  // dateOfBirth
  int? dateOfBirthDate;

  getDatePicker(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: dateOfBirthDate == null
          ? DateTime(1980)
          : DateTime.fromMillisecondsSinceEpoch(dateOfBirthDate!),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (datePicked != null) {
      dateOfBirthDate = datePicked.millisecondsSinceEpoch;
      notifyListeners();
    }
  }

  // gender
  String genderTypeRadioValue = "";

  setGenderValue(String value) {
    genderTypeRadioValue = value;
    notifyListeners();
  }
}
