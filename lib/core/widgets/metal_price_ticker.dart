import 'package:flutter/material.dart';
import 'dart:async';

class MetalPriceTicker extends StatefulWidget {
  const MetalPriceTicker({Key? key}) : super(key: key);

  @override
  State<MetalPriceTicker> createState() => _MetalPriceTickerState();
}

class _MetalPriceTickerState extends State<MetalPriceTicker> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  final List<Map<String, dynamic>> _metalPrices = [
    {'name': 'GOLD (24K)', 'price': '₹144,541', 'change': '+350', 'percent': '+0.47%', 'isUp': true},
    {'name': 'SILVER', 'price': '₹237,500', 'change': '-120', 'percent': '-0.13%', 'isUp': false},
    {'name': 'PLATINUM', 'price': '₹24,500', 'change': '+85', 'percent': '+0.35%', 'isUp': true},
    {'name': 'PALLADIUM', 'price': '₹85,200', 'change': '-400', 'percent': '-0.46%', 'isUp': false},
    {'name': 'GOLD (22K)', 'price': '₹69,150', 'change': '+310', 'percent': '+0.45%', 'isUp': true},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    // A 50ms periodic timer gives ~20fps smooth scrolling
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 1.0; // scroll speed

        if (maxScroll > 0) {
          if (currentScroll >= maxScroll) {
            _scrollController.jumpTo(0.0);
          } else {
            _scrollController.jumpTo(currentScroll + delta);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF121212), // Deep dark for professional look
        border: Border(
           bottom: BorderSide(color: Color(0xFF333333), width: 1.0),
        )
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Disable user scroll
        itemBuilder: (context, index) {
          // Infinite loop by using modulo
          final item = _metalPrices[index % _metalPrices.length];
          final bool isUp = item['isUp'];
          // Using standard green and red from stock apps
          final Color trendColor = isUp ? const Color(0xFF00E676) : const Color(0xFFFF5252);
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['price'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: trendColor,
                  size: 24,
                ),
                Text(
                  '${item['change']} (${item['percent']})',
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(width: 24),
                // Separator dot
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
