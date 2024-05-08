import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/api/interceptor.dart';

Future<void> sendEmail(BuildContext context, String subject, String mailBody,
    {String? userName,
    String? applicationId,
    String? email,
    String? phoneNumber,
    required Function(bool status) handleSendingMessage}) async {
  String? email;

  final String token = await getFirebaseIdToken() ?? '';
  String mailContent = '''
Hi Pauzible Support team,
 
User with following details has sent a message.
 
User Name: $userName
Application ID: $applicationId
Email ID:$email 
Subject: $subject
Message: $mailBody
 
Thanks,
Pauzible Team
          ''';
  var body = {
    "subjectEmail": subject,
    "bodyEmail": mailContent,
  };

  var encodedBody = jsonEncode(body);
  Response response = await makeNetworkRequest("POST", token, baseUrl,
      subUrl: subUrl, tableName: mailEndPoint, body: encodedBody);
  if (response.statusCode == 200) {
    debugPrint("Sending email successfully");
    Navigator.of(context).pop();
    handleSendingMessage(true);
  } else {
    debugPrint("Sending email unsuccessful");
    handleSendingMessage(false);
  }
}
