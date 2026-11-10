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

  ProductNotifier(this.repo) : super(const ProductState()) {
    loadProducts();
  }

  // Future<void> loadProducts() async {
  //   if (state.selectedFilter == ProductFilter.backorder) {
  //     state = state.copyWith(isLoading: false, products: []);
  //     return;
  //   }

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     final products = await repo.getProducts();

  //     state = state.copyWith(isLoading: false, allProducts: products);

  //     _applyFilter();
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false);
  //     rethrow;
  //   }
  // }

  Future<void> loadProducts() async {
    if (state.isLoading || state.isLoadingMore) return;

    if (state.selectedFilter == ProductFilter.backorder) {
      state = state.copyWith(isLoading: false, products: []);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      currentPage: 0,
      hasMore: true,
      allProducts: [],
      products: [],
    );

    try {
      final result = await repo.getProducts(page: 1);

      state = state.copyWith(
        isLoading: false,
        allProducts: result.products,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
      );

      _applyFilter();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.selectedFilter == ProductFilter.backorder) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;

      final result = await repo.getProducts(page: nextPage);

      final updatedProducts = [...state.allProducts, ...result.products];

      state = state.copyWith(
        allProducts: updatedProducts,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
        isLoadingMore: false,
      );

      _applyFilter();
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<ProductModel?> findByQr(String qr) {
    final isBackorder = state.selectedFilter == ProductFilter.backorder;

    return repo.getProductByQr(qr, backorder: isBackorder);
  }

  void setFilter(ProductFilter filter) {
    state = state.copyWith(selectedFilter: filter, search: '');

    if (filter == ProductFilter.backorder) {
      state = state.copyWith(products: []);
      return;
    }

    _applyFilter();
  }

  Future<void> searchProduct(String keyword) async {
    state = state.copyWith(search: keyword);

    // BACKORDER
    if (state.selectedFilter == ProductFilter.backorder) {
      if (keyword.trim().isEmpty) {
        state = state.copyWith(products: []);
        return;
      }

      state = state.copyWith(isLoading: true);

      try {
        final products = await repo.searchBackorder(keyword.trim());

        state = state.copyWith(products: products, isLoading: false);
      } catch (e) {
        state = state.copyWith(products: [], isLoading: false);
      }

      return;
    }

    // NORMAL
    _applyFilter();
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
        result = result.take(5).toList();
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
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
);
