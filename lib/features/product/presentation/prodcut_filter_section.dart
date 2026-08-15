import 'package:bk_pos/features/cashier/presentation/cashier_screen.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/product/provider/product_provider.dart';
import 'package:bk_pos/features/profile/provider/profile_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductFilterSection extends ConsumerWidget {
  const ProductFilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    final cart = ref.watch(cartProvider);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      onChanged: notifier.searchProduct,
                      decoration: InputDecoration(
                        hintText: "Cari Produkmuu...",
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.dark,
                        ),
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: "Refresh",
                  onPressed: () async {
                    await Future.wait([
                      notifier.loadProducts(),
                      ref.read(profileProvider.notifier).refresh(),
                    ]);
                  },
                  icon: const Icon(Icons.refresh),
                ),

                Badge(
                  isLabelVisible: cart.items.isNotEmpty,
                  label: Text(
                    '${cart.items.length}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  alignment: Alignment.topRight,
                  offset: const Offset(-2, 2), 
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CashierScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ProductFilter.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = ProductFilter.values[index];

                  return ChoiceChip(
                    selected: state.selectedFilter == filter,
                    label: Text(_label(filter)),
                    onSelected: (_) => notifier.setFilter(filter),

                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.transparent,

                    checkmarkColor: AppColors.dark,

                    labelStyle: TextStyle(
                      color: state.selectedFilter == filter
                          ? AppColors.dark
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),

                    side: BorderSide(
                      color: state.selectedFilter == filter
                          ? Colors.transparent
                          : AppColors.primary,
                      width: 1.5,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(ProductFilter filter) {
    switch (filter) {
      case ProductFilter.all:
        return "All Stock";
      case ProductFilter.lowStock:
        return "Low Stock";
      case ProductFilter.discount:
        return "Discount";
      case ProductFilter.bestSeller:
        return "Best Seller";
    }
  }
}
