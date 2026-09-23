import 'package:bk_pos/model/cart_item_model.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CashierQuantityControl extends StatelessWidget {
  final CartItemModel item;
  final TextEditingController controller;
  final FocusNode focusNode;

  final ValueChanged<String> onChanged;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CashierQuantityControl({
    super.key,
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              onTap: item.qty > 1 ? onDecrease : null,
              child: Center(
                child: Icon(
                  Icons.remove,
                  size: 18,
                  color: item.qty > 1 ? AppColors.dark : Colors.grey.shade400,
                ),
              ),
            ),
          ),

          Container(
            width: 1,
            height: double.infinity,
            color: Colors.grey.shade300,
          ),

          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              onChanged: onChanged,
              onSubmitted: (value) {
                onChanged(value);
                focusNode.unfocus();
              },
            ),
          ),

          Container(
            width: 1,
            height: double.infinity,
            color: Colors.grey.shade300,
          ),

          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(8),
              ),
              onTap: onIncrease,
              child: const Center(child: Icon(Icons.add, size: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
