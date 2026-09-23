import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/app_version_model.dart';
import 'package:dio/dio.dart';

class VersionRepository {
  Future<AppVersionModel> checkVersion() async {
    final response = await DioClient.dio.get(
      '/app-version',
      queryParameters: {
        '_': DateTime.now().millisecondsSinceEpoch,
      },
      options: Options(
        headers: {
          'Cache-Control': 'no-cache, no-store, max-age=0',
          'Pragma': 'no-cache',
        },
      ),
    );

    return AppVersionModel.fromJson(
      response.data,
    );
  }
}