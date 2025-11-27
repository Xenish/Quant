import 'dart:developer' as developer;

import '../../../core/network/dio_client.dart';
import '../domain/models/equity_point.dart';
import '../domain/models/live_status_model.dart';

class DashboardRepository {
  final DioClient _dioClient;

  DashboardRepository(this._dioClient);

  Future<LiveStatus> fetchLiveStatus() async {
    try {
      final response = await _dioClient.get('/api/live/status');
      return LiveStatus.fromJson(response);
    } catch (e) {
      developer.log('API Fetch failed ($e), returning MOCK data.');
      return _getMockData();
    }
  }

  Future<void> triggerPanicMode() async {
    await _dioClient.post('/api/control/panic');
  }

  Future<List<EquityPoint>> fetchEquityCurve() async {
    try {
      final response = await _dioClient.get('/api/stats/equity_curve');
      return (response as List)
          .map((e) => EquityPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Equity curve fetch failed ($e), returning mock data');
      return _mockEquityCurve();
    }
  }

  LiveStatus _getMockData() {
    return LiveStatus(
      runId: 'mock_run_001',
      symbol: 'BTCUSDT',
      timeframe: '15m',
      equity: 10500.25,
      realizedPnl: 150.0,
      dailyRealizedPnl: -45.50,
      openPositions: [
        LivePosition(
          id: '1',
          symbol: 'BTCUSDT',
          side: 'LONG',
          qty: 0.05,
          entryPrice: 95000,
          currentPrice: 95500,
          pnl: 25.0,
        ),
        LivePosition(
          id: '2',
          symbol: 'ETHUSDT',
          side: 'SHORT',
          qty: 1.5,
          entryPrice: 3200,
          currentPrice: 3210,
          pnl: -15.0,
        ),
      ],
      systemStatus: 'RUNNING',
    );
  }

  List<EquityPoint> _mockEquityCurve() {
    final now = DateTime.now();
    return List.generate(
      12,
      (index) => EquityPoint(
        time: now.subtract(Duration(hours: 11 - index)),
        value: 10000 + index * 120 * (index % 2 == 0 ? 1 : -0.5),
      ),
    );
  }
}
