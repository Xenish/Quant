import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/history_repository.dart';
import '../../domain/models/history_filter.dart';
import '../../domain/models/trade_history_models.dart';

final historyRepoProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(dioClientProvider));
});

final historyFilterProvider =
    StateProvider<HistoryFilter>((ref) => const HistoryFilter());

final _filterSelectionResetProvider = Provider<void>((ref) {
  ref.listen<HistoryFilter>(historyFilterProvider, (_, __) {
    ref.read(selectedRunIdProvider.notifier).state = null;
  });
});

final backtestRunsProvider = FutureProvider<List<BacktestRun>>((ref) async {
  ref.watch(_filterSelectionResetProvider);
  final filter = ref.watch(historyFilterProvider);
  return ref.watch(historyRepoProvider).getBacktestRuns(filter: filter);
});

final selectedRunIdProvider = StateProvider<String?>((ref) => null);

final selectedRunTradesProvider =
    FutureProvider<List<TradeRecord>>((ref) async {
  final runId = ref.watch(selectedRunIdProvider);
  final filter = ref.watch(historyFilterProvider);
  if (runId == null) {
    return [];
  }
  return ref.watch(historyRepoProvider).getTradesForRun(runId, filter: filter);
});

final availableStrategiesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(historyRepoProvider).getStrategies();
});
