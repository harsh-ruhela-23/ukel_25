import 'package:flutter/material.dart';

import '../../../../model/branch_model.dart';
import '../../../../model/other/services_list_model.dart';
import '../../../../services/get_storage.dart';
import '../../../../utils/constants.dart';

class AddCraftsmanViewModel extends ChangeNotifier {
  AddCraftsmanViewModel() {
    connectedBranchController.text = Storage.getValue(FbConstant.branch);
  }

  // TextEditingController
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController craftsmanNameController = TextEditingController();
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

  TextEditingController connectedBranchController = TextEditingController();
  TextEditingController serviceInfoWorkingLocationController =
      TextEditingController();
  TextEditingController serviceChargesController = TextEditingController();

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

  // serviceType
  ServicesListModel? selectedServiceType;

  setServiceTypeValue(ServicesListModel value) {
    selectedServiceType = value;
    notifyListeners();
  }
}
