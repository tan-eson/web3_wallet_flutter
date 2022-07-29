import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

final String? baseUrl = dotenv.env['MORALIS_BASE_URL'];
final String? _apiKey = dotenv.env['MORALIS_API_KEY'];

Future<Response> fetchUserNFTs(String owner, String network) {
  final queryResponse = get(
    Uri.parse("$baseUrl/$owner/nft?chain=$network&format=decimal"),
    headers: {
      'x-api-key': _apiKey ?? "-",
    },
  );

  return queryResponse;
}
