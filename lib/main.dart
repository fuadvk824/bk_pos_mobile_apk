import 'package:bk_pos/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  await CacheService.init(); 
  await TokenManager.init();

  DioClient.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BK POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
    );
  }
}
 
//24 juni 2026
//1. perbaiki keyStatus  di app_router.dart

