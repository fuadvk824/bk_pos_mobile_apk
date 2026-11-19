import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/product_model.dart';
import 'package:dio/dio.dart';

class ProductPage {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final bool hasMorePages;

  ProductPage({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.hasMorePages,
  });
}

class ProductRepository {
  Future<ProductPage> getProducts({
    int page = 1,
    String search = '',
    String? filter,
  }) async {
    final Map<String, dynamic> params = {'page': page, 'search': search};

    if (filter != null) {
      params['filter'] = filter;
    }

    final res = await DioClient.dio.get('/products', queryParameters: params);
    final List data = res.data['data'];
    final pagination = res.data['pagination'];

    return ProductPage(
      products: data.map((e) => ProductModel.fromJson(e)).toList(),
      currentPage: pagination['current_page'],
      lastPage: pagination['last_page'],
      hasMorePages: pagination['has_more_pages'],
    );
  }

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
