import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:web3_wallet_flutter/constants/network_template.dart';
import 'package:web3_wallet_flutter/constants/rpc_info.dart';
import 'package:web3_wallet_flutter/constants/secure_storage_keys.dart';
import 'package:provider/provider.dart';
import 'package:web3_wallet_flutter/model/nft_model.dart';
import 'package:web3_wallet_flutter/model/wallet_private_key.dart';
import 'package:web3_wallet_flutter/services/moralis/queries.dart';
import 'package:web3dart/web3dart.dart';

class WalletDashboard extends StatefulWidget {
  final String privateKey;
  const WalletDashboard({Key? key, required this.privateKey}) : super(key: key);

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  late EthPrivateKey privateKeyObj;
  late RPCInfo rpcInfoObj;
  // late Future<Response> fetchNftResponse;
  late Future<List<NFT>> allNfts;
  String nativeCurencyBalance = "0.0000";
  Network currentChain = RPCInfo.goerliTestnet;
  final Client httpClient = Client();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _sendAmountController = TextEditingController();

  String txHash = "";
  // TransactionReceipt? receiptState;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentChainInfo();
    allNfts = fetchUserNFTs(
      EthPrivateKey.fromHex(widget.privateKey).address.hex,
      currentChain.moralisSymbol,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _recipientController.dispose();
    _sendAmountController.dispose();
    httpClient.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          DropdownButton(
            value: currentChain,
            items: rpcInfoObj.networks
                .map((network) => DropdownMenuItem(
                      child: Text(network.name),
                      value: network,
                    ))
                .toList(),
            onChanged: (Network? value) {
              setState(() {
                currentChain = value ?? RPCInfo.goerliTestnet;
                allNfts = fetchUserNFTs(
                  EthPrivateKey.fromHex(widget.privateKey).address.hex,
                  currentChain.moralisSymbol,
                );
              });
              getCurrentChainInfo();
            },
          ),
        ],
      ),
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => Clipboard.setData(
                      ClipboardData(text: privateKeyObj.address.hex),
                    ),
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
                  Text(
                    currentChain.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$nativeCurencyBalance ${currentChain.symbol}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () => displaySendERC20Dialog(context),
                    child: Text("Send ${currentChain.symbol}"),
                  ),
                  InkWell(
                    onTap: () => Clipboard.setData(
                      ClipboardData(text: txHash),
                    ),
                    child: Text(txHash),
                  ),
                  // Text("${receiptState?.status.toString()}"),
                  // Text("${receiptState?.from?.hex}"),
                  // Text("${receiptState?.logs}"),
                  ElevatedButton(
                    onPressed: () => handleLogOut(context),
                    child: const Text("Log out"),
                  ),

                  /// Painting the listview that will display all our NFTs
                  FutureBuilder<List<NFT>>(
                    future: allNfts,
                    builder: (context, AsyncSnapshot<List<NFT>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            dev.log(snapshot.data![index].image);
                            return Card(
                              elevation: 10.0,
                              child: Column(children: [
                                Image.network(
                                  snapshot.data![index].image,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                  width: 250,
                                  height: 250,
                                ),
                                Text(snapshot.data![index].name),
                              ]),
                            );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const Center(child: CircularProgressIndicator()),
              )
            : Container(),
      ]),
    );
  }

  void getCurrentChainInfo() async {
    dev.log("Calling get current chain info");
    privateKeyObj = EthPrivateKey.fromHex(widget.privateKey);
    // Constructing an object of RPCInfo to access the getters
    rpcInfoObj = RPCInfo();
    final EthereumAddress currentWallet =
        EthereumAddress.fromHex(privateKeyObj.address.hex);

    final Web3Client web3client = Web3Client(currentChain.rpcUrl, httpClient);

    final walletCurrentBalance = await web3client.getBalance(currentWallet);

    setState(() {
      nativeCurencyBalance = walletCurrentBalance
          .getValueInUnit(EtherUnit.ether)
          .toStringAsFixed(4);
    });
  }

  Future handleRefresh() async {
    setState(() {
      allNfts = fetchUserNFTs(
        EthPrivateKey.fromHex(widget.privateKey).address.hex,
        currentChain.moralisSymbol,
      );
    });
    getCurrentChainInfo();
  }

  void handleLogOut(BuildContext context) {
    const storage = FlutterSecureStorage();
    storage.delete(key: SecureStorage.privateKey);
    context.read<PrivateKey>().setPrivateKey(null);
  }

  void displaySendERC20Dialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sending ${currentChain.symbol}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        label: Text(
                          "Recipient Address",
                        ),
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return "Recipient address cannot be empty";
                        } else if (input == privateKeyObj.address.hex) {
                          return "Recipient cannot be yourself";
                        } else {
                          try {
                            // basically try parse address
                            EthereumAddress.fromHex(input);
                          } catch (e) {
                            return "Recipient address invalid";
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _sendAmountController,
                      decoration: InputDecoration(
                        label: Text(
                          "Send Amount (${currentChain.symbol})",
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autocorrect: false,
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return "Send amount cannot be empty";
                        } else if (double.tryParse(input) == null) {
                          return "Send amount must be numbers";
                        } else if (double.parse(input) >
                            double.parse(nativeCurencyBalance)) {
                          return "Send amount exceeded balance";
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        /// if form not validated, textformfields will be highlighted in red for error
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            Navigator.pop(context);
                            isLoading = true;
                          });
                          dev.log("Form is good to go");
                          handleSendNativeCurrency();
                        }
                      },
                      child: const Text("Next"))
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _recipientController.clear();
                  _sendAmountController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              )
            ],
          );
        });
  }

  /// STEPS for ERC20 (TODO)
  /// 1. approve wallet address to operate on the native currency
  /// 2. set allowance for the amount to operate
  /// 3. create raw transaction
  /// 4. send transaction
  ///
  /// STEPS for native currency (THIS)
  /// 1. sign a transaction
  /// 2. send raw transaction
  handleSendNativeCurrency() async {
    try {
      final Web3Client web3client = Web3Client(currentChain.rpcUrl, httpClient);

      final EthPrivateKey sender = EthPrivateKey.fromHex(widget.privateKey);

      final rawTx = await web3client.signTransaction(
        sender,
        Transaction(
          from: sender.address,
          to: EthereumAddress.fromHex(_recipientController.text.trim()),
          gasPrice: await web3client.getGasPrice(),
          value: EtherAmount.inWei(
            BigInt.from(
              (double.parse(_sendAmountController.text) * pow(10, 18)).toInt(),
            ),
          ),
        ),
        chainId: (await web3client.getChainId()).toInt(),
      );

      final sendTx = await web3client.sendRawTransaction(rawTx);

      // final receipt = await web3client.getTransactionReceipt(sendTx);

      // final blockStream = web3client
      //     .events(
      //       FilterOptions(
      //           fromBlock:
      //               (await web3client.getTransactionByHash(sendTx)).blockNumber,
      //           toBlock:
      //               (await web3client.getTransactionByHash(sendTx)).blockNumber,
      //           address: sender.address),
      //     )
      //     .asBroadcastStream();

      setState(() {
        isLoading = false;
        txHash = sendTx;
        // receiptState = receipt;
      });
    } on Exception catch (e) {
      SnackBar snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isLoading = false;
      });
    } finally {
      _sendAmountController.clear();
      _recipientController.clear();
    }
  }
}
