import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import 'package:trade_companion/features/settings/presentation/providers/settings_provider.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/models/equity_point.dart';
import '../../domain/models/live_status_model.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return DioClient(baseUrl: baseUrl);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioClientProvider));
});

final panicActionInProgressProvider = StateProvider<bool>((ref) => false);

final liveStatusProvider = StreamProvider.autoDispose<LiveStatus>((ref) async* {
  final repository = ref.watch(dashboardRepositoryProvider);
  var isActive = true;
  ref.onDispose(() => isActive = false);

  while (isActive) {
    yield await repository.fetchLiveStatus();
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!isActive) {
        break;
      }
    }
  }
});

final equityCurveProvider =
    FutureProvider.autoDispose<List<EquityPoint>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final data = await repository.fetchEquityCurve();
  return data;
});
