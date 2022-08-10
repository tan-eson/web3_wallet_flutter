import 'package:web3_wallet_flutter/constants/eth.dart';
import 'package:web3_wallet_flutter/constants/eth_goerli.dart';
import 'package:web3_wallet_flutter/constants/network_template.dart';
import 'package:web3_wallet_flutter/constants/polygon.dart';

class RPCInfo {
  static Network ethereumMainnet = EthereumMainnet();
  static Network goerliTestnet = GoerliTestnet();
  static Network polygonMatic = PolygonMainnet();

  static final List<Network> _networks = [
    ethereumMainnet,
    goerliTestnet,
    polygonMatic,
  ];

  // using getter to return "_networks" in case of any future processes needed to be done before returning
  List<Network> get networks => _networks;
}
