import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/remote/supabase_config.dart';
import 'app.dart';

Future<void> main() async {
  // Initialize Flutter bindings (ensure you can use async/await in main).
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (this only needs to be called once).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Start QuizMaster
  runApp(const QuizApp());
}