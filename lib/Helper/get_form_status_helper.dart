import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

 getFormstatus(String skyflowId) async {
  var skyFlowToken = await getSkyFlowToken();


  String url =
      'https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$formRecordsTable/$skyflowId?&fields=form_status';
  debugPrint('FORM STATUS GET SKY $skyflowId');
  Response response = await makeNetworkRequest(
      "GET", skyFlowToken!, url);

  if (response.statusCode == 200) {
    var records = response.data;
    debugPrint('FORM STATUS GET $records');
    return records;
  } 
  else if (response.statusCode == 404) {
    return [];
  } else {
    debugPrint('Request failed with status: ${response.statusCode}.');
  }
}
