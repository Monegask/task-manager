import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Типизированный доступ к переменным окружения из .env.
///
/// Грузить через [load] до первого обращения к геттерам — обычно из main.
class Env {
  const Env._();

  static Future<void> load() => dotenv.load();

  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  /// В режиме разработки .env может быть пуст — пропускаем инициализацию
  /// сервисов, требующих секретов, чтобы каркас всё равно запускался.
  static bool get hasSupabaseCredentials =>
      (dotenv.env['SUPABASE_URL']?.isNotEmpty ?? false) &&
      (dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty ?? false);

  static String _read(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Переменная окружения $key не задана. Скопируй .env.example в .env '
        'и подставь значения из Supabase project settings.',
      );
    }
    return value;
  }
}
