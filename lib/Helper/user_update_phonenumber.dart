import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

updateUserNumber(String phoneNumber, String skyFlowId) async {

  var skyFlowToken = await getSkyFlowToken() ?? '';

  var body = {
        "record": {
          "fields": {"phone_number": phoneNumber}
        },
        "tokenization": false
      };

    var encodedBody = jsonEncode(body);

  Response response = await makeNetworkRequest(
      "PUT", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: userRecordTable,
      queryString: skyFlowId,
      body: encodedBody,
      );

  if (response.statusCode == 200) {
    var records = response.data['records'];

    if (records is List) {
      var skyflowId = records[0]['fields']['skyflow_id'];
      return skyflowId;
    }
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    return res;
  }
}