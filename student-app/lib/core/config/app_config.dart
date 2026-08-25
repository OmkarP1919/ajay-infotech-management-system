class AppConfig {
  static const String appName = 'Ajay Infotech';
  static const String appVersion = '1.0.0';

  // Live Supabase Cloud Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fsibagcyyducyurkdoii.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzaWJhZ2N5eWR1Y3l1cmtkb2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMzM0NTQsImV4cCI6MjEwMjgwOTQ1NH0.LoCaDuUatmxrs5evSkK-oVK2bVWx2ncsWuOxE3N_MuQ',
  );

  // Razorpay Gateway Configuration (Public Key ID ONLY)
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_TS6aY6OCDjZldb',
  );
}
