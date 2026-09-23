import 'package:flutter/material.dart';

class ProductDescriptionCard extends StatefulWidget {
  final String? description;

  const ProductDescriptionCard({super.key, required this.description});

  @override
  State<ProductDescriptionCard> createState() => _ProductDescriptionCardState();
}

class _ProductDescriptionCardState extends State<ProductDescriptionCard> {
  bool _showFullDescription = false;

  String get _description {
    final value = widget.description?.trim();

    if (value == null || value.isEmpty) {
      return 'Belum ada deskripsi untuk produk ini.';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Text(
                _description,
                maxLines: _showFullDescription ? null : 3,
                overflow: _showFullDescription
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.8),
              ),
            ),

            if (_description.length > 120)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showFullDescription = !_showFullDescription;
                    });
                  },
                  child: Text(
                    _showFullDescription
                        ? 'Tampilkan Lebih Sedikit'
                        : 'Lihat Selengkapnya',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
