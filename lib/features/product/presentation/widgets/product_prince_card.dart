import 'package:bk_pos/model/product_model.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';

class ProductPriceCard extends StatelessWidget {
  final ProductModel product;

  const ProductPriceCard({super.key, required this.product});

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
            _infoTile(
              Icons.payments_outlined,
              'Harga Jual',
              formatRupiah(product.price),
            ),
            const Divider(),
            _infoTile(
              Icons.discount,
              'Diskon',
              formatRupiah(product.discount),
              valueColor: Colors.red,
            ),
            const Divider(),
            _infoTile(
              Icons.attach_money,
              'Harga Akhir',
              formatRupiah(product.finalPrice),
              valueColor: Colors.deepOrange,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
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
            child: Icon(icon, color: Colors.deepOrange),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
