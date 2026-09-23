class WilayahModel {
  final int id;
  final String kode;
  final String nama;

  const WilayahModel({
    required this.id,
    required this.kode,
    required this.nama,
  });

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kode: json['kode']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
    );
  }
}