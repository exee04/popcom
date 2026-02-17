import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';

final stats = [
  StatPoint(1, 10),
  StatPoint(2, 14),
  StatPoint(3, 8),
  StatPoint(4, 20),
  StatPoint(5, 16),
];

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 50,
        left: 25,
        right: 25,
      ),
      child: GlassyCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatsBarChart(data: stats),
        ),
      ),
    );
  }
}

class StatsBarChart extends StatelessWidget {
  final List<StatPoint> data;

  const StatsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                            right: 10,
                            left: 11,
                          ),
                          child: Text(
                            labels[value.toInt() - 1],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 9 ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.map((e) {
                  return BarChartGroupData(
                    x: e.x.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: e.y,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),

            // TOP-LEFT OVERLAY TEXT
            const Positioned(
              top: 8,
              left: 8,
              child: Text(
                "Sales",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _average(List<StatPoint> data) {
    return data.map((e) => e.y).reduce((a, b) => a + b) / data.length;
  }
}

class StatPoint {
  final double x;
  final double y;

  StatPoint(this.x, this.y);
}

class GlassyCard extends StatelessWidget {
  final Widget child;

  const GlassyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
