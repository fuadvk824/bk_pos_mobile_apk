
import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/app_version_model.dart';

class VersionRepository {
  Future<AppVersionModel> checkVersion() async {
    final res = await DioClient.dio.get(
      '/app-version',
    );

    return AppVersionModel.fromJson(
      res.data,
    );
  }
}
