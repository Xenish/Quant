class LiveStatus {
  final String runId;
  final String symbol;
  final String timeframe;
  final double equity;
  final double realizedPnl;
  final double dailyRealizedPnl;
  final List<LivePosition> openPositions;
  final String systemStatus;

  LiveStatus({
    required this.runId,
    required this.symbol,
    required this.timeframe,
    required this.equity,
    required this.realizedPnl,
    required this.dailyRealizedPnl,
    required this.openPositions,
    required this.systemStatus,
  });

  factory LiveStatus.fromJson(Map<String, dynamic> json) {
    return LiveStatus(
      runId: json['run_id'] ?? '',
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '',
      equity: (json['equity'] as num?)?.toDouble() ?? 0.0,
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
      dailyRealizedPnl: (json['daily_realized_pnl'] as num?)?.toDouble() ?? 0.0,
      openPositions: (json['open_positions'] as List?)
              ?.map((e) => LivePosition.fromJson(e))
              .toList() ??
          [],
      systemStatus: json['system_status'] ?? 'RUNNING',
    );
  }
}

class LivePosition {
  final String id;
  final String symbol;
  final String side;
  final double qty;
  final double entryPrice;
  final double currentPrice;
  final double pnl;

  LivePosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.entryPrice,
    required this.currentPrice,
    required this.pnl,
  });

  factory LivePosition.fromJson(Map<String, dynamic> json) {
    return LivePosition(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'FLAT',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
