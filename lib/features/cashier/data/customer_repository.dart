import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/customer_model.dart';

class CustomerRepository {
  Future<List<CustomerModel>> searchCustomer(String keyword) async {
    final response = await DioClient.dio.get(
      "/customers/search",
      queryParameters: {"search": keyword},
    );

    return (response.data as List)
        .map((e) => CustomerModel.fromJson(e))
        .toList();
  }
}  