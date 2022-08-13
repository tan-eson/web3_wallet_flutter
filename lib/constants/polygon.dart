import 'package:web3_wallet_flutter/constants/network_template.dart';

class PolygonMainnet implements Network {
  @override
  String name = "Polygon Matic";

  @override
  String rpcUrl = "https://polygon-rpc.com";

  @override
  String symbol = "MATIC";

  @override
  String blockExplorer = "https://explorer.matic.network/";

  @override
  String moralisSymbol = "polygon";
}
