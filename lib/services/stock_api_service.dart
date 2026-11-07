
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  // Replace with a newly generated API key.
  final String apiKey = '9c79a47fc0974ea8b0ff7575f0e4674';

  Future<double> fetchStockPrice(String symbol) async {
    final url = Uri.https(
      'api.twelvedata.com',
      '/price',
      {
        'symbol': symbol,
        'apikey': apiKey,
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load stock price: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data['price'] == null) {
      throw Exception(
        data['message'] ?? 'Stock price is unavailable.',
      );
    }

    return double.parse(data['price'].toString());
  }
}
