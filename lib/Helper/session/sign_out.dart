import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/app.dart';
import 'package:pauzible_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void SignOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    clearSharedPreferences();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    navigateToLoginPage();
  } catch (e) {
    debugPrint('Error signing out: $e');
  }
}

void navigateToLoginPage() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => App()),
    (route) => false,
  );
}
