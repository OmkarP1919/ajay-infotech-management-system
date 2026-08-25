import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/supabase_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Cloud Services & Modular Notifications
  await SupabaseService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: AjayInfotechApp(),
    ),
  );
}
