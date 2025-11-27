class HistoryFilter {
  final String? strategy;
  final String? symbol;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoryFilter({
    this.strategy,
    this.symbol,
    this.startDate,
    this.endDate,
  });

  HistoryFilter copyWith({
    String? strategy,
    String? symbol,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStrategy = false,
    bool clearSymbol = false,
    bool clearDates = false,
  }) {
    return HistoryFilter(
      strategy: clearStrategy ? null : strategy ?? this.strategy,
      symbol: clearSymbol ? null : symbol ?? this.symbol,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
    );
  }

  bool get isEmpty =>
      strategy == null &&
      symbol == null &&
      startDate == null &&
      endDate == null;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (strategy != null && strategy!.isNotEmpty) {
      params['strategy_id'] = strategy;
    }
    if (symbol != null && symbol!.isNotEmpty) {
      params['symbol'] = symbol;
    }
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }
    return params;
  }
}
