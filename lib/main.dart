import 'package:bk_pos/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/token_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool envReady = false;

  try {
    await dotenv.load(fileName: '.env');
    final baseUrl = dotenv.env['BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('BASE_URL tidak ditemukan di .env');
    }

    envReady = true;

    debugPrint('ENV: OK');
    debugPrint('BASE_URL: $baseUrl');
  } catch (e, stackTrace) {
    debugPrint('ENV ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await CacheService.init();
    debugPrint('CACHE: OK');
  } catch (e, stackTrace) {
    debugPrint('CACHE ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await TokenManager.init();
    debugPrint('TOKEN: OK');
  } catch (e, stackTrace) {
    debugPrint('TOKEN ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  if (envReady) {
    try {
      DioClient.init();
      debugPrint('DIO: OK');
    } catch (e, stackTrace) {
      debugPrint('DIO ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  } else {
    debugPrint('DIO: SKIPPED because ENV is not ready');
  }

  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'BK POS',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const AppRouter(),
      ),
    );
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await initializeDateFormatting('id_ID', null);
//   await dotenv.load(fileName: ".env");
//   await CacheService.init();
//   await TokenManager.init();

//   DioClient.init();
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ToastificationWrapper(
//       child: MaterialApp(
//         title: 'BK POS',
//         theme: ThemeData(primarySwatch: Colors.blue),
//         debugShowCheckedModeBanner: false,
//         home: const AppRouter(),
//       ),
//     );
//   }
// }