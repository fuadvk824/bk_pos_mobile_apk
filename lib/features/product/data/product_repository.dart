import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:dio/dio.dart';

class ProductRepository {
  Future<List<ProductModel>> getProducts() async {
    final res = await DioClient.dio.get('/products');
    final List data = res.data['data'];

    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  // Future<ProductModel?> getProductByQr(String qr) async {
  //   final res = await DioClient.dio.post('/products/scan', data: {'qr': qr});

  //   if (res.data['success'] != true) {
  //     return null;
  //   }

  //   return ProductModel.fromJson(res.data['data']);
  // }

  Future<ProductModel?> getProductByQr(
    String qr, {
    bool backorder = false,
  }) async {
    final res = await DioClient.dio.post(
      '/products/scan',
      data: {'qr': qr, 'backorder': backorder},
    );

    if (res.data['success'] != true) {
      return null;
    }

    return ProductModel.fromJson(res.data['data']);
  }

  Future<List<ProductModel>> searchBackorder(String keyword) async {
    try {
      final response = await DioClient.dio.get(
        '/products/backorder-search',
        queryParameters: {'search': keyword},
      );

      final List data = response.data['data'];

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal mencari produk backorder',
      );
    }
  }
}
// import 'package:bk_pos/core/network/dio_client.dart';
// import 'package:bk_pos/model/product_model.dart';
// import 'package:dio/dio.dart';

// class ProductRepository {
//   Future<List<ProductModel>> getProducts() async {
//     final res = await DioClient.dio.get('/products');
//     final List data = res.data['data'];

//     return data.map((e) => ProductModel.fromJson(e)).toList();
//   }

//   Future<ProductModel?> getProductByQr(String qr) async {
//     final res = await DioClient.dio.post('/products/scan', data: {'qr': qr});

//     if (res.data['success'] != true) {
//       return null;
//     }

//     return ProductModel.fromJson(res.data['data']);
//   }

// }
