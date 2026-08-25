import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

const String supabaseUrl = 'https://fsibagcyyducyurkdoii.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzaWJhZ2N5eWR1Y3l1cmtkb2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMzM0NTQsImV4cCI6MjEwMjgwOTQ1NH0.LoCaDuUatmxrs5evSkK-oVK2bVWx2ncsWuOxE3N_MuQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  runApp(
    const ProviderScope(
      child: AjayInfotechAdminApp(),
    ),
  );
}
