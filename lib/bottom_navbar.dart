import 'package:bk_pos/features/auth/presentation/auth_login_screen.dart';
import 'package:bk_pos/features/auth/provider/auth_provider.dart';
import 'package:bk_pos/features/cashier/presentation/cashier_screen.dart';
import 'package:bk_pos/features/cashier/provider/cart_provider.dart';
import 'package:bk_pos/features/category/profile.dart';
import 'package:bk_pos/features/store/presentation/store_screen.dart';
import 'package:bk_pos/features/transaction/presentation/transaction_screen.dart';
import 'package:bk_pos/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavbar extends ConsumerStatefulWidget {
  const BottomNavbar({super.key});

  @override
  ConsumerState<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends ConsumerState<BottomNavbar> {
  int _currentIndex = 0;
  late PageController _pageController;

  late final List<Widget> _pages;

  final List<Map<String, dynamic>> _items = const [
    {"icon": LucideIcons.house, "label": "Home"},
    {"icon": LucideIcons.logs, "label": "Transaction"},
    {"icon": LucideIcons.calculator, "label": "Cashier"},
    {"icon": LucideIcons.filePenLine, "label": "Purchase Order"},
    {"icon": LucideIcons.banknote, "label": "Settlement"},
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _pages = [
      StoreScreen(),
      TransactionScreen(),
      CashierScreen(),
      Profile(),
      Profile(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.value == null) {
      return const AuthLoginScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _items.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = _currentIndex == index;
    final item = _items[index];
    //  final cashier = ref.watch(cashierProvider);
    final cart = ref.watch(cartProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: .15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item["icon"], size: 24, color: Colors.white),

                if (index == 2 && cart.items.isNotEmpty)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(
                        minHeight: 20,
                        minWidth: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cart.itemCount > 99
                              ? "99+"
                              : cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isActive
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          item["label"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
