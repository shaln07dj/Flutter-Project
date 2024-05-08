import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future sendEmail(String firebaseToken, String userAction, String applicationId,
    String skyflowId) async {
  Uri.parse('https://$baseUrl$subUrl/$emailSmsEndpoint');

  var requestBody = {
    "userAction": userAction,
    "application_id": applicationId,
    "skyflow_id": skyflowId
  };

  var encodedBody = jsonEncode(requestBody);
  Response response = await makeNetworkRequest("POST", firebaseToken, baseUrl,
      subUrl: subUrl, tableName: emailSmsEndpoint, body: encodedBody);

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
