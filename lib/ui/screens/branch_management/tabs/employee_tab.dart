// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:ukel/resource/assets_manager.dart';
// import 'package:ukel/resource/color_manager.dart';
// import 'package:ukel/resource/fonts_manager.dart';
// import 'package:ukel/resource/styles_manager.dart';
// import 'package:ukel/ui/screens/branch_management/widgets/add_craftman_screen.dart';
// import 'package:ukel/ui/screens/branch_management/widgets/add_employee_screen.dart';
// import 'package:ukel/ui/screens/branch_management/widgets/emp_attendance_screen.dart';
//
// import '../../../../main.dart';
// import '../../../../utils/app_utils.dart';
// import '../../../../utils/custom_page_transition.dart';
// import '../../../../widgets/title_value_card_widget.dart';
//
// class EmployeeTab extends StatelessWidget {
//   const EmployeeTab({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Punching',
//                 style: getSemiBoldStyle(
//                   color: ColorManager.btnColorDarkBlue,
//                   fontSize: FontSize.large,
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   // Add Employee Screen
//                   AppUtils.navigateTo(
//                     context,
//                     CustomPageTransition(
//                       MyApp.myAppKey,
//                       AddEmployeeScreen.routeName,
//                     ),
//                   );
//                 },
//                 child: Text(
//                   '+ Employee',
//                   style: getSemiBoldStyle(
//                     color: ColorManager.colorBlue,
//                     fontSize: FontSize.mediumExtra,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.sp),
//
//           // CheckIn CheckOut Card
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(17.sp),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: ColorManager.colorLightGrey,
//                 style: BorderStyle.solid,
//                 width: 1.0,
//               ),
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10.sp),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   '14:25:30',
//                   style: getMediumStyle(
//                     color: ColorManager.btnColorDarkBlue,
//                     fontSize: FontSize.heading,
//                   ),
//                 ),
//                 SizedBox(height: 10.sp),
//                 Text(
//                   'Tuesday, 07/02/2023',
//                   style: getMediumStyle(
//                     color: ColorManager.textColorGrey,
//                     fontSize: FontSize.big,
//                   ),
//                 ),
//                 SizedBox(height: 15.sp),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: checkInCheckOutButton(
//                         bgColor: const Color(0xff79CB9D),
//                         onPress: () {},
//                         text: 'Check In',
//                         icon: IconAssets.iconCheckIn,
//                       ),
//                     ),
//                     SizedBox(width: 15.sp),
//                     Container(
//                       color: const Color(0xffE4E5E9),
//                       width: 5.sp,
//                       height: 25.sp,
//                     ),
//                     SizedBox(width: 15.sp),
//                     Expanded(
//                       child: checkInCheckOutButton(
//                         bgColor: const Color(0xffFE6776),
//                         onPress: () {},
//                         text: 'Check Out',
//                         icon: IconAssets.iconCheckOut,
//                       ),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//           SizedBox(height: 20.sp),
//
//           // Emp Status card
//           Row(
//             children: [
//               const Expanded(
//                 child: TitleValueCardWidget(
//                   value: 'Present employee',
//                   title: '05',
//                 ),
//               ),
//               SizedBox(width: 15.sp),
//               const Expanded(
//                 child: TitleValueCardWidget(
//                   value: 'On Leave',
//                   title: '01',
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.sp),
//
//           // checkInCheckOutEmployee List
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: 20,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: (BuildContext context, int index) {
//               return Padding(
//                 padding: EdgeInsets.only(bottom: 15.sp),
//                 child: checkInCheckOutEmployeeCard(
//                   onPress: () {
//                     // Emp Attendance Screen
//                     AppUtils.navigateTo(
//                       context,
//                       CustomPageTransition(
//                         MyApp.myAppKey,
//                         EmpAttendanceScreen.routeName,
//                       ),
//                     );
//                   },
//                   text: 'Kartik Patel',
//                   inTime: '08:00',
//                   outTime: '18:00',
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 30.sp),
//         ],
//       ),
//     );
//   }
//
//   Widget checkInCheckOutButton(
//       {required String text,
//       required String icon,
//       required Function onPress,
//       required Color bgColor}) {
//     return InkWell(
//       onTap: () => onPress(),
//       child: Container(
//         alignment: Alignment.center,
//         width: double.infinity,
//         padding: EdgeInsets.all(13.sp),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(10.sp),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               icon,
//               color: Colors.white,
//               height: 18.sp,
//             ),
//             SizedBox(width: 11.sp),
//             Text(
//               text,
//               style: getMediumStyle(
//                 color: Colors.white,
//                 fontSize: FontSize.big,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget employeeStatusCard({required String totalNo, required String title}) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 17.sp),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: ColorManager.colorLightGrey,
//           style: BorderStyle.solid,
//           width: 1.0,
//         ),
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.sp),
//       ),
//       child: Column(
//         children: [
//           Text(
//             totalNo,
//             style: getMediumStyle(
//               color: ColorManager.btnColorDarkBlue,
//               fontSize: 20.5.sp,
//             ),
//           ),
//           SizedBox(height: 10.sp),
//           Text(
//             title,
//             style: getMediumStyle(
//               color: ColorManager.textColorGrey,
//               fontSize: 15.sp,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget checkInCheckOutEmployeeCard(
//       {required String text,
//       required Function onPress,
//       required String inTime,
//       required String outTime}) {
//     return ListTile(
//       contentPadding: EdgeInsets.all(isTablet ? 10.sp : 11.sp),
//       onTap: () => onPress(),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: ColorManager.colorLightGrey, width: 1),
//         borderRadius: BorderRadius.circular(10.sp),
//       ),
//       leading: Padding(
//         padding: EdgeInsets.only(left: isTablet ? 0 : 10.0),
//         child: const CircleAvatar(
//           radius: 20, // Image radius
//           backgroundImage: NetworkImage(
//               'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTj9ySx6w03MteA7LmBWIqr5C7rhqOdC8xY2SLkoAN03bMZfXmTVpRmcH3ewSR_pFpxqJM&usqp=CAU'),
//         ),
//       ),
//       title: Text(
//         text,
//         style: getBoldStyle(
//           color: ColorManager.textColorBlack,
//           fontSize: FontSize.big,
//         ),
//       ),
//       subtitle: Padding(
//         padding: EdgeInsets.only(top: 10.sp),
//         child: Row(
//           children: [
//             Text(
//               'In',
//               style: getBoldStyle(
//                 color: ColorManager.textColorGrey,
//                 fontSize: FontSize.medium,
//               ),
//             ),
//             SizedBox(width: 13.sp),
//             Text(
//               inTime,
//               style: getRegularStyle(
//                 color: ColorManager.textColorGrey,
//                 fontSize: FontSize.mediumExtra,
//               ),
//             ),
//             SizedBox(width: 15.sp),
//             Container(
//               color: const Color(0xffE4E5E9),
//               width: 5.sp,
//               height: 18.sp,
//             ),
//             SizedBox(width: 15.sp),
//             Text(
//               'Out',
//               style: getBoldStyle(
//                 color: ColorManager.textColorGrey,
//                 fontSize: FontSize.medium,
//               ),
//             ),
//             SizedBox(width: 13.sp),
//             Text(
//               outTime,
//               style: getRegularStyle(
//                 color: ColorManager.textColorGrey,
//                 fontSize: FontSize.mediumExtra,
//               ),
//             ),
//           ],
//         ),
//       ),
//       trailing: Icon(Icons.navigate_next,
//           size: 23.sp, color: ColorManager.colorDarkBlue),
//     );
//   }
// }
