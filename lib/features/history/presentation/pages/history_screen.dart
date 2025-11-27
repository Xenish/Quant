import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/history_filter.dart';
import '../../domain/models/trade_history_models.dart';
import '../providers/history_provider.dart';
import '../widgets/filter_sheet.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(backtestRunsProvider);
    final selectedRunId = ref.watch(selectedRunIdProvider);

    final activeFilter = ref.watch(historyFilterProvider);
    final filterChips = _buildFilterChips(context, ref, activeFilter);

    return Scaffold(
      appBar: AppBar(title: const Text('Trade History')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFilterSheet(context),
        child: const Icon(Icons.filter_list),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 160,
            child: runsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (runs) {
                if (runs.isEmpty) {
                  return const Center(child: Text('No history found'));
                }

                if (selectedRunId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedRunIdProvider.notifier).state =
                        runs.first.id;
                  });
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: runs.length,
                  itemBuilder: (context, index) {
                    final run = runs[index];
                    final isSelected = run.id == selectedRunId;
                    return _RunCard(
                      run: run,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(selectedRunIdProvider.notifier)
                          .state = run.id,
                    );
                  },
                );
              },
            ),
          ),
          if (filterChips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterChips,
              ),
            ),
          if (filterChips.isNotEmpty) const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: selectedRunId == null
                ? const Center(child: Text('Select a run to see trades'))
                : const _TradesList(),
          ),
        ],
      ),
    );
  }
}

class _TradesList extends ConsumerWidget {
  const _TradesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(selectedRunTradesProvider);

    return tradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (trades) {
        if (trades.isEmpty) {
          return const Center(child: Text('No trades in this run'));
        }

        return ListView.separated(
          itemCount: trades.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final trade = trades[index];
            final isWin = trade.pnl >= 0;
            final sideColor = trade.side == 'LONG' ? Colors.green : Colors.red;
            return ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorWithOpacity(sideColor, 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.side,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: sideColor,
                  ),
                ),
              ),
              title: Text(
                '\$${trade.entryPrice.toStringAsFixed(2)} ➜ \$${trade.exitPrice.toStringAsFixed(2)}',
              ),
              subtitle: Text(DateFormat('MM/dd HH:mm').format(trade.entryTime)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${trade.pnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isWin ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    '${(trade.pnlPercent * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.run,
    required this.isSelected,
    required this.onTap,
  });

  final BacktestRun run;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        isSelected ? colorScheme.primary : _colorWithOpacity(Colors.grey, 0.3);
    final bgColor =
        isSelected ? _colorWithOpacity(colorScheme.primary, 0.1) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(run.symbol,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(run.strategy,
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            const SizedBox(height: 8),
            Text(
              '${(run.totalReturn * 100).toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: run.totalReturn >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const Spacer(),
            Text('${run.tradeCount} Trades',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

Color _colorWithOpacity(Color color, double opacity) {
  final scaledAlpha = (color.a * opacity).clamp(0, 255).round();
  return color.withAlpha(scaledAlpha);
}

List<Widget> _buildFilterChips(
  BuildContext context,
  WidgetRef ref,
  HistoryFilter filter,
) {
  final chips = <Widget>[];
  if (filter.strategy != null) {
    chips.add(
      _FilterChip(
        label: filter.strategy!,
        onDeleted: () => ref.read(historyFilterProvider.notifier).state =
            filter.copyWith(clearStrategy: true),
      ),
    );
  }
  if (filter.symbol != null) {
    chips.add(
      _FilterChip(
        label: filter.symbol!,
        onDeleted: () => ref.read(historyFilterProvider.notifier).state =
            filter.copyWith(clearSymbol: true),
      ),
    );
  }
  if (filter.startDate != null && filter.endDate != null) {
    chips.add(
      _FilterChip(
        label:
            '${_formatShort(filter.startDate!)} - ${_formatShort(filter.endDate!)}',
        onDeleted: () => ref.read(historyFilterProvider.notifier).state =
            filter.copyWith(clearDates: true),
      ),
    );
  }
  return chips;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
    );
  }
}

String _formatShort(DateTime date) {
  return '${date.month}/${date.day}';
}

void _openFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: HistoryFilterSheet(),
    ),
  );
}
