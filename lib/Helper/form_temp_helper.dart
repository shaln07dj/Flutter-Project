import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future formTemp(String token, String? identifier, int? version) async {
  Uri.parse('https://$baseUrl$subUrl/$formTemplatebyVersion');
  var body = {
    "identifier": identifier,
    "version": version
  };
  var encodedBody = jsonEncode(body);

  Response response = await makeNetworkRequest("POST", token, baseUrl,
      subUrl: subUrl, tableName: formTemplatebyVersion, body: encodedBody);
  if (response.statusCode == 200) {
    return response.data;
  } else {}
}
