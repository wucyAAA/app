import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void show(String msg, {
    ToastGravity gravity = ToastGravity.CENTER,
    Color backgroundColor = const Color(0xE62C2C2E), // 深色背景
    Color textColor = Colors.white,
    double fontSize = 16.0,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      webPosition: "center", // web 端居中
      webBgColor: "#333333", // web 端深色背景
    );
  }

  static void showError(String msg) {
    show(msg, backgroundColor: const Color(0xFFFF453A));
  }

  static void showSuccess(String msg) {
    show(msg, backgroundColor: const Color(0xFF34C759));
  }

  static void showWarning(String msg) {
    show(msg, backgroundColor: const Color(0xFFFF9F0A));
  }
}
