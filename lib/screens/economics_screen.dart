import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/geo_point.dart';
import '../services/geo_api_service.dart';
import '../widgets/stat_card.dart';

class EconomicsScreen extends StatefulWidget {
  const EconomicsScreen({super.key});

  @override
  State<EconomicsScreen> createState() => _EconomicsScreenState();
}

class _EconomicsScreenState extends State<EconomicsScreen> {
  final GeoApiService _geoApiService = GeoApiService();

  EconomicsResult? _economicsResult;
  int _roadDamageCount = 0;
  bool _isLoading = true;
  String? _error;

  static const double _urbanGrowthRate = 0.145;
  static const double _forestLossSqKm = 3.5;

  @override
  void initState() {
    super.initState();
    _loadEconomics();
  }

  Future<void> _loadEconomics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final heatmap = await _geoApiService.fetchPotholeHeatmap();
      final roadDamageCount = heatmap.length;
      final economics = await _geoApiService.fetchInfrastructureDepreciation(
        urbanGrowthRate: _urbanGrowthRate,
        forestLossSqKm: _forestLossSqKm,
        roadDamageCount: roadDamageCount,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _roadDamageCount = roadDamageCount;
        _economicsResult = economics;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<FlSpot> _buildChartSpots() {
    final totalCrore = (_economicsResult?.rawCostInr ?? 0) / 10000000;
    const multipliers = [0.08, 0.14, 0.24, 0.42, 0.68, 1.0];
    return List.generate(
      multipliers.length,
      (index) => FlSpot(index.toDouble(), totalCrore * multipliers[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('Phase C: Infra-Portfolio Economics'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.tealAccent[400],
        actions: [
          IconButton(
            onPressed: _loadEconomics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatCard(
                            title: 'Est. Maintenance Deficit',
                            value: _economicsResult?.totalCostLabel ?? 'N/A',
                            valueColor: Colors.redAccent,
                          ),
                          StatCard(
                            title: 'Road Damage Events',
                            value: _roadDamageCount.toString(),
                            valueColor: Colors.orangeAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade700),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backend Inputs',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Urban growth rate: ${(_urbanGrowthRate * 100).toStringAsFixed(1)}% | Forest loss: ${_forestLossSqKm.toStringAsFixed(1)} sq km | Road damage count: $_roadDamageCount',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Compounding Infrastructure Depreciation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Live backend estimate with pothole heatmap count folded into the cost model.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey.shade700),
                          ),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      );
                                      final year = 2020 + value.toInt();
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text('$year', style: style),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildChartSpots(),
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (_economicsResult?.breakdown.entries.toList() ?? [])
                            .map(
                              (entry) => Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
    );
  }
}
