import 'package:web3_wallet_flutter/constants/network_template.dart';

class EthereumMainnet implements Network {
  @override
  String name = "Ethereum Mainnet";

  @override
  String rpcUrl =
      "https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161";

  @override
  String symbol = "ETH";

  @override
  String blockExplorer = "https://etherscan.io";

  @override
  String moralisSymbol = "eth";
}
