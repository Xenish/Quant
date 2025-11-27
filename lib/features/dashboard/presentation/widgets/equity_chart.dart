import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/equity_point.dart';

class EquityChart extends StatelessWidget {
  const EquityChart({super.key, required this.points});

  final List<EquityPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No equity data')),
      );
    }

    final sorted = [...points]..sort((a, b) => a.time.compareTo(b.time));
    final minY = sorted.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = sorted.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final isPositive = sorted.last.value >= sorted.first.value;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    final bottomInterval =
        ((sorted.length / 4).ceil()).clamp(1, sorted.length).toDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: bottomInterval,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  final point = sorted[index];
                  final label =
                      '${point.time.hour.toString().padLeft(2, '0')}:${point.time.minute.toString().padLeft(2, '0')}';
                  return Text(label, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < sorted.length; i++)
                  FlSpot(i.toDouble(), sorted[i].value)
              ],
              isCurved: true,
              barWidth: 3,
              color: color,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _colorWithOpacity(color, 0.3),
                    _colorWithOpacity(color, 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItems: (spots) {
                return spots.map((s) {
                  final idx = s.x.toInt();
                  final point = sorted[idx.clamp(0, sorted.length - 1)];
                  return LineTooltipItem(
                    point.value.toStringAsFixed(2),
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          minY: minY - (minY * 0.01),
          maxY: maxY + (maxY * 0.01),
        ),
      ),
    );
  }

  Color _colorWithOpacity(Color color, double opacity) {
    final scaledAlpha = (color.a * opacity).clamp(0, 255).round();
    return color.withAlpha(scaledAlpha);
  }
}
