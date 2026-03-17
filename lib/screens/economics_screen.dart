import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/stat_card.dart';

class EconomicsScreen extends StatelessWidget {
  const EconomicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Dark theme for a sleek financial look
      appBar: AppBar(
        title: const Text('Phase C: Infra-Portfolio Economics'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.tealAccent[400],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. The Top "Ticker" Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(
                  title: 'Est. Maintenance Deficit', 
                  value: '₹ 4.2 Cr', 
                  valueColor: Colors.redAccent
                ),
                StatCard(
                  title: 'Permeable Surface Lost', 
                  value: '14.5%', 
                  valueColor: Colors.orangeAccent
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // 2. The Chart Title
            const Text(
              'Compounding Infrastructure Depreciation',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cost correlation with expanding impermeable surfaces (2020-2026)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),

            // 3. The Line Chart (Using fl_chart)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey[700]!),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            // X-Axis represents years
                            const style = TextStyle(color: Colors.grey, fontSize: 12);
                            Widget text;
                            switch (value.toInt()) {
                              case 1: text = const Text('2021', style: style); break;
                              case 3: text = const Text('2023', style: style); break;
                              case 5: text = const Text('2025', style: style); break;
                              default: text = const Text('', style: style); break;
                            }
                            return SideTitleWidget(axisSide: meta.axisSide, child: text);
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        // These spots represent [Year, Cost in Crores]
                        spots: const [
                          FlSpot(0, 0.25), // Year 0: Base maintenance (₹25 Lakhs)
                          FlSpot(1, 0.30), // Year 1: Normal wear
                          FlSpot(2, 0.55), // Year 2: Micro-cracks from water pooling
                          FlSpot(3, 1.20), // Year 3: Pothole formation, localized patching
                          FlSpot(4, 2.80), // Year 4: Sub-base failure due to poor drainage
                          FlSpot(5, 5.50), // Year 5: Critical failure requiring major rehab
                        ],
                        isCurved: true,
                        color: Colors.redAccent,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget to create clean metric cards
  
}