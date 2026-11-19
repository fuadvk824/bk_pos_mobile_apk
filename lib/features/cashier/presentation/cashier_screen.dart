import 'package:bk_pos/features/cashier/presentation/checkout_screen.dart';
import 'package:bk_pos/features/cashier/presentation/widgets/cashier_bottom_total.dart';
import 'package:bk_pos/features/cashier/presentation/widgets/cashier_cart_item.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/model/cart_item_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _packageQtyControllers = {};
  final Map<int, TextEditingController> _packageSizeControllers = {};
  final Map<int, TextEditingController> _packagePriceControllers = {};
  final Map<int, TextEditingController> _retailPriceControllers = {};

  final Map<int, FocusNode> _qtyFocusNodes = {};
  final Map<int, FocusNode> _packageQtyFocusNodes = {};
  final Map<int, FocusNode> _packageSizeFocusNodes = {};
  final Map<int, FocusNode> _packagePriceFocusNodes = {};
  final Map<int, FocusNode> _retailPriceFocusNodes = {};

  @override
  void dispose() {
    for (final controller in _packageSizeControllers.values) {
      controller.dispose();
    }
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }

    for (final controller in _packageQtyControllers.values) {
      controller.dispose();
    }

    for (final controller in _packagePriceControllers.values) {
      controller.dispose();
    }

    for (final controller in _retailPriceControllers.values) {
      controller.dispose();
    }

    for (final node in _packageSizeFocusNodes.values) {
      node.dispose();
    }

    for (final node in _qtyFocusNodes.values) {
      node.dispose();
    }

    for (final node in _packageQtyFocusNodes.values) {
      node.dispose();
    }

    for (final node in _packagePriceFocusNodes.values) {
      node.dispose();
    }

    for (final node in _retailPriceFocusNodes.values) {
      node.dispose();
    }

    super.dispose();
  }

  TextEditingController _qtyController(CartItemModel item) {
    final controller = _qtyControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: item.qty.toString()),
    );

    _syncController(
      controller,
      item.qty.toString(),
      _qtyFocusNode(item.product.id),
    );

    return controller;
  }

  TextEditingController _packageQtyController(CartItemModel item) {
    final controller = _packageQtyControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: item.packageCount.toString()),
    );

    _syncController(
      controller,
      item.packageCount.toString(),
      _packageQtyFocusNode(item.product.id),
    );

    return controller;
  }

  TextEditingController _packageSizeController(CartItemModel item) {
    final value = item.packageSizeValue;

    final controller = _packageSizeControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(text: value > 0 ? value.toString() : ''),
    );

    _syncController(
      controller,
      value > 0 ? value.toString() : '',
      _packageSizeFocusNode(item.product.id),
    );

    return controller;
  }

  TextEditingController _packagePriceController(CartItemModel item) {
    final controller = _packagePriceControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(
        text: formatRupiahInput(item.currentPackagePrice),
      ),
    );

    final value = formatRupiahInput(item.currentPackagePrice);

    _syncController(controller, value, _packagePriceFocusNode(item.product.id));

    return controller;
  }

  TextEditingController _retailPriceController(CartItemModel item) {
    final controller = _retailPriceControllers.putIfAbsent(
      item.product.id,
      () => TextEditingController(
        text: formatRupiahInput(item.currentRetailPrice),
      ),
    );

    final value = formatRupiahInput(item.currentRetailPrice);

    _syncController(controller, value, _retailPriceFocusNode(item.product.id));

    return controller;
  }

  FocusNode _qtyFocusNode(int productId) {
    return _qtyFocusNodes.putIfAbsent(productId, FocusNode.new);
  }

  FocusNode _packageQtyFocusNode(int productId) {
    return _packageQtyFocusNodes.putIfAbsent(productId, FocusNode.new);
  }

  FocusNode _packagePriceFocusNode(int productId) {
    return _packagePriceFocusNodes.putIfAbsent(productId, FocusNode.new);
  }

  FocusNode _packageSizeFocusNode(int productId) {
    return _packageSizeFocusNodes.putIfAbsent(productId, FocusNode.new);
  }

  FocusNode _retailPriceFocusNode(int productId) {
    return _retailPriceFocusNodes.putIfAbsent(productId, FocusNode.new);
  }

  void _syncController(
    TextEditingController controller,
    String value,
    FocusNode focusNode,
  ) {
    if (focusNode.hasFocus) {
      return;
    }

    if (controller.text == value) {
      return;
    }

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _updateQty(CartItemModel item, String value) {
    final qty = int.tryParse(value);

    if (qty == null || qty < 1) {
      return;
    }

    final notifier = ref.read(cartProvider.notifier);

    notifier.updateQty(item.product.id, qty);

    // Kalau menggunakan harga bundle,
    // jumlah bundle harus disesuaikan dengan qty baru.
    if (item.usePackagePricing) {
      final conv2 = item.packageSizeValue;

      if (conv2 > 0) {
        final maxBundle = qty ~/ conv2;
        final currentBundleCount = item.packageCount;

        if (currentBundleCount > maxBundle) {
          notifier.setPackageQty(item.product.id, maxBundle);
        }
      }
    }
  }

  void _increaseQty(CartItemModel item) {
    final newQty = item.qty + 1;

    _updateQty(item, newQty.toString());
  }

  void _decreaseQty(CartItemModel item) {
    if (item.qty <= 1) {
      return;
    }

    final newQty = item.qty - 1;

    _updateQty(item, newQty.toString());
  }

  void _updatePackageQty(CartItemModel item, String value) {
    final packageSize = item.packageSizeValue;

    if (packageSize <= 0) {
      return;
    }

    int packageCount = int.tryParse(value) ?? 0;

    final maxPackageCount = item.qty ~/ packageSize;

    packageCount = packageCount.clamp(0, maxPackageCount).toInt();

    ref
        .read(cartProvider.notifier)
        .setPackageQty(item.product.id, packageCount);

    final controller = _packageQtyControllers[item.product.id];

    if (controller != null) {
      final text = packageCount.toString();

      if (controller.text != text) {
        controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  void _updatePackageSize(CartItemModel item, String value) {
    final packageSize = int.tryParse(value);

    if (packageSize == null || packageSize < 1) {
      return;
    }

    ref
        .read(cartProvider.notifier)
        .setPackageSize(item.product.id, packageSize);
  }

  void _updatePackagePrice(CartItemModel item, String value) {
    final price = parseRupiah(value);

    ref.read(cartProvider.notifier).setPackagePrice(item.product.id, price);
  }

  void _updateRetailPrice(CartItemModel item, String value) {
    final price = parseRupiah(value);

    ref.read(cartProvider.notifier).setRetailPrice(item.product.id, price);
  }

  void _togglePackagePricing(CartItemModel item, bool enabled) {
    final notifier = ref.read(cartProvider.notifier);

    if (!enabled) {
      notifier.resetPackagePricing(item.product.id);
      return;
    }

    notifier.setUsePackagePricing(item.product.id, true);
  }

  void _removeItem(CartItemModel item) {
    ref.read(cartProvider.notifier).remove(item.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        title: const Text(
          'Keranjang Kasir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (cart.isBackorder) _buildBackorderBanner(),

          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyCart()
                : _buildCartList(cart),
          ),
        ],
      ),
      bottomNavigationBar: CashierBottomTotal(
        cart: cart,
        formatRupiah: formatRupiah,
        onCheckout: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
        },
      ),
    );
  }

  Widget _buildBackorderBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Backorder',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'Produk dapat diproses walaupun stok tidak mencukupi.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 58,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Keranjang masih kosong',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan produk untuk mulai transaksi',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartState cart) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final item = cart.items[index];

        return CashierCartItem(
          item: item,
          index: index,
          isBackorder: cart.isBackorder,

          qtyController: _qtyController(item),
          packageSizeController: _packageSizeController(item),

          packageQtyController: _packageQtyController(item),
          packagePriceController: _packagePriceController(item),
          retailPriceController: _retailPriceController(item),

          qtyFocusNode: _qtyFocusNode(item.product.id),
          packageSizeFocusNode: _packageSizeFocusNode(item.product.id),

          packageQtyFocusNode: _packageQtyFocusNode(item.product.id),
          packagePriceFocusNode: _packagePriceFocusNode(item.product.id),
          retailPriceFocusNode: _retailPriceFocusNode(item.product.id),

          formatRupiah: formatRupiah,
          onUpdateQty: (value) {
            _updateQty(item, value);
          },
          onIncreaseQty: () {
            _increaseQty(item);
          },
          onDecreaseQty: () {
            _decreaseQty(item);
          },
          onUpdatePackageQty: (value) {
            _updatePackageQty(item, value);
          },
          onUpdatePackageSize: (value) {
            _updatePackageSize(item, value);
          },
          onUpdatePackagePrice: (value) {
            _updatePackagePrice(item, value);
          },
          onUpdateRetailPrice: (value) {
            _updateRetailPrice(item, value);
          },
          onTogglePackagePricing: (enabled) {
            _togglePackagePricing(item, enabled);
          },

          onRemove: () {
            _removeItem(item);
          },
          onResetPackagePricing: () {
            ref
                .read(cartProvider.notifier)
                .resetPackagePricing(item.product.id);
          },
        );
      },
    );
  }
} 