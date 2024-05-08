import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/send_email_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future sendAppId(
    String applicationId, String userId, String email, String applicantName,
    {required Function(bool status) handleUpdating}) async {
  Uri.parse(
      'https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$applicationRecordsTable');

  String? firebaseToken = await getFirebaseIdToken();

  var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  var createdAt = timeStampResponse.data["created_at"];
  var updatedAt = timeStampResponse.data["updated_at"];
  debugPrint(
      "timeStampResponse inside post_application_id_helper created_at updated_at: $createdAt $updatedAt");

  var body = {
    "records": [
      {
        "fields": {
          "application_id": applicationId,
          "application_status": 'Registration',
          "user_id": userId,
          "email": email,
          "is_deleted": false,
          "created_at": createdAt,
          "updated_at": updatedAt
        }
      }
    ],
    "tokenization": false
  };
  var encodedBody = jsonEncode(body);
  final String token = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest("POST", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      body: encodedBody);

  if (response.statusCode == 200) {
    var skyflowId = response.data['records'][0]["skyflow_id"];
    // handleUpdating(false);
    sendEmail(
        firebaseToken!, "newApplicationCreated", applicationId, skyflowId);

    return true;
  } else {}
}
