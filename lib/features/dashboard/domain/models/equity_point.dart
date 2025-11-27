class EquityPoint {
  final DateTime time;
  final double value;

  EquityPoint({required this.time, required this.value});

  factory EquityPoint.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'];
    DateTime parsed;
    if (rawTime is String) {
      parsed = DateTime.tryParse(rawTime) ?? _parseHourMinute(rawTime);
    } else if (rawTime is int) {
      parsed = DateTime.fromMillisecondsSinceEpoch(rawTime * 1000, isUtc: true)
          .toLocal();
    } else {
      parsed = DateTime.now();
    }
    return EquityPoint(
      time: parsed,
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }

  static DateTime _parseHourMinute(String value) {
    final now = DateTime.now();
    final parts = value.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? now.hour;
      final minute = int.tryParse(parts[1]) ?? now.minute;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return now;
  }
}
