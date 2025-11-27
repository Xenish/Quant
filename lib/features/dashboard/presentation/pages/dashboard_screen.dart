import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../widgets/equity_chart.dart';
import '../../domain/models/live_status_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveStatusAsync = ref.watch(liveStatusProvider);
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueGrey.shade100,
              child: const Icon(Icons.show_chart, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            const Text('Quant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(liveStatusProvider),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          )
        ],
      ),
      body: liveStatusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading data:\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(liveStatusProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
        data: (status) => _buildDashboardContent(
          context,
          ref,
          status,
          currencyFormat,
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    LiveStatus status,
    NumberFormat fmt,
  ) {
    final equityCurveAsync = ref.watch(equityCurveProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(liveStatusProvider);
        await ref.read(liveStatusProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_shouldShowStatusBanner(status.systemStatus))
            _SystemStatusBanner(status: status.systemStatus),
          if (_shouldShowStatusBanner(status.systemStatus))
            const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Equity',
                  value: fmt.format(status.equity),
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Daily PnL',
                  value: fmt.format(status.dailyRealizedPnl),
                  color: status.dailyRealizedPnl >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          equityCurveAsync.when(
            data: (points) => EquityChart(points: points),
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 220,
              child: Center(child: Text('Chart error: $e')),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Open Positions (${status.openPositions.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (status.openPositions.isEmpty)
            _buildEmptyState()
          else
            ...status.openPositions
                .map((pos) => _PositionCard(pos: pos, fmt: fmt))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorWithOpacity(Colors.grey, 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('No open positions'),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorWithOpacity(color, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorWithOpacity(color, 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  final LivePosition pos;
  final NumberFormat fmt;

  const _PositionCard({required this.pos, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isProfit = pos.pnl >= 0;
    final pnlColor = isProfit ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      pos.symbol,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pos.side == 'LONG'
                            ? _colorWithOpacity(Colors.green, 0.2)
                            : _colorWithOpacity(Colors.red, 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pos.side,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: pos.side == 'LONG' ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  fmt.format(pos.pnl),
                  style: TextStyle(
                    color: pnlColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn(label: 'Size', value: '${pos.qty}'),
                _InfoColumn(label: 'Entry', value: '${pos.entryPrice}'),
                _InfoColumn(label: 'Mark', value: '${pos.currentPrice}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

Color _colorWithOpacity(Color color, double opacity) {
  final scaledAlpha = (color.a * opacity).clamp(0, 255).round();
  return color.withAlpha(scaledAlpha);
}

bool _shouldShowStatusBanner(String status) {
  return status.toUpperCase() != 'RUNNING';
}

class _SystemStatusBanner extends StatelessWidget {
  const _SystemStatusBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final isPanic = normalized == 'PANIC';
    final color = isPanic ? Colors.orange : Colors.red;
    final label = isPanic ? 'PANIC MODE ACTIVE' : 'SYSTEM HALTED';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorWithOpacity(color, 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label ($normalized)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
