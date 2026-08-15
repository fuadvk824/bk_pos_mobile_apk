import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/customer_model.dart';

class CustomerRepository {
  Future<List<CustomerModel>> getCustomers({
    String search = '',
  }) async {
    final res = await DioClient.dio.get(
      '/customers',
      queryParameters: {
        'search': search,
      },
    );

    final List data = res.data['data'];

    return data
        .map((e) => CustomerModel.fromJson(e))
        .toList();
  }
}