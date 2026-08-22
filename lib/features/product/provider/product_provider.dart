import 'package:bk_pos/model/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(),
);

enum ProductFilter { all, lowStock, discount, bestSeller, backorder }

class ProductState {
  final List<ProductModel> allProducts;
  final List<ProductModel> products;

  final ProductFilter selectedFilter;
  final String search;

  final bool isLoading;

  const ProductState({
    this.allProducts = const [],
    this.products = const [],
    this.selectedFilter = ProductFilter.all,
    this.search = '',
    this.isLoading = false,
  });

  ProductState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? products,
    ProductFilter? selectedFilter,
    String? search,
    bool? isLoading,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository repo;

  ProductNotifier(this.repo) : super(const ProductState()) {
    loadProducts();
  }

  // Future<void> loadProducts() async {
  //   state = state.copyWith(isLoading: true);
  //   final products = await repo.getProducts();
  //   state = state.copyWith(isLoading: false, allProducts: products);

  //   _applyFilter();
  // }
  Future<void> loadProducts() async {
    // Backorder tidak mengambil seluruh produk
    if (state.selectedFilter == ProductFilter.backorder) {
      state = state.copyWith(isLoading: false, products: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final products = await repo.getProducts();

      state = state.copyWith(isLoading: false, allProducts: products);

      _applyFilter();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Future<ProductModel?> findByQr(String qr) {
  //   return repo.getProductByQr(qr);
  // }
  Future<ProductModel?> findByQr(String qr) {
    final isBackorder = state.selectedFilter == ProductFilter.backorder;

    return repo.getProductByQr(qr, backorder: isBackorder);
  }

  // void setFilter(ProductFilter filter) {
  //   state = state.copyWith(selectedFilter: filter);
  //   _applyFilter();
  // }
  void setFilter(ProductFilter filter) {
    state = state.copyWith(selectedFilter: filter, search: '');

    // Backorder tidak boleh menampilkan semua produk
    if (filter == ProductFilter.backorder) {
      state = state.copyWith(products: []);
      return;
    }

    _applyFilter();
  }

  // void searchProduct(String keyword) {
  //   state = state.copyWith(search: keyword);
  //   _applyFilter();
  // }
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

  // void _applyFilter() {
  //   List<ProductModel> result = List.from(state.allProducts);

  //   /// Filter
  //   switch (state.selectedFilter) {
  //     case ProductFilter.all:
  //       break;

  //     case ProductFilter.lowStock:
  //       result = result.where((e) => e.stock <= 5).toList();
  //       break;

  //     case ProductFilter.discount:
  //       result = result.where((e) => e.discount > 0).toList();
  //       break;

  //     case ProductFilter.bestSeller:
  //       result = result.where((e) => e.sold > 0).toList();
  //       result.sort((a, b) => b.sold.compareTo(a.sold));

  //       result = result.take(5).toList();
  //       break;
  //   }

  //   /// Search
  //   if (state.search.trim().isNotEmpty) {
  //     final keyword = state.search.toLowerCase();

  //     result = result.where((e) {
  //       return e.name.toLowerCase().contains(keyword) ||
  //           e.productCode.toLowerCase().contains(keyword);
  //     }).toList();
  //   }

  //   state = state.copyWith(products: result);
  // }
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
        // Backorder tidak menggunakan allProducts.
        // Produk hanya muncul melalui search atau scan QR.
        result = [];
        break;
    }

    /// Search hanya untuk produk normal.
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
// import 'package:bk_pos/model/product_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../data/product_repository.dart';

// final productRepositoryProvider = Provider<ProductRepository>(
//   (ref) => ProductRepository(),
// );

// enum ProductFilter { all, lowStock, discount, bestSeller }

// class ProductState {
//   final List<ProductModel> allProducts;
//   final List<ProductModel> products;

//   final ProductFilter selectedFilter;
//   final String search;

//   final bool isLoading;

//   const ProductState({
//     this.allProducts = const [],
//     this.products = const [],
//     this.selectedFilter = ProductFilter.all,
//     this.search = '',
//     this.isLoading = false,
//   });

//   ProductState copyWith({
//     List<ProductModel>? allProducts,
//     List<ProductModel>? products,
//     ProductFilter? selectedFilter,
//     String? search,
//     bool? isLoading,
//   }) {
//     return ProductState(
//       allProducts: allProducts ?? this.allProducts,
//       products: products ?? this.products,
//       selectedFilter: selectedFilter ?? this.selectedFilter,
//       search: search ?? this.search,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class ProductNotifier extends StateNotifier<ProductState> {
//   final ProductRepository repo;

//   ProductNotifier(this.repo) : super(const ProductState()) {
//     loadProducts();
//   }

//   Future<void> loadProducts() async {
//     state = state.copyWith(isLoading: true);
//     final products = await repo.getProducts();
//     state = state.copyWith(isLoading: false, allProducts: products);

//     _applyFilter();
//   }

//   Future<ProductModel?> findByQr(String qr) {
//     return repo.getProductByQr(qr);
//   }

//   void setFilter(ProductFilter filter) {
//     state = state.copyWith(selectedFilter: filter);
//     _applyFilter();
//   }

//   void searchProduct(String keyword) {
//     state = state.copyWith(search: keyword);
//     _applyFilter();
//   }

//   void _applyFilter() {
//     List<ProductModel> result = List.from(state.allProducts);

//     /// Filter
//     switch (state.selectedFilter) {
//       case ProductFilter.all:
//         break;

//       case ProductFilter.lowStock:
//         result = result.where((e) => e.stock <= 5).toList();
//         break;

//       case ProductFilter.discount:
//         result = result.where((e) => e.discount > 0).toList();
//         break;

//       case ProductFilter.bestSeller:
//         result = result.where((e) => e.sold > 0).toList();
//         result.sort((a, b) => b.sold.compareTo(a.sold));

//         result = result.take(5).toList();
//         break;
//     }

//     /// Search
//     if (state.search.trim().isNotEmpty) {
//       final keyword = state.search.toLowerCase();

//       result = result.where((e) {
//         return e.name.toLowerCase().contains(keyword) ||
//             e.productCode.toLowerCase().contains(keyword);
//       }).toList();
//     }

//     state = state.copyWith(products: result);
//   }
// }

// final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
//   (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
// );
