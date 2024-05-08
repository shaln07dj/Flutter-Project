import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

getUserFileURL(String skyflowId,
    {Function(String status)? handleLoading}) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';

  String url =
      'https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$formRecordsTable/$skyflowId?downloadURL=true&fields=file';

  Response resp = await makeNetworkRequest("GET", skyFlowToken, url);

  if (resp.statusCode == 200) {
    return resp.data['fields']['file'];
  } else if (resp.statusCode == 404) {
    handleLoading!('failed');
  }
  else {
    var res = 'Request failed with status: ${resp.statusCode}.';
    return res;
  }
}
