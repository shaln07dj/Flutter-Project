import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';

Future getSignUrl(String? recordId,
    {int retryCount = 3, String? fireBaseToken}) async {
  var url = Uri.https(
    baseUrl,
    '$subUrl/$signUrl',
    {'record_id': recordId},
  );

  var skyFlowToken = await getSkyFlowToken();
  var response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $skyFlowToken'},
  );
  if (response.statusCode == 200) {
    var url = json.decode(response.body)['data']['sign_url'];
    return url;
  } else if ((response.statusCode == 403 || response.statusCode == 401) &&
      retryCount > 0) {
    String? resp;
    try {
      resp = await getSkyFlowToken() ?? '';
      return await getSignUrl(recordId, retryCount: retryCount - 1);
    } catch (error) {
      if (kDebugMode) {
        print('');
      }
    }
    if (resp != Null) {}
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    return res;
  }
}
