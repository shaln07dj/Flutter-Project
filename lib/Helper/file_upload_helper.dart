import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> sendFileToBackend({
  required String filename,
  required String byteSize,
  required String skyFlowId,
  required Function callback,
  required Function isSuccessfull,
  required Function resetFileInfo,
  required Function(String message) showToast,
  required Function(bool status) resetCategory,
  required Function(bool status) resetSubCategory,
  required Function resetTextField,
  required Function(bool status) fileReset,
  required Function resetDropZone,
  required Function resetSubCategoryDefault,
  String? blobUrl,
  final Uint8List? bytes,
  final String? filePath,
}) async {
  dynamic streamedResponse;
  final String token = await getSkyFlowToken() ?? '';

  if (kIsWeb) {
    final response = await http.get(Uri.parse(blobUrl!));
    debugPrint("Bloburl of file: $blobUrl");

    if (response.statusCode == 200) {
      streamedResponse = await makeNetworkRequest(
        "MULTIPART_POST",
        token,
        skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: fileRecordsTable,
        skyflowId: skyFlowId,
        blobUrl: blobUrl,
        fileName: filename,
      );
    }
  } else {
    if (Platform.isAndroid || Platform.isIOS) {
      streamedResponse = await makeNetworkRequest(
        "MULTIPART_POST",
        token,
        skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: fileRecordsTable,
        skyflowId: skyFlowId,
        bytes: bytes!,
        filePath: filePath,
        fileName: filename,
      );
    }
  }

  if (streamedResponse.statusCode == 200) {
    callback();
    isSuccessfull();
    showToast(fileUploadMsg);
    resetSubCategory(true);
    resetSubCategoryDefault();
    resetCategory(true);
    resetTextField();
    resetDropZone();
    resetFileInfo();

    var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";

    dynamic timeStampResponse =
        await makeNetworkRequest("GET", "", timeStampUrl);
    var createdAt = timeStampResponse.data["created_at"];
    var updatedAt = timeStampResponse.data["updated_at"];

    debugPrint(
        "timeStampResponse inside file_upload_helper created_at updated_at: $createdAt $updatedAt");

    var body = {
      "record": {
        "fields": {"updated_at": updatedAt}
      },
      "tokenization": false
    };

    var encodedBody = jsonEncode(body);
    //getting error here
    Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: fileRecordsTable,
        queryString: skyFlowId,
        body: encodedBody);

    if (response.statusCode == 200) {
      debugPrint("Timestamp updated successfully");
    } else {
      debugPrint("Timestamp updation unsuccessful");
    }
  } else {}
}
