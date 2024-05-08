import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

const double maxFileSize = 5;
const int skyFlowTokenErrorStatusCode = 401;
const String skyFlowToKenErrorMessage = "";
const String fileUploadMsg = "Uploaded Success";
const String invalidFileMsg = "File Type Unsupported";
const int descrptionMaxWords = 50;
const int descrptionWordAvgLen = 15;
int inActivitySessionTimeoutDuration = 600;

String siteBaseUrl = "${dotenv.env['Site_Base-URL']}"; //www.pauzible.com
String endpointPrivacy = "privacy";
String endpointTermsOfUse = "terms-of-use";

String baseUrl = "${dotenv.env['Base_URL']}"; //  devapi.pauzible.com
String subUrl = "${dotenv.env['Sub_URL']}"; //  /v1/api
String domainUrl = "${dotenv.env['Domain_URL']}";

String skyFlowBaseUrl =
    "${dotenv.env['Skyflow_Base_URL']}"; // a370a9658141.vault.skyflowapis-preview.com
String sfSubUrl = "${dotenv.env['Sf_Sub_URL']}"; //   /v1/vaults
String vaultId = "${dotenv.env['Vault_ID']}";
String applicationRecordsTable = "${dotenv.env['App_Records_Table']}";
String fileRecordsTable = "${dotenv.env['File_Records_Table']}";
String signRecordsTable = "${dotenv.env['Sign_Records_Table']}";
String formRecordsTable = "${dotenv.env['Form_Records_Table']}";
String userRecordTable = "${dotenv.env['User_Records_Table']}";
String mailEndPoint = "${dotenv.env['EMAIL_END_POINT']}";

const String formTemplateTable = "formTemplates";
const String formTemplatebyVersion = "formTemplateByVersion";
const String signUrl = 'getSignUrl';
const String tokenEndPoint = 'getToken';
const String applicationIdEndPoint = 'getApplicationId';
const String filteredStringForSignedRecord = "RECALLED";
const String emailSmsEndpoint = "sendEmailSMS";
const String getTimeStamp = "timestamps";

const List<Map<String, dynamic>> userStatusList = [
  {"application_status": "Registration", "application_status_id": 1},
  {"application_status": "Pre-Qualification", "application_status_id": 2},
  {"application_status": "Personal Details", "application_status_id": 3},
  {"application_status": "Mortgage Details", "application_status_id": 4},
  {"application_status": "Documents Submission", "application_status_id": 5},
  {"application_status": "Contract Signed", "application_status_id": 6},
  {"application_status": "Disbursement", "application_status_id": 7},
  {"application_status": "Closure", "application_status_id": 8},
];
const footerCopywriteText =
    "Copyright 2024 © Pauzible UK Limited, All rights reserved.";
const footerTroubleText = "Having any troubles? ";
const footerContactText = "Contact Support";

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 992;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width < 992 &&
    MediaQuery.of(context).size.width > 600;

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width <= 600;

Future<String?> getVersionNumber() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  } catch (e) {
    print('Error fetching version number: $e');
    // return 'Unknown';
    return null;
  }
}
