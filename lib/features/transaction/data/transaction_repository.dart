import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../model/transaction_detail_model.dart';
import '../../../model/transaction_model.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final res = await DioClient.dio.get(
        "/transactions",
        queryParameters: {
          if (startDate != null) "start_date": _formatDate(startDate),

          if (endDate != null) "end_date": _formatDate(endDate),
        },
      );

      final List data = res.data["data"] as List;

      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal mengambil transaksi",
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<TransactionDetailModel> getTransactionDetail(int id) async {
    try {
      final res = await DioClient.dio.get("/transactions/$id");

      return TransactionDetailModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal mengambil detail transaksi",
      );
    }
  }

  Future<void> addProductToTransaction({
    required int transactionId,
    required int productId,
    required int quantity,
  }) async {
    try {
      await DioClient.dio.post(
        '/transactions/$transactionId/items',
        data: {'product_id': productId, 'quantity': quantity},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menambahkan barang ke transaksi',
      );
    }
  }

  Future<void> addPayment({
    required int transactionId,
    required String paymentMethod,
    required double amount,
    String? driverName,
    String? deliveryType,
    double? shippingCost,
    String? notes,
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
          "notes": notes,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal menambah pembayaran",
      );
    }
  }

  Future<void> updateDriver({
    required int transactionId,
    required String driverName,
  }) async {
    try {
      await DioClient.dio.patch(
        "/transactions/$transactionId/driver",
        data: {"driver_name": driverName},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Gagal mengupdate driver");
    }
  }

  Future<void> updateNotes({
    required int transactionId,
    required String notes,
  }) async {
    try {
      await DioClient.dio.patch(
        "/transactions/$transactionId/notes",
        data: {"notes": notes},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Gagal mengupdate catatan",
      );
    }
  }
}
 