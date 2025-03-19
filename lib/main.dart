import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mice_plan/config/router/router_provider.dart';
import 'package:mice_plan/constants/styles.dart';
import 'package:mice_plan/firebase_options.dart';
import 'package:url_strategy/url_strategy.dart';

// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('kr', null);
  setPathUrlStrategy();
  // Firebase를 초기화합니다. Firebase를 사용하려면 앱 실행 전에 반드시 초기화해야 합니다.
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // 플랫폼에 따라 설정된 Firebase 옵션 사용
  );
  await FirebaseFirestore.instance.clearPersistence();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '마이스플랜 MICE PLAN',
      scrollBehavior:
          CustomScrollBehavior(), // ✅ Apply global scroll behavior here
      // 앱의 테마를 설정합니다.
      theme: AppTheme.mpTheme,
      debugShowCheckedModeBanner: false,

      routerConfig: router,
    );
  }
}
