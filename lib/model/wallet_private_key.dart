import 'package:flutter/material.dart';

class PrivateKey with ChangeNotifier {
  String? _walletPrivateKey;

  String? get walletPrivateKey => _walletPrivateKey;

  void setPrivateKey(String? newKey) {
    _walletPrivateKey = newKey;
    notifyListeners();
  }
}
