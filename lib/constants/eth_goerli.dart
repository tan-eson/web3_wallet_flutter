import 'package:web3_wallet_flutter/constants/network_template.dart';

class GoerliTestnet implements Network {
  @override
  String name = "Goerli Testnet";

  @override
  String rpcUrl =
      "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161";

  @override
  String symbol = "GoerliETH";

  @override
  String blockExplorer = "https://goerli.etherscan.io";

  @override
  String moralisSymbol = 'goerli';
}
