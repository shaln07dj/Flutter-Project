import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future<void> send_application_record_form_data(String formRecordSkyFlowId,
    String applicationRecordSkyFlowId, String tableName) async {
  final String token = await getSkyFlowToken() ?? '';
  var body = {
    "record": {
      "fields": {"last_form_id": formRecordSkyFlowId}
    },
    "tokenization": false
  };

  var encodedBody = jsonEncode(body);
  Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: tableName,
      queryString: applicationRecordSkyFlowId,
      body: encodedBody);
  if (response.statusCode == 200) {
    debugPrint("Timestamp updated successfully");
  } else {
    debugPrint("Timestamp updation unsuccessful");
  }
}
