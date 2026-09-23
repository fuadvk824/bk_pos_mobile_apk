import 'package:bk_pos/core/network/dio_client.dart';
import 'package:bk_pos/model/wilayah_model.dart';

class WilayahRepository {
  Future<List<WilayahModel>> searchProvinsi(String search) async {
    final response = await DioClient.dio.get(
      '/wilayah/provinsi',
      queryParameters: {'search': search},
    );

    return (response.data as List)
        .map((e) => WilayahModel.fromJson(e))
        .toList();
  }

  Future<List<WilayahModel>> searchKabupaten({
    required int provinsiId,
    required String search,
  }) async {
    final response = await DioClient.dio.get(
      '/wilayah/kabupaten',
      queryParameters: {
        'provinsi_id': provinsiId,
        'search': search,
      },
    );

    return (response.data as List)
        .map((e) => WilayahModel.fromJson(e))
        .toList();
  }

  Future<List<WilayahModel>> searchKecamatan({
    required int kabupatenId,
    required String search,
  }) async {
    final response = await DioClient.dio.get(
      '/wilayah/kecamatan',
      queryParameters: {
        'kabupaten_id': kabupatenId,
        'search': search,
      },
    );

    return (response.data as List)
        .map((e) => WilayahModel.fromJson(e))
        .toList();
  }

  Future<List<WilayahModel>> searchDesa({
    required int kecamatanId,
    required String search,
  }) async {
    final response = await DioClient.dio.get(
      '/wilayah/desa',
      queryParameters: {
        'kecamatan_id': kecamatanId,
        'search': search,
      },
    );

    return (response.data as List)
        .map((e) => WilayahModel.fromJson(e))
        .toList();
  }
}

 