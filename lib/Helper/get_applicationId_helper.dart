import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future getApplicationId(String? token,
    {int retryCount = 3, String? fireBaseToken}) async {
  dynamic queryParameters = {
    'redaction': 'PLAIN_TEXT',
    'fields': [
      'application_id',
      'application_status',
      'last_form_id',
      'skyflow_id'
    ],
    'tokenization': 'false',
    'limit': '25',
    'downloadURL': 'false',
    'order_by': 'NONE'
  };

  Response response = await makeNetworkRequest('GET', token!, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      queryparams: queryParameters);

  if (response.statusCode == 200) {
    var records = response.data['records'];
    if (records is List) {
      String? appId = records[0]["fields"]["application_id"];
      String? userCurrentStatus = records[0]["fields"]["application_status"];
      String? skyflowId = records[0]["fields"]["skyflow_id"];
      setApplicationRecordSkyflowId(skyflowId!);

      saveUserCurrentStatus(userCurrentStatus!);
      getAppId().then((aaplicationId) {
        if (aaplicationId == '') {
          saveAppId(appId!);
        }
      });
      if (records.isNotEmpty &&
          records[0]["fields"] != null &&
          records[0]["fields"].containsKey("last_form_id")) {
        String id = records[0]["fields"]["last_form_id"];
        setsubmittedFormId(id);
        setFormSubmission(true);
      } else if (records.isNotEmpty &&
          records[0]["fields"] != null &&
          (records[0]["fields"].containsKey("last_form_id")) == false) {
        setsubmittedFormId('');
        setFormSubmission(false);
      }
    }
    return records;
  } else {
    print("Error getting Application ID");
    var res = 'Request failed with status: ${response.statusCode}.';
    return res;
  }
}
