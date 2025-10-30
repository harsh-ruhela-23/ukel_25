import 'dart:ui';

class FbConstant {
  static const id = 'id';
  static const customer = 'customer';
  static const user = 'user';
  static const name = 'name';
  static const couponCode = 'code';
  static const coupon = 'coupon';
  static const amount = 'amount';
  static const nameForSearch = 'name_for_search';
  static const village = 'village';
  static const phone = 'phone';
  static const service = 'service';
  static const serviceType = 'service_type';
  static const serviceCharges = 'charges';
  static const serviceTypeModelList = 'type';
  static const unit = 'unit';
  static const value = 'value';
  static const option = 'option';
  static const label = 'label';
  static const type = 'type';
  static const uid = 'uid';
  static const currentUserId = 'current_user_id';
  static const branchId = 'branch_id';
  static const serviceData = 'service_data';
  static const serviceId = 'service_id';
  static const membersData = 'members_data';
  static const maxValue = 'max_value';
  static const minValue = 'min_value';
  static const validator = 'validator';

  // job item
  static const jobItem = 'job_item';
  static const jobId = 'jobId';
  static const jobServiceInvoiceId = 'service_invoice_id';
  static const jobItemCode = 'item_code';
  static const jobItemDueDate = 'due_date';
  static const jobItemCreatedAtDate = 'created_at_date';
  static const jobItemServiceId = 'service_id';
  static const jobItemServiceValues = 'service_values';
  static const jobItemNotes = 'notes';
  static const jobItemQty = 'qty';
  static const jobItemColorName = 'color_name';
  static const jobItemTotalCharge = 'total_charge';
  static const jobItemImageUrl = 'image_url';
  static const jobItemColor = 'color';
  static const jobItemPercentage = 'jobItemPercentage';
  static const jobItemCustomerId = 'customer_id';
  static const jobItemSelectedCraftsmanId = 'selected_craftsman_id';
  static const jobItemSelectedCraftsmanName = 'selected_craftsman_name';
  static const jobItemImages =
      'JobItemImages'; // for firebase storage folder name
  static const rejectCount = 'rejectCount';
  static const rejectReason = 'rejectReason';
  static const jobStatusObj = 'jobStatusObj';

  static const timelineStatusObj = 'timelineStatusObj';
  static const timelineStatusPer = 'timelineStatusPer';
  static const timelineTitle = 'timelineTitle';
  static const timelineSubTitle = 'timelineSubTitle';
  static const timelineBgColor = 'timelineBgColor';
  static const timelineIndicatorColor = 'timelineIndicatorColor';
  static const timelineIsComplete = 'timelineIsComplete';
  static const timelineIsReject = 'timelineIsReject';
  static const timelineIsFirst = 'timelineIsFirst';
  static const timelineIsLast = 'timelineIsLast';
  static const timelineCompleteDate = 'timelineCompleteDate';
  static const timelineRejectCount = 'timelineRejectCount';

  // service Invoice
  static const serviceInvoice = 'service_invoice';
  static const serviceInvoicePriceInfo = 'price_info';
  static const serviceInvoiceId = 'id';
  static const serviceInvoiceCode = 'invoice_code';
  static const serviceInvoiceDueDate = 'due_date';
  static const serviceInvoiceCreatedAtDate = 'created_at_date';
  static const serviceInvoiceNotes = 'notes';
  static const serviceInvoiceTotalQty = 'total_qty';
  static const serviceInvoiceTotalAmount = 'total_amount';
  static const serviceInvoiceReceivedAmount = 'received_amount';
  static const tag = 'tag';
  static const serviceInvoiceDueAmount = 'due_amount';
  static const serviceInvoicePaymentMode = 'payment_mode';
  static const serviceInvoiceCustomerId = 'customer_id';
  static const serviceInvoiceCustomerName = 'customer_name';
  // static const serviceInvoiceCustomerNameForSearch = 'customer_name_for_search';
  static const serviceInvoiceCustomerPhNo = 'customer_phno';
  static const serviceInvoiceCustomerVillage = 'customer_village';
  static const serviceInvoiceStatusValue = 'status_value';
  static const serviceInvoiceJobIds = 'job_ids';
  static const serviceInvoiceQty = 'qty';
  static const serviceInvoiceAmount = 'amount';

  // craftsman
  static const craftsman = 'craftsman';
  static const craftsmanIn = 'in';
  static const craftsmanOut = 'out';

  static const appointed = 'appointed';
  static const running = 'running';
  static const done = 'done';
  static const qtPassed = 'qtPassed';
  static const craftsmanPersonalDetails = 'personal_details';
  static const craftsmanBankDetails = 'bank_details';
  static const craftsmanServiceInfo = 'service_info';
  static const craftsmanId = 'id';
  static const createdBy = 'createdBy';
  static const craftsmanName = 'name';
  static const craftsmanPhoneNumber = 'phone_number';
  static const craftsmanMobileNumber = 'mobile_number';
  static const craftsmanEmail = 'email';
  static const craftsmanDateOfBirth = 'date_of_birth';
  static const craftsmanGender = 'gender';
  static const craftsmanHomeTown = 'home_town';
  static const craftsmanWorkingLocation = 'working_location';
  static const craftsmanAddress = 'address';
  static const craftsmanAadhaarNo = 'aadhaar_no';
  static const craftsmanPanNo = 'pan_no';
  static const sid = 'sid';

