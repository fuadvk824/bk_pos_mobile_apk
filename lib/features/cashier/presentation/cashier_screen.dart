import 'package:bk_pos/features/cashier/presentation/checkout_screen.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/cashier/provider/checkout_provider.dart';
import 'package:bk_pos/model/cart_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

// class _CashierScreenState extends ConsumerState<CashierScreen> {
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
class _CashierScreenState extends ConsumerState<CashierScreen> {
  final Map<int, TextEditingController> priceControllers = {};

  TextEditingController controllerFor(CartItemModel item) {
    return priceControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: item.sellingPrice.toInt().toString()),
    );
  }

  @override
  void dispose() {
    for (final c in priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Cashier")),
      body: Column(
        children: [
          Container(height: 1, color: Colors.grey.shade300),

          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Belum ada produk'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      //tambahan
                      final controller = controllerFor(item);
                      // sinkronkan jika state berubah
                      final value = item.sellingPrice.toInt().toString();
                      if (controller.text != value) {
                        controller.text = value;
                      }
                      //tambahan

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: item.product.stock <= 5
                                      ? Colors.orange.shade100
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Stok: ${item.product.stock}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: item.product.stock <= 5
                                            ? Colors.orange.shade900
                                            : Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (item.product.discount > 0) ...[
                                Text(
                                  "Rp ${item.product.price.toInt()}",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Diskon : Rp ${item.product.finalPrice.toInt()}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else
                                Text("Rp ${item.product.price.toInt()}"),

                              const SizedBox(height: 10),
                             
                              TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Harga Jual",
                                  suffix: TextButton(
                                    onPressed: () {
                                      cartNotifier.resetPrice(item.product.id);
                                    },
                                    child: const Text("Reset"),
                                  ),
                                ),
                                onChanged: (v) {
                                  final value = double.tryParse(v);
                                  if (value != null) {
                                    cartNotifier.updatePrice(
                                      item.product.id,
                                      value,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              if (item.stockError)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Jumlah melebihi stok (${item.product.stock})",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),

                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      cartNotifier.updateQty(
                                        item.product.id,
                                        item.qty - 1,
                                      );
                                    },
                                  ),

                                  Text(item.qty.toString()),

                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cartNotifier.updateQty(
                                        item.product.id,
                                        item.qty + 1,
                                      );
                                    },
                                  ),

                                  const Spacer(),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      cartNotifier.remove(item.product.id);
                                    },
                                  ),
                                ],
                              ),

                              Text(
                                "Subtotal : Rp ${item.subtotal.toInt()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // TOTAL
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Subtotal"),
                        const Spacer(),
                        Text("Rp ${cart.subtotal.toInt()}"),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text("TOTAL"),
                        const Spacer(),
                        Text(
                          "Rp ${checkoutNotifier.total.toInt()}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cart.items.isEmpty || cart.hasStockError
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                        child: const Text("Proses Checkout"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
