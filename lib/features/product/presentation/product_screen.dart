import 'package:bk_pos/features/product/presentation/prodcut_filter_section.dart';
import 'package:bk_pos/features/product/presentation/product_grid.dart';
import 'package:bk_pos/features/product/presentation/product_scan_screen.dart';
import 'package:bk_pos/features/profile/provider/profile_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/product_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductScanScreen()),
          );
        },
       
        child: Icon(Icons.qr_code_scanner, size: 28, color: AppColors.dark),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              notifier.loadProducts(),
              ref.read(profileProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverPinnedHeader(child: ProductFilterSection()),
              MultiSliver(children: [ProductGrid()]),
            ],
          ),
        ),
      ),
    );
  }
}
