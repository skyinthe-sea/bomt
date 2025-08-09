import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://gowkatetjgcawxemuabm.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjIyNjQsImV4cCI6MjA2Mjc5ODI2NH0.GlcHoQofmXWSkowFN2FaXtSqnHWRxG3gsb6IyuE_pTo';
  
  // 🔑 Service Role Key for admin operations (bypasses RLS)
  static const String supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd2thdGV0amdjYXd4ZW11YWJtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzIyMjI2NCwiZXhwIjoyMDYyNzk4MjY0fQ.oEU2dLi1FGBf4v2Sm_2gRdwIEQNh5bxeGcIFCQDHM9A';

  static SupabaseClient get client => Supabase.instance.client;
  
  // 🔑 Admin client for operations that need to bypass RLS
  static SupabaseClient get adminClient => SupabaseClient(supabaseUrl, supabaseServiceKey);

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}