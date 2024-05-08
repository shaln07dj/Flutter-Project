import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

getSignRecords(Function(String status) handleLoading, int offSetValue) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';

  final Map<String, dynamic> params = {
    'redaction': 'PLAIN_TEXT',
    'fields': [
      'category',
      'description',
      'sub_category',
      'skyflow_id',
      'status',
      'created_at',
      'updated_at'
    ],
    'tokenization': 'false',
    'offset': offSetValue.toString(),
    'limit': '25',
    'downloadURL': 'false',
    'order_by': 'NONE'
  };

  Response response = await makeNetworkRequest(
      "GET", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: signRecordsTable,
      queryparams: params);

  if (response.statusCode == 200) {
    var records = response.data['records'];
    handleLoading('success');
    return records;
  } else if (response.statusCode == 404) {
    handleLoading('failed');
    return [];
  } else {
    debugPrint('Request failed with status: ${response.statusCode}');
  }
}
