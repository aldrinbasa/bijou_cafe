import 'package:flutter/material.dart';
import 'package:bijou_cafe/constants/texts.dart';

class Toast {
  static void show(BuildContext context, String? message) {
    final snackBar = SnackBar(
      content: Text(message ?? vagueError),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
