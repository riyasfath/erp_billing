import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads values from the `.env` file. Call [EnvConfig.load] once in main().
class EnvConfig {
  EnvConfig._();

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get baseUrl {
    final value = dotenv.env['BASE_URL'];
    if (value == null || value.trim().isEmpty) {
      throw StateError('BASE_URL is missing in .env');
    }
    // Remove trailing slash so endpoints can start with '/'
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static Duration get connectTimeout => Duration(
      milliseconds: int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 15000);

  static Duration get receiveTimeout => Duration(
      milliseconds: int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '') ?? 15000);

  static bool get enableApiLogs =>
      (dotenv.env['ENABLE_API_LOGS'] ?? 'false').toLowerCase() == 'true';
}