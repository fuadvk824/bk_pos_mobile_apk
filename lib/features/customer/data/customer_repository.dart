import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/customer_model.dart';

class CustomerPage {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final bool hasMorePages;

  CustomerPage({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    required this.hasMorePages,
  });
}

class CustomerRepository {
  Future<CustomerPage> getCustomers({String search = '', int page = 1}) async {
    final res = await DioClient.dio.get(
      '/customers',
      queryParameters: {'search': search, 'page': page},
    );

    final List data = res.data['data'];
    final meta = res.data['meta'];

    return CustomerPage(
      customers: data.map((e) => CustomerModel.fromJson(e)).toList(),
      currentPage: meta['current_page'],
      lastPage: meta['last_page'],
      hasMorePages: meta['current_page'] < meta['last_page'],
    );
  }
}
 