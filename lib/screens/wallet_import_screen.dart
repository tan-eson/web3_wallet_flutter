import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3_wallet_flutter/constants/secure_storage_keys.dart';
import 'package:web3_wallet_flutter/model/wallet_private_key.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class WalletImport extends StatefulWidget {
  const WalletImport({Key? key}) : super(key: key);

  @override
  State<WalletImport> createState() => _WalletImportState();
}

class _WalletImportState extends State<WalletImport> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController privateKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Import")),
        body: SingleChildScrollView(
          child: Column(children: [
            const Text("Hello, import your wallet to begin"),
            Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: privateKeyController,
                      decoration:
                          const InputDecoration(hintText: 'Private Key'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide your private key';
                        } else {
                          return null;
                        }
                      },
                    ),
                    ElevatedButton(
                        onPressed: () => handleFormSubmit(context),
                        child: const Text("Import"))
                  ],
                ))
          ]),
        ));
  }

  void handleFormSubmit(BuildContext context) {
    final bool? isFormValid = _formKey.currentState?.validate();
    if (isFormValid == true) {
      importWallet(context);
    }
  }

  void importWallet(BuildContext context) {
    try {
      // constructing an EthPrivateKey object to make sure private key provided is valid.
      EthPrivateKey.fromHex(privateKeyController.text);
      const storage = FlutterSecureStorage();
      // store into persistent storage, so that private key persist even after app close.
      storage.write(
          key: SecureStorage.privateKey, value: privateKeyController.text);
      // update state of private key, and show dashboard page
      context.read<PrivateKey>().setPrivateKey(privateKeyController.text);
    } catch (e) {
      SnackBar snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
