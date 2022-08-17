import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3_wallet_flutter/model/nft_model.dart';

final String? baseUrl = dotenv.env['MORALIS_BASE_URL'];
final String? _apiKey = dotenv.env['MORALIS_API_KEY'];

Future<List<NFT>> fetchUserNFTs(String owner, String network) async {
  List<NFT> allNfts = [];
  try {
    final queryResponse = await get(
      Uri.parse("$baseUrl/$owner/nft?chain=$network&format=decimal"),
      headers: {
        'x-api-key': _apiKey ?? "-",
      },
    );

    final body = jsonDecode(queryResponse.body);
    final results = body['result'] ?? [];
    final List refinedResults = [...results];

    refinedResults.asMap().forEach((index, nft) {
      allNfts.add(NFT.fromJson(nft));

      log(allNfts.asMap().toString());
      log(allNfts.first.name.toString());
    });
  } catch (e) {
    log(e.toString());
  }
  return allNfts;
}
