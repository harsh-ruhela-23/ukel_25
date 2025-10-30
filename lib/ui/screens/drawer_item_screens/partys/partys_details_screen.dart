import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/customer_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/service_invoice/service_view_model.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/service_dropdown_widget.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class PartyDetailsScreen extends StatefulWidget {
  const PartyDetailsScreen({Key? key, required this.customerData})
      : super(key: key);

  final CustomerModel customerData;

  @override
  State<PartyDetailsScreen> createState() => _PartyDetailsScreenState();
}

class _PartyDetailsScreenState extends State<PartyDetailsScreen> {
  MembersModel? selectedMember;

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // now the UI is ready, so update your ViewModel and call setState
    //   Provider.of<ServiceViewModel>(context, listen: false).selectedService = null;
    //   Provider.of<ServiceViewModel>(context, listen: false).selectedMember = widget.customerData.membersData![1];
    //   selectedMember = widget.customerData.membersData![1];
    //   Provider.of<ServiceViewModel>(context, listen: false).getServicesList();
    //   setState(() {});
    // });
    return SafeArea(
      child: Scaffold(
        appBar: OtherScreenAppBar(
          onBackClick: () => AppUtils.navigateUp(context),
          title: "Party Details",
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customerItemCard(widget.customerData),
              Padding(
                padding: EdgeInsets.only(top: 20.sp, bottom: 10.sp),
                child: Text(
                  "Nap",
                  style: getMediumStyle(
                    color: ColorManager.textColorBlack,
                    fontSize: FontSize.bigExtra,
                  ),
                ),
              ),
              widget.customerData.membersData != null
                  ? Padding(
                      padding: EdgeInsets.only(top: 10.sp),
                      child: SizedBox(
                        height: 22.sp,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.customerData.membersData!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.sp),
                              child: MembersListItemWidget(
                                memberData:
                                    widget.customerData.membersData![index],
                                onClick: (MembersModel data) {
                                  Provider.of<ServiceViewModel>(context,
                                          listen: false)
                                      .selectedService = null;
                                  Provider.of<ServiceViewModel>(context,
                                          listen: false)
                                      .selectedMember = data;
                                  selectedMember = data;
                                  Provider.of<ServiceViewModel>(context,
                                          listen: false)
                                      .getServicesList();
                                  setState(() {});
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    final provider = Provider.of<ServiceViewModel>(context, listen: false);
                                    provider.getServicesList();
                                    Future.delayed(const Duration(milliseconds: 1000), () {
                                      if (provider.servicesModelList.isNotEmpty) {
                                        provider.setSelectedService(provider.servicesModelList.first, false);
                                        setState(() {});
                                      }
                                    });
                                  });
                                },
                                isSelected:
                                    widget.customerData.membersData![index] ==
                                        selectedMember,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox(),
              selectedMember != null
                  ? Padding(
                      padding: EdgeInsets.only(top: 20.sp),
                      child: const ServiceDropDownWidget(
                        isFieldsEnable: false,
                        isForParty: true,
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          "Please Select Customer",
                          style: getMediumStyle(
                            color: ColorManager.textColorBlack,
                            fontSize: FontSize.bigExtra,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
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
            Column(
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

                    // <-- Make the icon tappable:
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: customerModel.phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch dialer')),
                          );
                        }
                      },
                      child: Icon(
                        Icons.phone,
                        color: ColorManager.textColorGrey,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),

              ],
            ),
            // Text(
            //   '₹450',
            //   style: getMediumStyle(
            //     color: ColorManager.textColorBlack,
            //     fontSize: FontSize.big,
            //   ),
            // ),
          ],
        ),
      );
    }
  }

class MembersListItemWidget extends StatelessWidget {
  const MembersListItemWidget(
      {Key? key,
      required this.memberData,
      required this.onClick,
      required this.isSelected})
      : super(key: key);

  final MembersModel memberData;
  final Function(MembersModel) onClick;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick(memberData);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffE1EBFA) : const Color(0xffF8F6F7),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Center(
          child: Text(
            memberData.name ?? "",
            style: getMediumStyle(
              color: ColorManager.textColorBlack,
              fontSize: FontSize.mediumExtra,
            ),
          ),
        ),
      ),
    );
  }
}
