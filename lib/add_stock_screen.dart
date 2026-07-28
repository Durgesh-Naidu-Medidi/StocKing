import 'package:flutter/material.dart';
import 'stock_model.dart';
import 'services/live_stock_service.dart';
class AddStockScreen extends StatefulWidget {
  final Function(StockModel) onAdd;
  final String stockName;

  const AddStockScreen({
    super.key,
    required this.onAdd,
    required this.stockName,
  });

  @override
  State<AddStockScreen> createState() =>
      _AddStockScreenState();
}

class _AddStockScreenState
    extends State<AddStockScreen> {

  final TextEditingController
      buyPriceController =
          TextEditingController();

  final TextEditingController
      targetPriceController =
          TextEditingController();

  final LiveStockService stockService =
      LiveStockService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF050505),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          widget.stockName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(
              "Buy Price",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: buyPriceController,

              keyboardType:
                  TextInputType.number,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                filled: true,
                fillColor:
                    const Color(0xFF151515),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),

                  borderSide: BorderSide.none,
                ),

                hintText: "Enter buy price",

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Target Price",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  targetPriceController,

              keyboardType:
                  TextInputType.number,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                filled: true,
                fillColor:
                    const Color(0xFF151515),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),

                  borderSide: BorderSide.none,
                ),

                hintText:
                    "Enter target price",

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
          

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.greenAccent,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                onPressed: () async {

  final livePrice =
      await stockService.fetchPrice(
    widget.stockName,
  );

  final stock = StockModel(

    stockName: widget.stockName,

    buyPrice:
        buyPriceController.text,

    targetPrice:
        targetPriceController.text,

    currentPrice: livePrice,
    highestPrice: livePrice,
  );

  widget.onAdd(stock);

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content: Text(
        "Stock Added Successfully",
      ),
    ),
  );

  Navigator.pop(context);
},

                child: const Text(
                  "Add Stock",

                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}