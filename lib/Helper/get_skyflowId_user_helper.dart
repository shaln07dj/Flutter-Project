import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

fetchSkyflowIdUser() async {
  var skyFlowToken = await getSkyFlowToken() ?? '';
  final Map<String, dynamic> params = {
    'fields': ['skyflow_id', "email", "phone_number"]
  };

  Response response = await makeNetworkRequest(
      "GET", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: userRecordTable,
      queryparams: params);

  if (response.statusCode == 200) {
    var records = response.data['records'];

    if (records is List) {
      var skyflowId = records[0]['fields'];
      return skyflowId;
    }
  } else if (response.statusCode == 404) {
    // handleLoading('failed');
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    // handleLoading('failed');
    return res;
  }
  // }
}
