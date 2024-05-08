import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/file_upload_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/send_email_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future sendFileInfo({
  category,
  subCategory,
  description,
  required bool isDeleted,
  applicationId,
  userId,
  required String filename,
  required String byteSize,
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
  Map? map,
  String? blobUrl,
  Uint8List? bytes,
  String? filePath,
}) async {
  Uri.parse('https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$fileRecordsTable');

  String? firebaseToken = await getFirebaseIdToken();

  var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  var created_at = timeStampResponse.data["created_at"];
  var updated_at = timeStampResponse.data["updated_at"];
  debugPrint(
      "timeStampResponse inside send_file_info_helper created_at updated_at: $created_at $updated_at");

  var body = {
    "records": [
      {
        "fields": {
          'category': category,
          'sub_category': subCategory,
          'description': description,
          "user_id": userId,
          "is_deleted": isDeleted,
          'application_id': applicationId,
          'created_at': created_at,
          'updated_at': updated_at
        }
      }
    ],
    "tokenization": false
  };
  var encodedBody = jsonEncode(body);
  final String token = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest(
    "POST",
    token,
    skyFlowBaseUrl,
    subUrl: sfSubUrl,
    vaultId: vaultId,
    tableName: fileRecordsTable,
    body: encodedBody,
  );
  if (response.statusCode == 200) {
    var skyFlowId = response.data['records'][0]["skyflow_id"];
    if (kIsWeb) {
      // Web platform
      sendFileToBackend(
        filename: filename,
        byteSize: byteSize,
        skyFlowId: skyFlowId,
        callback: callback,
        isSuccessfull: isSuccessfull,
        resetFileInfo: resetFileInfo,
        showToast: showToast,
        resetCategory: resetCategory,
        resetSubCategory: resetSubCategory,
        resetTextField: resetTextField,
        fileReset: fileReset,
        resetDropZone: resetDropZone,
        resetSubCategoryDefault: resetSubCategoryDefault,
        blobUrl: blobUrl!,
      );
    } else {
      // Mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        sendFileToBackend(
          filename: filename,
          byteSize: byteSize,
          skyFlowId: skyFlowId,
          callback: callback,
          isSuccessfull: isSuccessfull,
          resetFileInfo: resetFileInfo,
          showToast: showToast,
          resetCategory: resetCategory,
          resetSubCategory: resetSubCategory,
          resetTextField: resetTextField,
          fileReset: fileReset,
          resetDropZone: resetDropZone,
          resetSubCategoryDefault: resetSubCategoryDefault,
          bytes: bytes!,
          filePath: filePath,
        );
      }
    }

    sendEmail(firebaseToken!, "userDocumentUpload", applicationId, skyFlowId);
    return true;
  } else {}
}
