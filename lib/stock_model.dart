class StockModel {

  final String stockName;
  final String buyPrice;
  final String targetPrice;
  final double currentPrice;
  final double highestPrice;

  StockModel({
    required this.stockName,
    required this.buyPrice,
    required this.targetPrice,
    required this.currentPrice,
    required this.highestPrice,
  });

  Map<String, dynamic> toJson() {

    return {

      'stockName': stockName,
      'buyPrice': buyPrice,
      'targetPrice': targetPrice,
      'currentPrice': currentPrice,
      'highestPrice': highestPrice,
    };
  }

  factory StockModel.fromJson(
      Map<String, dynamic> json) {

    return StockModel(

      stockName: json['stockName'],

      buyPrice: json['buyPrice'],

      targetPrice: json['targetPrice'],

      currentPrice: json['currentPrice'],

      highestPrice: json['highestPrice'],
    );
  }
}