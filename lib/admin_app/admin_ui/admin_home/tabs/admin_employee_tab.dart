import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/main.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_invoice_repository.dart';
import 'package:ukel/utils/common_widget.dart';

class AdminEmployeeTab extends StatefulWidget {
  const AdminEmployeeTab({Key? key, this.branchId}) : super(key: key);

  final String? branchId;

  @override
  State<AdminEmployeeTab> createState() => _AdminEmployeeTabState();
}

class _AdminEmployeeTabState extends State<AdminEmployeeTab> {
  final repository = ServiceInvoiceRepository();
  bool isCustomerListFetchingData = false;
  List<CustomerModel> customersList = [];
  String error = '';

  List<CustomerModel> searchResult = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCustomersList();
  }

  void getCustomersList() async {
    try {
      customersList.clear();
      if (!isCustomerListFetchingData) {
        isCustomerListFetchingData = true;

        await repository.fetchCustomers(branchId: widget.branchId).then((list) {
          if (list.isNotEmpty) {
            customersList.addAll(list);
          }
        });

        error = '';
        isCustomerListFetchingData = false;
      }
    } catch (e) {
      error = e.toString();
      isCustomerListFetchingData = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 15.sp),
            Expanded(
              child: isCustomerListFetchingData
                  ? Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: buildLoadingWidget,
              )
                  : error.isNotEmpty
                  ? buildEmptyDataWidget(error.toString())
                  : customersList.isEmpty
                  ? buildEmptyDataWidget('No Parties found!!')
                  : (searchResult.isNotEmpty ||
                  searchController.text.isNotEmpty)
                  ? buildSearchResultList()
                  : buildCustomerListWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchResultList() {
    return searchResult.isEmpty
        ? buildEmptyDataWidget("No Result Found!!")
        : SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResult.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.sp),
                  child: customerItemCard(searchResult[index]),
                );
              },
            ),
          );
  }

  Widget buildCustomerListWidget() {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: customersList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 15.sp),
            child: customerItemCard(customersList[index]),
          );
        },
      ),
    );
  }

  Widget buildSearchFieldCustomers() {
    return TextFormField(
      autofocus: false,
      controller: searchController,
      onChanged: (val) => onSearchTextChanged(val),
      decoration: InputDecoration(
        suffixIcon: searchController.text.isEmpty
            ? const SizedBox()
            : InkWell(
                child: const Icon(Icons.close, color: Colors.black),
                onTap: () {
                  searchController.clear();
                  onSearchTextChanged('');
                },
              ),
        contentPadding: isTablet
            ? EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp)
            : EdgeInsets.symmetric(horizontal: 15.sp),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(
            width: 2.sp,
            color: Colors.grey,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(
            width: 2.sp,
            color: Colors.grey,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(
            width: 2.sp,
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(
            width: 2.sp,
            color: Colors.grey,
          ),
        ),
        hintText: 'Search Partys',
        hintStyle: getRegularStyle(
          color: ColorManager.colorGrey,
          fontSize: FontSize.mediumExtra,
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    searchResult.clear();
    // if (text.isEmpty) {
    //   setState(() {});
    //   return;
    // }

    for (var customerDetails in customersList) {
      if (customerDetails.name.contains(text) ||
          customerDetails.name.toLowerCase().contains(text.toLowerCase()) ||
          customerDetails.phone.contains(text) ||
          customerDetails.phone.toLowerCase().contains(text.toLowerCase())) {
        searchResult.add(customerDetails);
      }
    }
    setState(() {});
  }

  Widget customerItemCard(CustomerModel customerModel) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      // margin: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: const Color(0xffE1EBFA),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerModel.name,
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: 16.5.sp,
                  ),
                ),
                SizedBox(height: 10.sp),
                Text(
                  customerModel.village,
                  style: getRegularStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.medium,
                  ),
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Text(
                      customerModel.phone,
                      style: getRegularStyle(
                        color: ColorManager.textColorGrey,
                        fontSize: FontSize.big,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    Icon(
                      Icons.phone,
                      color: ColorManager.textColorGrey,
                      size: 18.sp,
                    )
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹450',
            style: getMediumStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.big,
            ),
          ),
        ],
      ),
    );
  }
}
