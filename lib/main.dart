import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();

  if (Env.hasSupabaseCredentials) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } else if (kDebugMode) {
    debugPrint(
      'WARN: SUPABASE_URL/SUPABASE_ANON_KEY не заданы — '
      'удалённый бэкенд отключён. Скопируй .env.example в .env.',
    );
  }

  runApp(const ProviderScope(child: TaskManagerApp()));
}