  static const craftsmanBankName = 'bank_name';
  static const craftsmanBranch = 'branch';
  static const craftsmanAccountNo = 'account_no';
  static const craftsmanAccountHolderName = 'account_holder_name';
  static const craftsmanIFSCCode = 'ifsc_code';

  static const craftsmanWorkingCapacity = 'working_capacity';
  static const craftsmanServiceType = 'service_type';
  static const craftsmanConnectedBranch = 'connected_branch';
  static const craftsmanServiceWorkingLocation = 'working_location';
  static const craftsmanServiceCharges = 'service_charges';

  static const craftsmanNoOfDays = 'no_of_days';
  static const craftsmanPendingJobs = 'pending_jobs';

  static const branch = 'branch';
  static const branchDetails = 'branch_details';
  static const branchCode = 'branch_code';
  static const ownerName = 'owner_name';
  static const branchShopAddress = 'shop_address';
  static const branchOwnerAddress = 'owner_address';

  // employee
  static const employee = 'employee';

  // color
  static const color = 'color';
  static const colorName = 'name';
  static const code = 'color_code';
}

class AppConstant {
  static const dd_mm_yyyy = "dd/MM/yyyy";
  static const yMMMMd = "yMMMMd";
  static const success = 'success';
  static const failed = 'failed';
  static const isLogin = 'isLogin';
  static const somethingWentWrong = 'something Went Wrong';
  static const noUserFound = 'Sorry Dear... !! No User Found.';
  static const newCustomerAddedSuccessfully = 'New Customer Added Successfully';
  static const jobItemAddedSuccess = 'Job Item Added Successfully';
  static const craftsmanAddedSuccess = 'Craftsman Added Successfully';
  static const newBranchAddedSuccess = 'New Branch Added Successfully';
  static const newColorAddedSuccess = 'New Color Added Successfully';
  static const newCouponAddedSuccess = 'New Coupon Added Successfully';
  static const couponAppliedSuccess = 'Coupon Applied Successfully';
  static const serviceInvoiceCreatedSuccess =
      'Service Invoice Created Successfully';
  static const cash = 'Cash';
  static const online = 'Online';

  static const male = 'Male';
  static const female = 'Female';

  // JobItem and ServiceInvoice Status
  static const inShop = 'In Shop';
  static const inProcess = 'In Process';
  static const shipment = 'Shipment';
  static const pickUp = 'Pick Up';
  static const packingQt = 'Packing & QT';
  static const tobeDeliver = 'To be Delivered';
  static const deliver = 'Delivered';

  static const pending = 'Pending';
  static const jobDone = 'Job Done';

  static const role = 'role';
  static const user = 'User';
  static const admin = 'Admin';
  static const subAdmin = 'Sub-Admin';
  static const branch = 'Branch';
  static const craftsman = 'Craftsman';
}

class BroadCastConstant {
  static const homeScreenUpdate = "homeScreenUpdate";
}

class JobStatusConstant {
  static const inShop = "IS";
  static const jobDone = "JD";
  static const outFromShop = "OFS";
  static const receivedShop = "RS";
  static const qualityTest = "QT";
  static const deliver = "D";

  static const craftsmanReceived = "CRW";
  static const outFromCraftsman = "OFC";
}

class JobPercentConstant {
  static const percent0 = "0";
  static const percent16 = "16";
  static const percent34 = "34";
  static const percent50 = "50";
  static const percent68 = "68";
  static const percent84 = "84";
  static const percent99 = "99";
  static const percent100 = "100";
}

class TimeLineTitleConstant {
  static const outFromShop = "Out From Shop";
  static const craftsmanReceivedWork = "Craftsman Received Work";
  static const jobDone = "Job Done";
  static const outFromCraftsman = "Out From Craftsman";
  static const receivedAtShop = "Received at Shop";
  static const qualityTestingAndPacking = "Quality Testing & Packing";
  static const delivered = "Delivered";
}

class IntToHexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex = "FF${hex.toUpperCase().replaceAll("#", "")}";
    return int.parse(formattedHex, radix: 16);
  }

  IntToHexColor(final String hex) : super(_getColor(hex));
}

// Input = 123456789012
// output = 1234 5678 9012
String formatAadhaarNumber(String aadhaarNumber) {
  if (aadhaarNumber.length != 12) {
    // Aadhaar number should be 12 digits long
    return aadhaarNumber;
  }

  // Insert spaces after every 4 digits
  return aadhaarNumber.replaceAllMapped(
      RegExp(r'.{4}'), (match) => '${match.group(0)} ');
}
