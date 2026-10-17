import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration class managing confidential environment credentials.
class AppConfig {
  AppConfig._();

  /// Initialize environment variables from .env
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // In offline mode or if .env is missing, app runs safely with fallback defaults
    }
  }

  /// Supabase project URL (Free Tier Cloud Relay)
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';

  /// Supabase public anonymous API key
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-anon-key';

  /// Current environment name
  static String get environment =>
      dotenv.env['APP_ENV'] ?? 'development';

  /// Toggle for background cloud sync
  static bool get enableCloudSync =>
      (dotenv.env['ENABLE_CLOUD_SYNC'] ?? 'false').toLowerCase() == 'true';

  /// Debug logging enabled flag
  static bool get isDebugLogging =>
      (dotenv.env['DEBUG_LOGGING'] ?? 'true').toLowerCase() == 'true';
}
