import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_wallet_flutter/model/wallet_private_key.dart';
import 'package:web3_wallet_flutter/screens/wallet_dashboard_screen.dart';
import 'package:web3_wallet_flutter/screens/wallet_import_screen.dart';

class ScreenWrapper extends StatefulWidget {
  const ScreenWrapper({Key? key}) : super(key: key);

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    String? privateKey = context.watch<PrivateKey>().walletPrivateKey;

    if (privateKey != null) {
      return WalletDashboard(
        privateKey: privateKey,
      );
    } else {
      return const WalletImport();
    }
  }
}
