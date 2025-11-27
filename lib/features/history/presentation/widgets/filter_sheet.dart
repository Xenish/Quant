import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/history_filter.dart';
import '../providers/history_provider.dart';

class HistoryFilterSheet extends ConsumerStatefulWidget {
  const HistoryFilterSheet({super.key});

  @override
  ConsumerState<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends ConsumerState<HistoryFilterSheet> {
  String? _selectedStrategy;
  DateTimeRange? _dateRange;
  late final TextEditingController _symbolController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(historyFilterProvider);
    _selectedStrategy = filter.strategy;
    if (filter.startDate != null && filter.endDate != null) {
      _dateRange =
          DateTimeRange(start: filter.startDate!, end: filter.endDate!);
    }
    _symbolController = TextEditingController(text: filter.symbol ?? '');
  }

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strategiesAsync = ref.watch(availableStrategiesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Trades',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                )
              ],
            ),
            const SizedBox(height: 16),
            strategiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Failed to load strategies: $e'),
              data: (strategies) => DropdownButtonFormField<String?>(
                value: _selectedStrategy,
                decoration: const InputDecoration(
                  labelText: 'Strategy',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All Strategies')),
                  ...strategies.map(
                    (strategy) => DropdownMenuItem(
                      value: strategy,
                      child: Text(strategy),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStrategy = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: 'Symbol',
                hintText: 'BTCUSDT',
                suffixIcon: _symbolController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => setState(() {
                          _symbolController.clear();
                        }),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date Range'),
              subtitle: Text(_dateRange == null
                  ? 'Any time'
                  : _dateRangeLabel(_dateRange!)),
              trailing: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check),
                label: const Text('Apply Filters'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    ref.read(historyFilterProvider.notifier).state = const HistoryFilter();
    setState(() {
      _selectedStrategy = null;
      _symbolController.clear();
      _dateRange = null;
    });
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filter = HistoryFilter(
      strategy: _selectedStrategy,
      symbol: _symbolController.text.trim().isNotEmpty
          ? _symbolController.text.trim()
          : null,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
    ref.read(historyFilterProvider.notifier).state = filter;
    Navigator.of(context).pop();
  }

  String _dateRangeLabel(DateTimeRange range) {
    final start = _formatDate(range.start);
    final end = _formatDate(range.end);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
