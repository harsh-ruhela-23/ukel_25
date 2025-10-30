// import 'package:flutter/material.dart';
//
// class DateTimeModel {
//   late String day;
//   late String month;
//   late String time;
//   late String year;
//
//   DateTimeModel({
//     required this.day,
//     required this.month,
//     required this.time,
//     required this.year,
//   });
//
//   DateTimeModel.fromJson(Map<String, dynamic> json) {
//     day = json['day'];
//     month = json['month'];
//     time = json['time'];
//     year = json['year'];
//   }
//
//   static Map<String, dynamic> toJson() {
//     final date = DateTime.now();
//     final time = TimeOfDay.now();
//
//     return {
//       AppKeys.day: date.day.toString(),
//       AppKeys.month: AppStrings.months[date.month - 1],
//       AppKeys.time: time.format(globalContext),
//       AppKeys.year: date.year.toString(),
//     };
//   }
// }
