import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> getProducts() async {
    final res = await DioClient.dio.get('/products');
    final List data = res.data['data'];

    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel?> getProductByQr(String qr) async {
    final res = await DioClient.dio.post('/products/scan', data: {'qr': qr});

    if (res.data['success'] != true) {
      return null;
    }

    return ProductModel.fromJson(res.data['data']);
  }
}
