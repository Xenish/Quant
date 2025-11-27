import 'dart:developer' as developer;

import '../../../core/network/dio_client.dart';
import '../domain/models/history_filter.dart';
import '../domain/models/trade_history_models.dart';

class HistoryRepository {
  HistoryRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<BacktestRun>> getBacktestRuns({HistoryFilter? filter}) async {
    try {
      final response = await _dioClient.get(
        '/api/backtests',
        queryParameters: filter?.toQueryParameters(),
      );
      return (response as List)
          .map((entry) => BacktestRun.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Fetch runs failed ($e), returning mock data');
      return _getMockRuns();
    }
  }

  Future<List<TradeRecord>> getTradesForRun(
    String runId, {
    HistoryFilter? filter,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/trades/$runId',
        queryParameters: filter?.toQueryParameters(),
      );
      return (response as List)
          .map((entry) => TradeRecord.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Fetch trades failed ($e), returning mock data');
      return _getMockTrades(runId);
    }
  }

  Future<List<String>> getStrategies() async {
    try {
      final response = await _dioClient.get('/api/backtests/strategies');
      final list = (response as List).cast<String>();
      return list;
    } catch (e) {
      developer.log('Fetch strategies failed ($e), using mock data');
      final runs = _getMockRuns();
      return runs.map((e) => e.strategy).toSet().toList();
    }
  }

  List<BacktestRun> _getMockRuns() {
    return [
      BacktestRun(
        id: 'run_btc_1',
        strategy: 'Momentum_V1',
        symbol: 'BTCUSDT',
        timeframe: '15m',
        startTime: DateTime.now().subtract(const Duration(days: 30)),
        endTime: DateTime.now(),
        totalReturn: 0.125,
        tradeCount: 45,
      ),
      BacktestRun(
        id: 'run_eth_2',
        strategy: 'MeanRev_V2',
        symbol: 'ETHUSDT',
        timeframe: '1h',
        startTime: DateTime.now().subtract(const Duration(days: 60)),
        endTime: DateTime.now(),
        totalReturn: -0.05,
        tradeCount: 20,
      ),
    ];
  }

  List<TradeRecord> _getMockTrades(String runId) {
    return List.generate(10, (index) {
      final isWin = index % 3 != 0;
      final side = index.isEven ? 'LONG' : 'SHORT';
      final entryTime = DateTime.now().subtract(Duration(hours: index * 4));
      return TradeRecord(
        id: 'trade_${runId}_$index',
        side: side,
        entryTime: entryTime,
        exitTime: entryTime.add(const Duration(hours: 2)),
        entryPrice: 50000.0 + (index * 100),
        exitPrice: 50000.0 + (index * 100) + (isWin ? 500 : -200),
        pnl: isWin ? 50.0 : -20.0,
        pnlPercent: isWin ? 0.01 : -0.005,
      );
    });
  }
}
