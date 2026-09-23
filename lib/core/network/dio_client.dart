import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_manager.dart';

class DioClient {
  static late final Dio dio;

  static void init() {
    final baseUrl = dotenv.env['BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('BASE_URL tidak tersedia');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isLoginRequest = options.path == '/login';

          if (!isLoginRequest && TokenManager.isExpired) {
            await TokenManager.clear();

            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
                error: 'SESSION_EXPIRED',
              ),
            );
          }

          final token = TokenManager.token;

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            await TokenManager.clear();
          }

          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}
 