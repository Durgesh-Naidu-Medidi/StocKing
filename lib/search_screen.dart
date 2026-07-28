import 'package:flutter/material.dart';
import 'add_stock_screen.dart';
import 'stock_model.dart';

class SearchScreen extends StatefulWidget {

  final Function(StockModel) onAdd;

  const SearchScreen({
    super.key,
    required this.onAdd,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  final TextEditingController
      searchController =
          TextEditingController();

  final List<String> allStocks = [

    "AAPL",
    "TSLA",
    "NVDA",
    "META",
    "NFLX",
    "MSFT",
    "GOOGL",
    "AMZN",
    "RELIANCE",
    "TCS",
    "INFY",
    "HDFCBANK",
  ];

  List<String> filteredStocks = [];

  @override
  void initState() {
    super.initState();

    filteredStocks = allStocks;
  }

  void searchStocks(String query) {

    final results = allStocks.where((stock) {

      return stock.toLowerCase()
          .contains(query.toLowerCase());

    }).toList();

    setState(() {

      filteredStocks = results;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF050505),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          "Search Stocks",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller:
                  searchController,

              onChanged: searchStocks,

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

                  borderSide:
                      BorderSide.none,
                ),

                hintText:
                    "Search company...",

                hintStyle:
                    const TextStyle(
                  color: Colors.grey,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(

                itemCount:
                    filteredStocks.length,

                itemBuilder:
                    (context, index) {

                  final stock =
                      filteredStocks[index];

                  return Container(

                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFF151515),

                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),

                    child: ListTile(

                      leading:
                          CircleAvatar(
                        backgroundColor:
                            Colors.greenAccent,

                        child: Text(
                          stock[0],

                          style:
                              const TextStyle(
                            color:
                                Colors.black,
                          ),
                        ),
                      ),

                      title: Text(
                        stock,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Tap to add stock",

                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 18,
                      ),

                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddStockScreen(

                              stockName: stock,

                              onAdd:
                                  widget.onAdd,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}