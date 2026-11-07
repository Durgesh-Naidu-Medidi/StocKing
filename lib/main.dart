import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'search_screen.dart';
import 'screens/stock_details_screen.dart';
import 'stock_model.dart';
import 'dart:async';
import 'services/live_stock_service.dart';

List<StockModel> watchlist = [];

void main() {
  runApp(const StocKingApp());
}

class StocKingApp extends StatelessWidget {
  const StocKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'StocKing',

      theme: ThemeData(
        brightness: Brightness.dark,
      ),

      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

      Timer? _refreshTimer;

  void addStock(StockModel stock) {

    setState(() {

      watchlist.add(stock);

      saveWatchlist();
    });
  }
  final LiveStockService stockService =
    LiveStockService();

@override
void initState() {
  super.initState();

  loadWatchlist();

  _refreshTimer = Timer.periodic(
    const Duration(seconds: 10),
    (timer) {
      if (mounted) {
        refreshPrices();
      }
    },
  );
}

@override
void dispose(){
  _refreshTimer?.cancel();
  super.dispose();
}

Future<void> saveWatchlist() async {

  final prefs =
      await SharedPreferences.getInstance();

  final List<String> stockList =
      watchlist.map((stock) {

    return jsonEncode(stock.toJson());

  }).toList().cast<String>();

  await prefs.setStringList(
    'watchlist',
    stockList,
  );
}

Future<void> loadWatchlist() async {

  final prefs =
      await SharedPreferences.getInstance();

  final List<String>? stockList =
      prefs.getStringList('watchlist');

  if (stockList != null && mounted) {

    setState(() {

      watchlist.clear();

      watchlist.addAll(

        stockList.map((stockString) {

          final data =
              jsonDecode(stockString);

          return StockModel.fromJson(data);

        }).toList(),
      );
    });
  }
}
Future<void> refreshPrices() async {

  for (int i = 0;
      i < watchlist.length;
      i++) {

    final latestPrice =
        await stockService.fetchPrice(
      watchlist[i].stockName,
    );
    final highest =
    watchlist[i].highestPrice;

final target =
    double.tryParse(
          watchlist[i]
              .targetPrice,
        ) ??
        0;

final reachedTarget =
    latestPrice >= target;

final droppedFromPeak =
    latestPrice <
        highest * 0.95;
        if (reachedTarget &&
    droppedFromPeak) {

  showSmartAlert(

    watchlist[i].stockName,

    latestPrice,
  );
}

    watchlist[i] = StockModel(

      stockName:
          watchlist[i].stockName,

      buyPrice:
          watchlist[i].buyPrice,

      targetPrice:
          watchlist[i].targetPrice,

      currentPrice: latestPrice,

highestPrice:
    latestPrice >
            watchlist[i]
                .highestPrice
        ? latestPrice
        : watchlist[i]
            .highestPrice,
    );
  }

  saveWatchlist();

  if (!mounted) return;

  setState(() {});
}
void showSmartAlert(

  String stockName,
  double currentPrice,
) {

  showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        backgroundColor:
            const Color(0xFF151515),

        title: const Text(
          "⚠ Profit Alert",

          style: TextStyle(
            color: Colors.white,
          ),
        ),

        content: Text(

          "$stockName is dropping after profit peak.\n\nCurrent Price: ₹$currentPrice",

          style: const TextStyle(
            color: Colors.white70,
          ),
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);
            },

            child: const Text(
              "OK",
            ),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF050505),

      bottomNavigationBar:
          BottomNavigationBar(

        backgroundColor:
            const Color(0xFF0D0D0D),

        selectedItemColor:
            Colors.greenAccent,

        unselectedItemColor:
            Colors.grey,

        type:
            BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: "Watchlist",
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.pie_chart_outline),

            label: "Portfolio",
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.person_outline),

            label: "Profile",
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.greenAccent,

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),

        onPressed: () {

          Navigator.push(
             context,

             MaterialPageRoute(
               builder: (context) =>
                  SearchScreen(
                onAdd: addStock,
      ),
    ),
  );
},
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(16),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      "StocKing 👑",

                      style: TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    CircleAvatar(
                      backgroundColor:
                          Colors.grey
                              .shade900,

                      child: const Icon(
                        Icons.person,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 25),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                            0xFF151515),

                    borderRadius:
                        BorderRadius
                            .circular(18),
                  ),

                  child:
                      const TextField(
                    style: TextStyle(
                        color:
                            Colors.white),

                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,

                      hintText:
                          "Search Stocks",

                      hintStyle:
                          TextStyle(
                              color:
                                  Colors.grey),

                      icon: Icon(
                        Icons.search,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 25),

                SizedBox(
                  height: 45,

                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,

                    children: [

                      categoryChip(
                        title: "Stocks",
                        isSelected:
                            true,
                      ),

                      categoryChip(
                        title: "Crypto",
                      ),

                      categoryChip(
                        title: "Forex",
                      ),

                      categoryChip(
                        title: "ETFs",
                      ),

                      categoryChip(
                        title: "News",
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 30),

                const Text(
                  "Your Watchlist",

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 20),

                watchlist.isEmpty

                    ? const Center(
                        child: Text(
                          "No stocks added yet",

                          style: TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )

                    : GridView.builder(

                        itemCount:
                            watchlist.length,

                        shrinkWrap:
                            true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(

                          crossAxisCount:
                              2,

                          crossAxisSpacing:
                              16,

                          mainAxisSpacing:
                              16,

                          childAspectRatio:
                              0.9,
                        ),

                        itemBuilder:
                            (context, index) {

                          final stock =
                              watchlist[index];

                          final target =
    double.tryParse(
          stock.targetPrice,
        ) ??
        0;

final reachedTarget =
    stock.currentPrice >= target;

final droppedFromPeak =
    stock.currentPrice <
        stock.highestPrice * 0.95;

                          return premiumStockCard(

                            context:
                                context,

                            stock:
                                stock.stockName,

                            price:
                              "₹${stock.currentPrice}",

                            change: reachedTarget

    ? droppedFromPeak

        ? "⚠ Profit Falling"

        : "🎯 Target Hit"

    : "Target ₹${stock.targetPrice}",

                            isProfit:
                                true,
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget categoryChip({
  required String title,
  bool isSelected = false,
}) {

  return Container(
    margin: const EdgeInsets.only(right: 12),

    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),

    decoration: BoxDecoration(
      color: isSelected
          ? Colors.greenAccent
          : const Color(0xFF151515),

      borderRadius: BorderRadius.circular(30),
    ),

    child: Text(
      title,

      style: TextStyle(
        color:
            isSelected ? Colors.black : Colors.white,

        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget premiumStockCard({
  required BuildContext context,
  required String stock,
  required String price,
  required String change,
  required bool isProfit,
}) {

  return GestureDetector(

   onTap: () {
  final selectedStock = watchlist.firstWhere(
    (item) => item.stockName == stock,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StockDetailsScreen(
        stock: selectedStock,
      ),
    ),
  );
},

    child: Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius:
            BorderRadius.circular(26),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            backgroundColor:
                isProfit
                    ? Colors.green
                    : Colors.red,

            child: Text(
              stock[0],

              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const Spacer(),

          Text(
            stock,

            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            price,

            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            change,

            style: TextStyle(
              color: isProfit
                  ? Colors.greenAccent
                  : Colors.redAccent,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}