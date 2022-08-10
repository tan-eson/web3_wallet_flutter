import 'dart:developer';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: RefreshIndicator(
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
                Text(
                  currentChain.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('$nativeCurencyBalance ${currentChain.symbol}'),
                ElevatedButton(
                  onPressed: () => handleLogOut(context),
                  child: const Text("Log out"),
                ),
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
    );
  }

  void getCurrentChainInfo() async {
    log("Calling get current chain info");
    privateKeyObj = EthPrivateKey.fromHex(widget.privateKey);
    // Constructing an object of RPCInfo to access the getters
    rpcInfoObj = RPCInfo();
    final EthereumAddress currentWallet =
        EthereumAddress.fromHex(privateKeyObj.address.hex);

    final Client httpClient = Client();
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
}
