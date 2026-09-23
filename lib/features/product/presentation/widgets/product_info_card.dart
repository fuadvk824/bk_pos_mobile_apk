import 'package:bk_pos/model/product_model.dart';
import 'package:flutter/material.dart';

class ProductInfoCard extends StatelessWidget {
  final ProductModel product;
  final bool isBackorder;

  const ProductInfoCard({
    super.key,
    required this.product,
    required this.isBackorder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _infoTile(Icons.qr_code, 'Kode Produk', product.productCode),
            const Divider(),
            _infoTile(
              Icons.inventory,
              'Stok',
              isBackorder ? 'Backorder' : '${product.stock}',
            ),
            const Divider(),
            _infoTile(Icons.scale, 'Satuan', product.unit),
            const Divider(),
            _infoTile(
              Icons.local_fire_department,
              'Terjual',
              '${product.sold}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          _IconBox(icon: icon),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.deepOrange.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.deepOrange),
    );
  }
}
