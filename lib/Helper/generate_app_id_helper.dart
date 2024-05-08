// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

generateAppId() async {
  String? token = await getFirebaseIdToken();
  String appIdUrl = 'https://$baseUrl$subUrl/$applicationIdEndPoint';
  Response response = await makeNetworkRequest("GET", token!, appIdUrl);

  if (response.statusCode == 200) {
    String applicationId = response.data['app_Id'];
    saveAppId(applicationId);

    return applicationId;
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    debugPrint('Request failed with status: ${response.statusCode}.');
    return res;
  }
}
