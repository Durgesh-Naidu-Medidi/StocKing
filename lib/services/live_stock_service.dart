import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveStockService {

  Future<double> fetchPrice(
      String symbol) async {

    final url = Uri.parse(

      'https://api.twelvedata.com/price?symbol=$symbol&apikey=9c79a47fc0974ea8b0ff7575f0e4674f',
    );

    final response =
        await http.get(url);

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      if (data["price"] != null) {

        return double.parse(
            data["price"]);
      }
    }

    return 0.0;
  }
}