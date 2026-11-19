import 'package:flutter/material.dart';

import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/model/wilayah_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WilayahSearchField extends StatelessWidget {
  final TextEditingController controller;

  final String hierarchyLabel;
  final String searchHint;

  final bool enabled;
  final bool loading;

  final List<WilayahModel> results;

  final ValueChanged<String> onChanged;
  final ValueChanged<WilayahModel> onSelected;

  final VoidCallback onClear;
  final VoidCallback onReset;
  final VoidCallback onUndo;

  const WilayahSearchField({
    super.key,
    required this.controller,
    required this.hierarchyLabel,
    required this.searchHint,
    required this.enabled,
    required this.loading,
    required this.results,
    required this.onChanged,
    required this.onSelected,
    required this.onClear,
    required this.onReset,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedWilayah = hierarchyLabel != 'Pilih Wilayah';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            hierarchyLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        TextField(
          controller: controller,

          readOnly: !enabled,

          onChanged: enabled ? onChanged : null,

          decoration: inputDecoration(
            label: searchHint,
            icon: LucideIcons.mapPlus,
          ).copyWith(
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),

                if (!loading && controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Hapus pencarian',
                    icon: const Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onPressed: onClear,
                  ),

                if (!loading && hasSelectedWilayah)
                  IconButton(
                    tooltip: 'Undo wilayah terakhir',
                    icon: const Icon(
                      LucideIcons.undo2,
                      size: 19,
                    ),
                    onPressed: onUndo,
                  ),

                if (!loading && hasSelectedWilayah)
                  IconButton(
                    tooltip: 'Reset semua wilayah',
                    icon: const Icon(
                      LucideIcons.rotateCw,
                      size: 19,
                    ),
                    onPressed: onReset,
                  ),
              ],
            ),
          ),
        ),

        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(
              maxHeight: 220,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = results[index];

                return ListTile(
                  dense: true,
                  title: Text(item.nama),
                  subtitle: Text(item.kode),
                  onTap: () {
                    onSelected(item);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

