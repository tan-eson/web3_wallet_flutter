import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web3_wallet_flutter/constants/secure_storage_keys.dart';
import 'package:provider/provider.dart';
import 'package:web3_wallet_flutter/model/wallet_private_key.dart';
import 'package:web3dart/web3dart.dart';

class WalletDashboard extends StatefulWidget {
  final String privateKey;
  const WalletDashboard({Key? key, required this.privateKey}) : super(key: key);

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  late EthPrivateKey privateKeyObj;

  void constructWallet() {
    privateKeyObj = EthPrivateKey.fromHex(widget.privateKey);
  }

  @override
  void initState() {
    super.initState();
    constructWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => Clipboard.setData(
                  ClipboardData(text: privateKeyObj.address.hex)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  privateKeyObj.address.hex,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                const storage = FlutterSecureStorage();
                storage.delete(key: SecureStorage.privateKey);
                context.read<PrivateKey>().setPrivateKey(null);
              },
              child: const Text("Log out"),
            )
          ],
        ),
      ),
    );
  }
}
