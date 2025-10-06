import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_core/firebase_core.dart'; // 현재 Mock 사용으로 주석 처리
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // 현재 Mock 사용으로 주석 처리

import 'core/env/env_loader.dart';
import 'core/logging/logger.dart';
import 'presentation/routes/router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvLoader.load();

  // Initialize Firebase (현재 Mock 사용으로 주석 처리)
  // await Firebase.initializeApp();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: EnvLoader.supabaseUrl,
    anonKey: EnvLoader.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),
  );

  // Initialize Google Mobile Ads (현재 Mock 사용으로 주석 처리)
  // await MobileAds.instance.initialize();

  // Initialize Logger
  AppLogger.init();

  // Print environment variables (debug mode only)
  if (EnvLoader.debugMode) {
    EnvLoader.printAll();
  }

  runApp(const ProviderScope(child: LuckyWalkApp()));
}

class LuckyWalkApp extends ConsumerWidget {
  const LuckyWalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LuckyWalk',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
