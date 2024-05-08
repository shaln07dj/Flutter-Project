// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

getToken(String token) async {
  String tokenUrl = 'https://$baseUrl$subUrl/$tokenEndPoint';
  Response response = await makeNetworkRequest("GETTOKEN", token, tokenUrl);

  if (response.statusCode == 200) {
    String skyFlowToken = response.data['token'];
    saveSkyFowToken(skyFlowToken);
    return response;
  } else {
    debugPrint('Request failed with status: ${response.statusCode}.');
    return response;
  }
}
