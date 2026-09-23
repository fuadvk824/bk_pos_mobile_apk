import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductQuantityControl extends StatelessWidget {
  final int qty;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;

  const ProductQuantityControl({
    super.key,
    required this.qty,
    required this.controller,
    required this.focusNode,
    required this.onDecrease,
    required this.onIncrease,
    required this.onChanged,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),

          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
            ),
          ),

          IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
