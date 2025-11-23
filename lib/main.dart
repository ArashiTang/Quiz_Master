import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/remote/supabase_config.dart';
import 'app.dart';

Future<void> main() async {
  // 初始化 Flutter 绑定（确保可以在 main 里用 async / await）
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase（只需要在这里调用一次）
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 启动你的正式应用，而不是 demo 的 MyApp
  runApp(const QuizApp());
}