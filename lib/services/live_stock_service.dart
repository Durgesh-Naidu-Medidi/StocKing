
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveStockService {

  // Use a newly generated API key.
  final String apiKey = 'f0be723330494bb5a41fc63fe1976c8a';

  // Fetch current stock price
  Future<double> fetchPrice(String symbol) async {

    final url = Uri.https(
      'api.twelvedata.com',
      '/price',
      {
        'symbol': symbol,
        'apikey': apiKey,
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['price'] != null) {
        return double.parse(data['price'].toString());
      }

      throw Exception(data['message'] ?? 'Unable to fetch stock price');
    }

    throw Exception('API request failed: ${response.statusCode}');
  }

  // Fetch historical stock prices
  
Future<List<double>> fetchHistoricalPrices(
  String symbol, {
  required String interval,
  int outputsize = 30,
}) async {
  final url = Uri.https(
    'api.twelvedata.com',
    '/time_series',
    {
      'symbol': symbol,
      'interval': interval,
      'outputsize': outputsize.toString(),
      'apikey': apiKey,
    },
  );

  final response = await http.get(url);

  // Show the actual HTTP error if the request fails.
  if (response.statusCode != 200) {
    throw Exception(
      'HTTP ${response.statusCode}: ${response.body}',
    );
  }

  final data = jsonDecode(response.body);

  // Twelve Data can return API errors even with HTTP 200.
  if (data['values'] == null) {
    throw Exception(
      'Twelve Data error: ${data['message'] ?? response.body}',
    );
  }

  final List values = data['values'];

  return values.reversed.map<double>((item) {
    return double.parse(item['close'].toString());
  }).toList();
}
}