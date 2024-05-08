import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/auth_screen.dart';

Future updateSkyflowDisplayName(
    String firstName, String lastName, String skyflowId,
    {Function(bool status)? handleUpdating}) async {
  var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  var createdAt = timeStampResponse.data["created_at"];
  var updatedAt = timeStampResponse.data["updated_at"];
  User? user = FirebaseAuth.instance.currentUser;
  debugPrint(
      "timeStampResponse inside update_displayname_helper created_at updated_at: $createdAt $updatedAt");

  var body = {
    "record": {
      "fields": {
        "first_name": firstName,
        "last_name": lastName,
        "updated_at": updatedAt
      }
    },
    "tokenization": false
  };
  var encodedBody = jsonEncode(body);
  final String token = await getSkyFlowToken() ?? '';
  debugPrint("TOKEN $token");
  Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      queryString: skyflowId,
      body: encodedBody);
  if (response.statusCode == 200) {
    await user?.updateDisplayName('$firstName $lastName');
    handleUpdating!(true);
    await navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AuthHomeScreen(
          route: true,
        ),
      ),
      (route) => false,
    );

    return true;
  } else {
    handleUpdating!(false);
  }
}
