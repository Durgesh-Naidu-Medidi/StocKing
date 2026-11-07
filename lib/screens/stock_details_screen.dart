
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../stock_model.dart';
import '../services/live_stock_service.dart';

class StockDetailsScreen extends StatefulWidget {
  final StockModel stock;

  const StockDetailsScreen({
    super.key,
    required this.stock,
  });

  @override
  State<StockDetailsScreen> createState() =>
      _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  final LiveStockService stockService = LiveStockService();

  String selectedRange = '1M';

  List<double> prices = [];

  bool isLoading = true;
  String? errorMessage;

  final Map<String, Map<String, dynamic>> ranges = {
    '1D': {'interval': '5min', 'outputsize': 78},
    '1W': {'interval': '1h', 'outputsize': 35},
    '1M': {'interval': '1day', 'outputsize': 30},
    '1Y': {'interval': '1week', 'outputsize': 52},
  };

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final range = ranges[selectedRange]!;

      final result = await stockService.fetchHistoricalPrices(
        widget.stock.stockName,
        interval: range['interval'] as String,
        outputsize: range['outputsize'] as int,
      );

      if (!mounted) return;

      setState(() {
        prices = result;
        isLoading = false;

        if (prices.isEmpty) {
          errorMessage = 'No historical data available.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void changeRange(String range) {
    if (selectedRange == range) return;

    setState(() {
      selectedRange = range;
    });

    loadChartData();
  }

  double get profitLoss {
    final buyPrice =
        double.tryParse(widget.stock.buyPrice) ?? 0;

    if (buyPrice <= 0) return 0;

    return ((widget.stock.currentPrice - buyPrice) / buyPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice = widget.stock.currentPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        elevation: 0,
        title: Text(
          widget.stock.stockName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Price',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '₹${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(2)}% from buy price',
              style: TextStyle(
                color: profitLoss >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Stock information
            Row(
              children: [
                _infoCard(
                  'Buy Price',
                  '₹${widget.stock.buyPrice}',
                ),
                const SizedBox(width: 12),
                _infoCard(
                  'Target Price',
                  '₹${widget.stock.targetPrice}',
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Price History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // Time range selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ranges.keys.map((range) {
                final isSelected = selectedRange == range;

                return GestureDetector(
                  onTap: () => changeRange(range),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.greenAccent
                          : const Color(0xFF151515),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Text(
                      range,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // Historical chart
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(20),
              ),

              child: buildChart(),
            ),

            const SizedBox(height: 25),

            const Text(
              'Stock Performance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _performanceRow(
              'Highest Recorded Price',
              '₹${widget.stock.highestPrice.toStringAsFixed(2)}',
            ),

            _performanceRow(
              'Your Buy Price',
              '₹${widget.stock.buyPrice}',
            ),

            _performanceRow(
              'Your Target Price',
              '₹${widget.stock.targetPrice}',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.greenAccent,
        ),
      );
    }

    if (errorMessage != null || prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.show_chart,
              color: Colors.grey,
              size: 40,
            ),

            const SizedBox(height: 12),

            Text(
              errorMessage ?? 'No chart data available.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: loadChartData,
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        ),
      );
    }

    final spots = prices.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value,
      );
    }).toList();

    final minimumPrice = prices.reduce(
      (a, b) => a < b ? a : b,
    );

    final maximumPrice = prices.reduce(
      (a, b) => a > b ? a : b,
    );

    final difference = maximumPrice - minimumPrice;

    final padding = difference == 0
        ? (maximumPrice.abs() * 0.02).clamp(1.0, double.infinity)
        : difference * 0.15;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (prices.length - 1).toDouble(),

        minY: minimumPrice - padding,
        maxY: maximumPrice + padding,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maximumPrice - minimumPrice) == 0
              ? null
              : difference / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            );
          },
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: prices.length > 4
                  ? (prices.length / 4).ceilToDouble()
                  : 1,

              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${value.toInt() + 1}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '₹${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 3,
            dotData: const FlDotData(show: false),

            belowBarData: BarAreaData(
              show: true,
              color: Colors.greenAccent.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
