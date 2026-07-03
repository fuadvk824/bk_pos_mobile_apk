
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../model/transaction_detail_model.dart';
import '../../../model/transaction_model.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getTransactions() async {
    final res = await DioClient.dio.get('/transactions');
    final List data = res.data['data'];

    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionDetailModel> getTransactionDetail(int id) async {
    final res = await DioClient.dio.get('/transactions/$id');

    return TransactionDetailModel.fromJson(res.data['data']);
  }

  Future<void> addPayment({
    required int transactionId,
    required String paymentMethod,
    required double amount,

    String? driverName,
    String? deliveryType,
    double? shippingCost,
  }) async {
    try {
      await DioClient.dio.post(
        "/transactions/$transactionId/payment",
        data: {
          "driver_name": driverName,
          "delivery_type": deliveryType,
          "shipping_cost": shippingCost,
          "payment_method": paymentMethod,
          "amount": amount,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal menambah pembayaran",
      );
    }
  }
}
