import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_manager.dart';
import '../../../model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String login, String password) async {
    try {
      final res = await DioClient.dio.post(
        '/login',
        data: {'login': login, 'password': password},
      );
      
      final data = res.data;
      if (data is! Map) {
        throw Exception('Response server tidak valid');
      }

      final token = data['token'];
      if (token == null || token.toString().isEmpty) {
        throw Exception('Token login tidak ditemukan');
      }

      await TokenManager.set(token.toString());

      final user = await me();
      if (user == null) {
        throw Exception('Data user tidak ditemukan dari server');
      }

      return user;
    } on DioException catch (e) {
      String message = 'Login gagall';

      final responseData = e.response?.data;

      if (responseData is Map && responseData['message'] != null) {
        message = responseData['message'].toString();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        message = 'Koneksi ke server timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Tidak dapat terhubung ke server';
      } else if (e.response?.statusCode == 500) {
        message = 'Terjadi error pada server';
      } else if (e.response?.statusCode == 502) {
        message = 'Server login eksternal sedang bermasalah';
      }

      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<UserModel?> me() async {
    final res = await DioClient.dio.get('/users');
    return UserModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<void> logout() async {
    try {
      await DioClient.dio.post('/logout');
    } catch (_) {}

    await TokenManager.clear();
  }
}
