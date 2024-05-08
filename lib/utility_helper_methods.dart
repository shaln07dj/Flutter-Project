import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/colors.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return Colors.green;
    case 'not approved':
      return Colors.blue;
    case 'disabled':
      return Colors.red;
    default:
      return Colors.transparent;
  }
}

lastLoginInDays(String dateTimeString) {
  // Split the string by whitespace to get date and time parts
  List<String> parts = dateTimeString.split(' ');

  // Get the date part and split it by '-'
  List<String> dateParts = parts[0].split('-');

  // Convert all parts to integers
  int year = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int day = int.parse(dateParts[2]);

  DateTime lastLoginDate = DateTime.utc(year, month, day);

  // Get the current date
  DateTime currentDate = DateTime.now();

  // Calculate the difference in days
  int differenceInDays = currentDate.difference(lastLoginDate).inDays;
  // Return a DateTime object
  String differenceInDaysString = differenceInDays.toString();
  return differenceInDaysString;
}

OutlineInputBorder borderStyle({bool isError = false}) {
  return OutlineInputBorder(
      borderSide: BorderSide(
          color: isError ? Colors.red : Color(borderColor),
          width: isError ? 1 : 0.5));
}
