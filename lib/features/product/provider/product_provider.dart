import 'dart:async';

import 'package:bk_pos/model/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(),
);

enum ProductFilter { all, backorder, lowStock, discount, bestSeller }

class ProductState {
  final List<ProductModel> allProducts;
  final List<ProductModel> products;

  final ProductFilter selectedFilter;
  final String search;

  final bool isLoading;

  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductState({
    this.allProducts = const [],
    this.products = const [],
    this.selectedFilter = ProductFilter.all,
    this.search = '',
    this.isLoading = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProductState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? products,
    ProductFilter? selectedFilter,
    String? search,
    bool? isLoading,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository repo;
  Timer? _searchDebounce;
  int _requestId = 0;

  ProductNotifier(this.repo) : super(const ProductState()) {
    loadProducts();
  }

  Future<void> loadProducts({String search = ''}) async {
    _searchDebounce?.cancel();

    final requestId = ++_requestId;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      currentPage: 0,
      hasMore: true,
      allProducts: [],
      products: [],
      search: search,
    );

    try {
      final result = await repo.getProducts(
        page: 1,
        search: search,
        filter: _getApiFilter(),
      );

      if (requestId != _requestId) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        allProducts: result.products,
        products: result.products,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
      );

      if (state.selectedFilter != ProductFilter.all) {
        _applyFilter();
      }
    } catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(isLoading: false, isLoadingMore: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.selectedFilter == ProductFilter.backorder) {
      return;
    }

    final requestId = _requestId;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;

      final result = await repo.getProducts(
        page: nextPage,
        search: state.selectedFilter == ProductFilter.all
            ? state.search.trim()
            : '',
        filter: _getApiFilter(),
      );

      // Request sudah tidak berlaku jika pengguna pindah filter
      if (requestId != _requestId) return;

      final updatedProducts = [...state.allProducts, ...result.products];

      state = state.copyWith(
        allProducts: updatedProducts,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
        isLoadingMore: false,
      );

      if (state.selectedFilter == ProductFilter.all) {
        state = state.copyWith(products: updatedProducts);
      } else {
        _applyFilter();
      }
    } catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setFilter(ProductFilter filter) {
    _searchDebounce?.cancel();

    // Batalkan request sebelumnya
    ++_requestId;

    // Bersihkan data dan status loading sebelumnya
    state = state.copyWith(
      selectedFilter: filter,
      search: '',
      allProducts: [],
      products: [],
      currentPage: 0,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
    );

    // Backorder tidak mengambil data sebelum pencarian
    if (filter == ProductFilter.backorder) {
      return;
    }

    // Ambil ulang halaman pertama untuk filter yang dipilih
    loadProducts();
  }

  Future<void> searchProduct(String keyword) async {
    state = state.copyWith(search: keyword);

    // BACKORDER: tetap menggunakan API khusus
    // BACKORDER: pencarian API dengan minimal 3 karakter dan debounce
    if (state.selectedFilter == ProductFilter.backorder) {
      _searchDebounce?.cancel();

      // Batalkan request pencarian sebelumnya
      ++_requestId;

      final searchKeyword = keyword.trim();

      // Kurang dari 3 karakter
      if (searchKeyword.length < 3) {
        state = state.copyWith(products: [], isLoading: false);
        return;
      }

      // Minimal 3 karakter: tunggu 400 ms
      final requestId = _requestId;

      _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
        if (requestId != _requestId) return;

        state = state.copyWith(isLoading: true);

        try {
          final products = await repo.searchBackorder(searchKeyword);

          if (requestId != _requestId) return;

          state = state.copyWith(products: products, isLoading: false);
        } catch (e) {
          if (requestId != _requestId) return;

          state = state.copyWith(products: [], isLoading: false);
        }
      });

      return;
    }

    // ALL STOCK: pencarian melalui API Laravel
    if (state.selectedFilter == ProductFilter.all) {
      _searchDebounce?.cancel();

      // Batalkan request sebelumnya
      ++_requestId;

      final searchKeyword = keyword.trim();

      // Jika kurang dari 3 karakter
      if (searchKeyword.length < 3) {
        if (searchKeyword.isEmpty) {
          // Jika search dikosongkan, tampilkan kembali 6 produk awal
          loadProducts();
        } else {
          // Belum melakukan pencarian API
          state = state.copyWith(
            isLoading: false,
            products: [],
            allProducts: [],
            currentPage: 0,
            hasMore: true,
          );
        }
        return;
      }

      // Minimal 3 karakter: tunggu 400 ms
      _searchDebounce = Timer(const Duration(milliseconds: 400), () {
        loadProducts(search: searchKeyword);
      });

      return;
    }

    // FILTER LAIN: tetap pencarian lokal
    _applyFilter();
  }

  String? _getApiFilter() {
    switch (state.selectedFilter) {
      case ProductFilter.lowStock:
        return 'low_stock';

      case ProductFilter.discount:
        return 'discount';

      case ProductFilter.bestSeller:
        return 'best_seller';

      default:
        return null;
    }
  }

  Future<ProductModel?> findByQr(String qr) {
    final isBackorder = state.selectedFilter == ProductFilter.backorder;

    return repo.getProductByQr(qr, backorder: isBackorder);
  }

  void _applyFilter() {
    List<ProductModel> result = List.from(state.allProducts);

    switch (state.selectedFilter) {
      case ProductFilter.all:
        break;

      case ProductFilter.lowStock:
        result = result.where((e) => e.stock <= 5).toList();
        break;

      case ProductFilter.discount:
        result = result.where((e) => e.discount > 0).toList();
        break;

      case ProductFilter.bestSeller:
        result = result.where((e) => e.sold > 0).toList();
        result.sort((a, b) => b.sold.compareTo(a.sold));
        break;

      case ProductFilter.backorder:
        result = [];
        break;
    }

    if (state.selectedFilter != ProductFilter.backorder &&
        state.search.trim().isNotEmpty) {
      final keyword = state.search.toLowerCase();

      result = result.where((e) {
        return e.name.toLowerCase().contains(keyword) ||
            e.productCode.toLowerCase().contains(keyword);
      }).toList();
    }

    state = state.copyWith(products: result);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
);
