import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/store_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeProvider);
    final notifier = ref.read(storeProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.userInfo?.storeName ?? 'Store'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: notifier.load),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: CustomScrollView(
          slivers: [
            // USER INFO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  child: ListTile(
                    title: Text(state.userInfo?.userName ?? ''),
                    subtitle: Text(
                      "Target: ${state.userInfo?.targetAmount ?? 0}",
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Produk",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.searchProduct,
                ),
              ),
            ),

            // FILTER HORIZONTAL
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: ProductFilter.values.map((filter) {
                    final isSelected = state.selectedFilter == filter;

                    String label;
                    switch (filter) {
                      case ProductFilter.all:
                        label = "All";
                        break;
                      case ProductFilter.lowStock:
                        label = "Low Stock";
                        break;
                      case ProductFilter.discount:
                        label = "Discount";
                        break;
                      case ProductFilter.bestSeller:
                        label = "Best Seller";
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => notifier.setFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // PRODUCT GRID
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = state.products[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, size: 40),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p.category ?? '-',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Stock: ${p.stock}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Rp ${p.price}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref.read(cartProvider.notifier).add(p);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${p.name} ditambahkan"),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add_shopping_cart),
                              label: Text("Add"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: state.products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
