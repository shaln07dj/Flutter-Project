import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/send_form_data_application_record.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future<bool> uploadJSONFile(
  String jsonFile,
  String skyFlowId,
) async {
  final String token = await getSkyFlowToken() ?? '';
  final String applicationRecordSkyflowId =
      await getApplicationRecordSkyflowId() ?? '';
  String skyflowId = skyFlowId;
  String filename = 'temp_file.json';
  bool fileUploaded = false;

  Response streamedResponse = await makeNetworkRequest(
      "MULTIPART_JSONPOST", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: formRecordsTable,
      skyflowId: skyflowId,
      jsonFile: jsonFile,
      fileName: filename);

  if (streamedResponse.statusCode == 200) {
    print("Form Data JSON File uploaded successfully");
    print(streamedResponse.data.runtimeType);
    var resp = jsonDecode(streamedResponse.data);
    var formRecordsTableSkyflowId = resp["skyflow_id"];
    setsubmittedFormId(resp["skyflow_id"]);
    print(formRecordsTableSkyflowId);
    send_application_record_form_data(formRecordsTableSkyflowId,
        applicationRecordSkyflowId, applicationRecordsTable);
    var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";

    dynamic timeStampResponse =
        await makeNetworkRequest("GET", "", timeStampUrl);
    var createdAt = timeStampResponse.data["created_at"];
    var updatedAt = timeStampResponse.data["updated_at"];

    debugPrint(
        "timeStampResponse inside upload_JSONFile_helper created_at updated_at: $createdAt $updatedAt");

    var body = {
      "record": {
        "fields": {"updated_at": updatedAt}
      },
      "tokenization": false
    };

    var encodedBody = jsonEncode(body);
    Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: formRecordsTable,
        queryString: skyflowId,
        body: encodedBody);
    if (response.statusCode == 200) {
      debugPrint("Timestamp updated successfully");
    } else {
      debugPrint("Timestamp updation unsuccessful");
    }
    fileUploaded = true;
    return fileUploaded;
  } else {
    print(
        "Failed to upload Form Data JSON File. Status code: ${streamedResponse.statusCode}");
    return fileUploaded;
  }
}
