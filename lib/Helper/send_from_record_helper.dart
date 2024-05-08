import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/src/form_builder.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/send_email_helper.dart';
import 'package:pauzible_app/Helper/upload_json_file.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future sendFormRecord(
  String token,
  String applicationId,
  String jsonFile,
  Function resetData,
  String formStatus,
  Function(String message) showToast,
  String? lastFormId,
  GlobalKey<FormBuilderState> dialogKey,
) async {
  bool fileUploaded = await uploadJSONFile(jsonFile, lastFormId!);

  if (fileUploaded) {
    String? firebaseToken = await getFirebaseIdToken();

    var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
    dynamic timeStampResponse =
        await makeNetworkRequest("GET", "", timeStampUrl);
    var updatedAt = timeStampResponse.data["updated_at"];
    debugPrint(
      "timeStampResponse inside send_from_record_helper created_at updated_at: $updatedAt",
    );

    var body = {
      "record": {
        "fields": {
          'updated_at': updatedAt,
          'form_status': formStatus,
        },
      },
    };
    var encodedBody = jsonEncode(body);

    Response response = await makeNetworkRequest(
      "PUT",
      token,
      skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      queryString: lastFormId,
      tableName: formRecordsTable,
      body: encodedBody,
    );

    if (response.statusCode == 200) {
      // var skyflowId = response.data['records'][0]["skyflow_id"];
      sendEmail(
          firebaseToken!, "userFormSubmission", applicationId, lastFormId);
      resetData();
      showToast("Form Submitted");
      return response.data;
    }
  } else {
    debugPrint('Failed to upload jsonFile');
    showDialog(
      context: dialogKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Warning!"),
          content: const Text("Unable to save your changes, please try again."),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }
}
