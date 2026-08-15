import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/user_model.dart';

class ProfileRepository {
  Future<UserModel> getUserInfo() async {
    final res = await DioClient.dio.get('/users');

    return UserModel.fromJson(res.data['data']);
  }
}