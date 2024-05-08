// Obtain shared preferences.
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;
Future<void> initSharedPreferences() async {
  prefs = await SharedPreferences.getInstance();
}

Future<void> clearSharedPreferences() async {
  await prefs!.clear();
}

void saveSkyFowToken(token) async {
  debugPrint("saving skyflow token");
  prefs?.setString('skyFlowToken', token);
}

saveFireBaseToken(token) async {
  prefs?.setString('fireBaseToken', token);
}

saveAppId(String appId) async {
  prefs?.setString('appId', appId);
}

saveUserId(String userId) async {
  prefs?.setString('userId', userId);
}

saveUserCurrentStatus(String status) async {
  prefs?.setString('userCurrentStatus', status);
}

saveSkyflowId(String skyflowId) async {
  prefs?.setString('skyFlowId', skyflowId);
}

setUserEmail(String skyflowId) async {
  prefs?.setString('userEmail', skyflowId);
}

setUserPhoneNo(String skyflowId) async {
  prefs?.setString('userPhoneNo', skyflowId);
}

setsubmittedFormId(String skyflowId) async {
  prefs?.setString('submittedFormId', skyflowId);
}

setFormSubmission(bool isFormSubmitted) async {
  prefs?.setBool('isFormSubmitted', isFormSubmitted);
  debugPrint('setFormSubmission $isFormSubmitted');
}

setStatusForm(String? formStatus) async {
  prefs?.setString('formStatus', formStatus!);
  debugPrint('setFormStatus $formStatus');
}

setUrlAppIdFlow(bool isurlAppIdFlow) async {
  prefs?.setBool('urlAppIdFlow', isurlAppIdFlow);
}

setApplicationRecordSkyflowId(String skyflowId) async {
  prefs?.setString('applicationRecordSkyflowId', skyflowId);
}

Future<void> saveApplicationFromData(user) async {
  String userJson = jsonEncode(user);
  prefs?.setString('userApplicationFromData', userJson);
}

getSkyFlowToken() async {
  String token = prefs?.getString('skyFlowToken') ?? 'defaultString';
  return token;
}

getFireBaseToken() async {
  String token = prefs?.getString('fireBaseToken') ?? 'defaultString';
  return token;
}

getAppId() async {
  debugPrint("getting appId");
  String appId = prefs?.getString('appId') ?? '';
  debugPrint("getting appId returned $appId");

  return appId;
}

getUserId() async {
  String appId = prefs?.getString('userId') ?? '';
  return appId;
}

getUserCurrentStatus() async {
  String userCurrentStatus =
      prefs?.getString('userCurrentStatus') ?? 'Registration';
  return userCurrentStatus;
}

getSkyflowId() async {
  String skyflowId = prefs?.getString('skyFlowId') ?? '';
  return skyflowId;
}

getUserEmail() async {
  String userEmail = prefs?.getString('userEmail') ?? '';
  return userEmail;
}

getUserPhoneNo() async {
  String userPhoneNo = prefs?.getString('userPhoneNo') ?? '';
  return userPhoneNo;
}

getsubmittedFormId() async {
  String skyflowId = prefs?.getString('submittedFormId') ?? '';
  return skyflowId;
}

getFormSubmissionStatus() async {
  bool staus = prefs?.getBool('isFormSubmitted') ?? false;
  return staus;
}

getStatusForm() async {
  String? formStatus = prefs?.getString('formStatus') ?? '';
  return formStatus;
}

getUrlAppIdFlow() async {
  bool status = prefs?.getBool('urlAppIdFlow') ?? false;
  return status;
}

getApplicationRecordSkyflowId() async {
  String status = prefs?.getString('applicationRecordSkyflowId') ?? '';
  return status;
}

Future getApplicationFromData() async {
  String? userJson = prefs?.getString('userApplicationFromData');

  if (userJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userJson);

    return userMap;
  }

  return null;
}
