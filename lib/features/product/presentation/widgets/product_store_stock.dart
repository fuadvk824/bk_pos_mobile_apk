import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductStoreStock extends StatelessWidget {
  final ProductModel product;

  const ProductStoreStock({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: product.stores.isEmpty
            ? _emptyState()
            : Column(
                children: [
                  ...product.stores.asMap().entries.map((entry) {
                    final index = entry.key;
                    final store = entry.value;

                    return Column(
                      children: [
                        _infoTile(
                          store.name,
                          '${store.stock} ${product.unit}',
                          store.stock,
                        ),
                        if (index != product.stores.length - 1) const Divider(),
                      ],
                    );
                  }),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.store, color: Colors.grey),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Produk belum tersedia di store manapun',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, int stock) {
    final Color stockColor;

    if (stock <= 0) {
      stockColor = Colors.red;
    } else if (stock < 10) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.store, color: Colors.deepOrange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: stockColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
