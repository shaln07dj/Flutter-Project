import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/Helper/session/sign_out.dart';
import 'package:pauzible_app/app.dart';
import 'package:pauzible_app/main.dart';

Dio dio = Dio();
bool isRefreshing = false;
Dio tokenDio = Dio();
bool isInterceptorAdded = false;
CancelToken cancelToken = CancelToken();
// void _signOut() async {
//   try {
//     await FirebaseAuth.instance.signOut();
//   } catch (e) {
//     print('Error signing out: $e');
//   }
// }

class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token is expired or invalid
      try {
        // Refresh the token
        String? firebaseToken = await getFirebaseIdToken();
        Response skyflowResponse = await getToken(firebaseToken!);
        String? skyflowToken = skyflowResponse.data['token'];

        if (skyflowResponse.statusCode == 401) {
          // _signOut();
          SignOut();
          // saveSkyFowToken('');
          // saveFireBaseToken('');
          // saveAppId('');
          // saveUserId('');
          handler.next(err);
          return;
        }

        // Update the Authorization header with the new token
        err.requestOptions.headers["Authorization"] = "Bearer $skyflowToken";

        // Retry the request with the new token
        final response = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          cancelToken: cancelToken,
        );

        // If the request is successful, resolve the original request
        handler.resolve(response);
      } catch (e) {
        // If the token refresh fails, propagate the original error
        // _signOut();
        SignOut();
        // saveSkyFowToken('');
        // saveFireBaseToken('');
        // saveAppId('');
        // saveUserId('');
        // setFormSubmission(false);
        handler.next(err);
      }
    } else {
      // If the error is not related to token expiration, propagate the error
      handler.next(err);
    }
  }
}

void addInterceptor() {
  if (!isInterceptorAdded) {
    dio.interceptors.add(TokenRefreshInterceptor());
    isInterceptorAdded = true;
  }
}

makeNetworkRequest(
  String method,
  String token,
  String baseUrl, {
  String? subUrl,
  String? vaultId,
  String? tableName,
  dynamic queryparams,
  String? queryString,
  String? skyflowId,
  dynamic body,
  String? jsonFile,
  String? fileName,
  int attempts = 0,
  String? blobUrl,
  final Uint8List? bytes,
  String? filePath,
}) async {
  addInterceptor();
  var options = Options(
    // Pass the custom headers, including the token
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
  );
  var multipartHeaders = Options(
    headers: {
      HttpHeaders.contentTypeHeader: 'multipart/form-data',
      'Authorization': 'Bearer $token'
    },
  );
  if (method == 'GET') {
    dynamic response = subUrl != null
        ? await fetchData(dio, method, baseUrl,
            subUrl: subUrl,
            vaultId: vaultId!,
            tableName: tableName!,
            queryparams: queryparams,
            options: options)
        : await fetchData(dio, method, baseUrl, options: options);
    return response;
  }
  if (method == 'GETTOKEN') {
    dynamic response =
        await fetchData(tokenDio, method, baseUrl, options: options);
    return response;
  }

  if (method == "POST") {
    dynamic response = postData(dio, baseUrl,
        subUrl: subUrl,
        vaultId: vaultId,
        tableName: tableName,
        body: body,
        options: options);
    return response;
  }

  if (method == "MULTIPART_POST") {
    dynamic response = postMultipartData(
      dio,
      baseUrl,
      subUrl: subUrl,
      vaultId: vaultId,
      tableName: tableName,
      fileName: fileName,
      skyflowId: skyflowId,
      options: multipartHeaders,
      blobUrl: blobUrl,
      bytes: bytes,
      filePath: filePath,
    );
    return response;
  }

  if (method == "MULTIPART_JSONPOST") {
    dynamic response = postJSONFileData(dio, baseUrl,
        subUrl: subUrl,
        vaultId: vaultId,
        tableName: tableName,
        jsonFile: jsonFile,
        fileName: fileName,
        skyflowId: skyflowId,
        options: multipartHeaders);
    return response;
  }

  if (method == "PUT") {
    dynamic response = putData(dio, baseUrl,
        subUrl: subUrl,
        vaultId: vaultId,
        queryString: queryString,
        tableName: tableName,
        body: body,
        options: options);
    return response;
  }
}

