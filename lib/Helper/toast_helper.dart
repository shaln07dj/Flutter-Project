import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastHelper(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    webPosition: 'center',
    webBgColor: '0xFF1E88E5',
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
