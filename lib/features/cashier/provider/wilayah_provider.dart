import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bk_pos/features/cashier/data/wilayah_repository.dart';
import 'package:bk_pos/model/wilayah_model.dart';

enum WilayahLevel {
  provinsi,
  kabupaten,
  kecamatan,
  desa,
  selesai,
}

class WilayahState {
  final List<WilayahModel> results;

  final WilayahModel? selectedProvinsi;
  final WilayahModel? selectedKabupaten;
  final WilayahModel? selectedKecamatan;
  final WilayahModel? selectedDesa;

  final bool loading;

  const WilayahState({
    this.results = const [],
    this.selectedProvinsi,
    this.selectedKabupaten,
    this.selectedKecamatan,
    this.selectedDesa,
    this.loading = false,
  });

  WilayahLevel get level {
    if (selectedProvinsi == null) {
      return WilayahLevel.provinsi;
    }

    if (selectedKabupaten == null) {
      return WilayahLevel.kabupaten;
    }

    if (selectedKecamatan == null) {
      return WilayahLevel.kecamatan;
    }

    if (selectedDesa == null) {
      return WilayahLevel.desa;
    }

    return WilayahLevel.selesai;
  }

  String get hierarchyLabel {
    final values = <String>[];

    if (selectedProvinsi != null) {
      values.add(selectedProvinsi!.nama);
    }

    if (selectedKabupaten != null) {
      values.add(selectedKabupaten!.nama);
    }

    if (selectedKecamatan != null) {
      values.add(selectedKecamatan!.nama);
    }

    if (selectedDesa != null) {
      values.add(selectedDesa!.nama);
    }

    if (values.isEmpty) {
      return 'Pilih Wilayah';
    }

    return values.join(' - ');
  }

  String get searchHint {
    switch (level) {
      case WilayahLevel.provinsi:
        return 'Cari Provinsi...';

      case WilayahLevel.kabupaten:
        return 'Cari Kabupaten / Kota...';

      case WilayahLevel.kecamatan:
        return 'Cari Kecamatan...';

      case WilayahLevel.desa:
        return 'Cari Desa / Kelurahan...';

      case WilayahLevel.selesai:
        return 'Wilayah Sudah Lengkap';
    }
  }

  bool get canSearch {
    return level != WilayahLevel.selesai;
  }

  WilayahState copyWith({
    List<WilayahModel>? results,
    Object? selectedProvinsi = _unset,
    Object? selectedKabupaten = _unset,
    Object? selectedKecamatan = _unset,
    Object? selectedDesa = _unset,
    bool? loading,
  }) {
    return WilayahState(
      results: results ?? this.results,

      selectedProvinsi: selectedProvinsi == _unset
          ? this.selectedProvinsi
          : selectedProvinsi as WilayahModel?,

      selectedKabupaten: selectedKabupaten == _unset
          ? this.selectedKabupaten
          : selectedKabupaten as WilayahModel?,

      selectedKecamatan: selectedKecamatan == _unset
          ? this.selectedKecamatan
          : selectedKecamatan as WilayahModel?,

      selectedDesa: selectedDesa == _unset
          ? this.selectedDesa
          : selectedDesa as WilayahModel?,

      loading: loading ?? this.loading,
    );
  }
}

const _unset = Object();

class WilayahNotifier extends StateNotifier<WilayahState> {
  final WilayahRepository repository;

  WilayahNotifier(this.repository) : super(const WilayahState());

  Future<void> search(String keyword) async {
    final search = keyword.trim();

    if (search.length < 3) {
      state = state.copyWith(
        results: [],
        loading: false,
      );
      return;
    }

    if (!state.canSearch) {
      return;
    }

    state = state.copyWith(
      loading: true,
      results: [],
    );

    try {
      List<WilayahModel> result;

      switch (state.level) {
        case WilayahLevel.provinsi:
          result = await repository.searchProvinsi(search);
          break;

        case WilayahLevel.kabupaten:
          result = await repository.searchKabupaten(
            provinsiId: state.selectedProvinsi!.id,
            search: search,
          );
          break;

        case WilayahLevel.kecamatan:
          result = await repository.searchKecamatan(
            kabupatenId: state.selectedKabupaten!.id,
            search: search,
          );
          break;

        case WilayahLevel.desa:
          result = await repository.searchDesa(
            kecamatanId: state.selectedKecamatan!.id,
            search: search,
          );
          break;

        case WilayahLevel.selesai:
          result = [];
          break;
      }

      state = state.copyWith(
        results: result,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        results: [],
        loading: false,
      );
    }
  }

  void select(WilayahModel value) {
    switch (state.level) {
      case WilayahLevel.provinsi:
        state = state.copyWith(
          selectedProvinsi: value,
          selectedKabupaten: null,
          selectedKecamatan: null,
          selectedDesa: null,
          results: [],
        );
        break;

      case WilayahLevel.kabupaten:
        state = state.copyWith(
          selectedKabupaten: value,
          selectedKecamatan: null,
          selectedDesa: null,
          results: [],
        );
        break;

      case WilayahLevel.kecamatan:
        state = state.copyWith(
          selectedKecamatan: value,
          selectedDesa: null,
          results: [],
        );
        break;

      case WilayahLevel.desa:
        state = state.copyWith(
          selectedDesa: value,
          results: [],
        );
        break;

      case WilayahLevel.selesai:
        break;
    }
  }

  void clear() {
    state = const WilayahState();
  }

  void clearLast() {
    if (state.selectedDesa != null) {
      state = state.copyWith(
        selectedDesa: null,
        results: [],
      );
      return;
    }

    if (state.selectedKecamatan != null) {
      state = state.copyWith(
        selectedKecamatan: null,
        selectedDesa: null,
        results: [],
      );
      return;
    }

    if (state.selectedKabupaten != null) {
      state = state.copyWith(
        selectedKabupaten: null,
        selectedKecamatan: null,
        selectedDesa: null,
        results: [],
      );
      return;
    }

    if (state.selectedProvinsi != null) {
      state = const WilayahState();
    }
  }
}

final wilayahRepositoryProvider = Provider<WilayahRepository>(
  (ref) => WilayahRepository(),
);

final wilayahProvider =
    StateNotifierProvider<WilayahNotifier, WilayahState>((ref) {
  return WilayahNotifier(
    ref.read(wilayahRepositoryProvider),
  );
});

 