fetchData(Dio dio, String method, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? tableName,
    dynamic queryparams,
    required Options options}) async {
  try {
    var response = await dio.get(
      tableName != null
          ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName').toString()
          : baseUrl,
      queryParameters: queryparams != '' ? queryparams : {},
      options: options,
      cancelToken: cancelToken,
    );
    return (response);
    // ignore: empty_catches
  } catch (e) {
    if (e is DioError) {
      if (e.response != null && e.response?.statusCode == 404) {
        // Handle the 404 response here
        return e.response;
      } else {
        // Handle other DioErrors or exceptions here
        debugPrint('Error: $e');
      }
    }
  }
}

postData(Dio dio, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? queryString,
    String? tableName,
    dynamic body,
    bool? isMultipartRequest,
    required Options options}) async {
  try {
    var response = await dio.post(
      vaultId != null && queryString != null
          ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName/$queryString')
              .toString()
          : vaultId != null
              ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName').toString()
              : Uri.https(baseUrl, '$subUrl/$tableName').toString(),
      data: body,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
    // ignore: empty_catches
  } catch (e) {
    debugPrint("Error in POST $baseUrl$subUrl: $e");
  }
}

postMultipartData(
  Dio dio,
  String baseUrl, {
  String? subUrl,
  String? vaultId,
  String? queryString,
  String? tableName,
  String? skyflowId,
  String? fileName,
  required Options options,
  String? blobUrl,
  Uint8List? bytes,
  String? filePath,
}) async {
  debugPrint("blobUrl inside postMultipartData: $blobUrl");
  debugPrint("bytes inside postMultipartData: $bytes");
  debugPrint("filePath inside postMultipartData: $filePath");

  if (blobUrl != null && (bytes == null && filePath == null)) {
    final response = await http.get(Uri.parse(blobUrl));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      try {
        FormData formData = FormData.fromMap(
            {'file': MultipartFile.fromBytes(bytes, filename: fileName)});
        var response = await dio.post(
          'https://$baseUrl/v1/vaults/$vaultId/$tableName/$skyflowId/files',
          data: formData,
          options: options,
          cancelToken: cancelToken,
        );
        debugPrint('Dio Multipart POST Response: ${response.data}');
        return response;
      } catch (e) {
        debugPrint('Dio Multipart POST Error: $e');
      }
    }
  } else if (blobUrl == null && (bytes != null && filePath != null)) {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes!, filename: fileName),
      });
      var response = await dio.post(
        'https://$baseUrl/v1/vaults/$vaultId/$tableName/$skyflowId/files',
        data: formData,
        options: options,
      );
      debugPrint('Dio Multipart POST Response: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('Dio Multipart POST Error: $e');
    }
  }
}

postJSONFileData(Dio dio, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? tableName,
    String? skyflowId,
    String? jsonFile,
    String? fileName,
    required Options options}) async {
  try {
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromString(jsonFile!, filename: 'temp_file.json'),
    });
    var response = await dio.post(
      'https://$baseUrl/v1/vaults/$vaultId/$tableName/$skyflowId/files',
      data: formData,
      options: options,
      cancelToken: cancelToken,
    );
    debugPrint('Dio Multipart JSON_POST Response: ${response.data}');
    return response;
  } catch (e) {
    debugPrint('Dio Multipart JSON_POST Error: $e');
  }
}

putData(Dio dio, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? queryString,
    String? tableName,
    dynamic body,
    required Options options}) async {
  try {
    var response = await dio.put(
      vaultId != null && queryString != null
          ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName/$queryString')
              .toString()
          : vaultId != null
              ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName').toString()
              : Uri.https(baseUrl, '$tableName').toString(),
      data: body,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
    // ignore: empty_catches
  } catch (e) {}
}
