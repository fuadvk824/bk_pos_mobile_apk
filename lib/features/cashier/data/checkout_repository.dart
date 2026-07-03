import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../model/customer_model.dart';

class CheckoutRepository {
  Future<void> submitTransaction(Map<String, dynamic> payload) async {
    try {
      await DioClient.dio.post("/checkout", data: payload);
    } on DioException catch (e) {
      final msg = e.response?.data["message"] ?? "Gagal menyimpan transaksi";

      throw Exception(msg);
    }
  }

  Future<List<CustomerModel>> searchCustomer(String keyword) async {
    try {
      final response = await DioClient.dio.get(
        "/customers/search",
        queryParameters: {"search": keyword},
      );

      return (response.data as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Gagal mencari customer");
    }
  }
}
