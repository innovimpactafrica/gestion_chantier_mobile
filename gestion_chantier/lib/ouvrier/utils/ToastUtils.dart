import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/utils/constant.dart';

class ToastUtils {
  // Méthode statique pour pouvoir l'appeler partout
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
