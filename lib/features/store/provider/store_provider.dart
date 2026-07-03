import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/store_repository.dart';

final storeRepositoryProvider = Provider((ref) => StoreRepository());

enum ProductFilter { all, lowStock, discount, bestSeller }

class StoreState {
  final UserModel? userInfo;
  final List<ProductModel> products;
  final List<ProductModel> allProducts;
  final ProductFilter selectedFilter;
  final bool isLoading;
  final String search;

  StoreState({
    this.userInfo,
    this.products = const [],
    this.allProducts = const [],
    this.selectedFilter = ProductFilter.all,
    this.isLoading = false,

    //tambahan
    this.search = '',
  });

  StoreState copyWith({
    UserModel? userInfo,
    List<ProductModel>? products,
    List<ProductModel>? allProducts,
    ProductFilter? selectedFilter,
    bool? isLoading,

    //tambahan
    String? search,
  }) {
    return StoreState(
      userInfo: userInfo ?? this.userInfo,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,

      //tambahan
      search: search ?? this.search,
    );
  }
}

class StoreNotifier extends StateNotifier<StoreState> {
  final StoreRepository repo;

  StoreNotifier(this.repo) : super(StoreState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final userInfo = await repo.getUserInfo();
    final products = await repo.getProducts();

    state = state.copyWith(
      userInfo: userInfo,
      allProducts: products,
      products: products,
      selectedFilter: ProductFilter.all,
      isLoading: false,
    );
  }

  void setFilter(ProductFilter filter) {
    List<ProductModel> filtered = [];

    switch (filter) {
      case ProductFilter.all:
        filtered = List.from(state.allProducts);
        break;

      case ProductFilter.lowStock:
        filtered = state.allProducts.where((p) => p.stock <= 5).toList();
        break;

      case ProductFilter.discount:
        filtered = state.allProducts.where((p) => p.discount > 0).toList();
        break;

      case ProductFilter.bestSeller:
        filtered = state.allProducts.where((p) => p.sold > 0).toList();
        filtered.sort((a, b) => b.sold.compareTo(a.sold));
        filtered = filtered.take(5).toList();

        break;
    }

    state = state.copyWith(selectedFilter: filter, products: filtered);
  }

  void searchProduct(String keyword) {
    state = state.copyWith(search: keyword);

    if (keyword.trim().isEmpty) {
      setFilter(state.selectedFilter);
      return;
    }

    final filtered = state.allProducts.where((e) {
      return e.name.toLowerCase().contains(keyword.toLowerCase()) ||
          e.productCode.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    state = state.copyWith(products: filtered);
  }
}

final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>(
  (ref) => StoreNotifier(ref.read(storeRepositoryProvider)),
);
