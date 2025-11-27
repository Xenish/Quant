class BacktestRun {
  final String id;
  final String strategy;
  final String symbol;
  final String timeframe;
  final DateTime startTime;
  final DateTime endTime;
  final double totalReturn;
  final int tradeCount;

  BacktestRun({
    required this.id,
    required this.strategy,
    required this.symbol,
    required this.timeframe,
    required this.startTime,
    required this.endTime,
    required this.totalReturn,
    required this.tradeCount,
  });

  factory BacktestRun.fromJson(Map<String, dynamic> json) {
    return BacktestRun(
      id: json['run_id'] ?? '',
      strategy: json['strategy'] ?? 'Unknown',
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalReturn: (json['cum_return'] as num?)?.toDouble() ?? 0.0,
      tradeCount: json['trade_count'] as int? ?? 0,
    );
  }
}

class TradeRecord {
  final String id;
  final String side;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double pnlPercent;

  TradeRecord({
    required this.id,
    required this.side,
    required this.entryTime,
    this.exitTime,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.pnlPercent,
  });

  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['trade_id'] ?? '',
      side: json['side'] ?? 'FLAT',
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'] as String)
          : null,
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      exitPrice: (json['exit_price'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      pnlPercent: (json['pnl_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
