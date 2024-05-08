import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future builderTable(String token, List<String> identifiers) async {
  Uri.parse('https://$baseUrl$subUrl/$formTemplateTable');
  var body = {"identifiers": identifiers};
  var encodedBody = jsonEncode(body);

  Response response = await makeNetworkRequest("POST", token, baseUrl,
      subUrl: subUrl, tableName: formTemplateTable, body: encodedBody);
  if (response.statusCode == 200) {
    return response.data;
  } else {}
}
