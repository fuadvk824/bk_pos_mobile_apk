import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/model/user_model.dart';
import '../../../core/network/dio_client.dart';

class StoreRepository {
  Future<UserModel> getUserInfo() async {
    final res = await DioClient.dio.get('/users');
    return UserModel.fromJson(res.data['data']);
  }

  Future<List<ProductModel>> getProducts() async {
    final res = await DioClient.dio.get('/products');

    final List data = res.data['data'];

    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}