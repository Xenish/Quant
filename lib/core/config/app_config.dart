class AppConfig {
  // In a real scenario, this might come from .env or shared_preferences initially
  // For Sprint F1, we default to localhost (use your PC's local IP for emulator)
  // Android Emulator uses 10.0.2.2 to access host localhost.
  static const String defaultBaseUrl = "http://10.0.2.2:8000";

  static const String defaultSymbol = "BTCUSDT";
  static const String defaultTimeframe = "15m";
}
