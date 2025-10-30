import 'package:flutter/material.dart';

class AddEmployeeViewModel extends ChangeNotifier {
  // TextEditingController
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController homeTownController = TextEditingController();
  TextEditingController workingLocationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController aadhaarNoController = TextEditingController();
  TextEditingController panNoController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();

  TextEditingController workCapacityController = TextEditingController();
  TextEditingController connectedBranchController = TextEditingController();
  TextEditingController serviceInfoWorkingLocationController =
      TextEditingController();
  TextEditingController serviceChargesController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
