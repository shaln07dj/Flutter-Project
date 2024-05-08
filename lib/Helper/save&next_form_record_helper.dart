import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/send_email_helper.dart';
import 'package:pauzible_app/Helper/upload_json_file.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future saveNextFormRecord(
    String token,
    String applicationId,
    String userId,
    String jsonFile,
    String identifier,
    int version,
    String formStatus,
    String? lastFormId) async {
  try {
    Uri.parse('https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$formRecordsTable');
    String? firebaseToken = await getFirebaseIdToken();

    var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
    dynamic timeStampResponse =
        await makeNetworkRequest("GET", "", timeStampUrl);
    var createdAt = timeStampResponse.data["created_at"];
    var updatedAt = timeStampResponse.data["updated_at"];
    debugPrint(
      "timeStampResponse inside send_from_record_helper created_at updated_at: $createdAt $updatedAt",
    );

    if (lastFormId!.isNotEmpty && formStatus == 'partially_submitted') {
      var skyflowId = lastFormId;
      uploadJSONFile(jsonFile, skyflowId);
      return;
    } else {
      var body = {
        "records": [
          {
            "fields": {
              "application_id": applicationId,
              "form_identifier": identifier,
              "version": version,
              "is_deleted": false,
              "user_id": userId,
              'created_at': createdAt,
              'updated_at': updatedAt,
              'form_status': formStatus,
            },
          },
        ],
      };
      var encodedBody = jsonEncode(body);

      Response response = await makeNetworkRequest(
        "POST",
        token,
        skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: formRecordsTable,
        body: encodedBody,
      );

      if (response.statusCode == 200) {
        var skyflowId = response.data['records'][0]["skyflow_id"];
        uploadJSONFile(jsonFile, skyflowId);
        return response.data;
      }
    }
  } catch (e) {
    debugPrint('Error in save&next $e');
  }
}
