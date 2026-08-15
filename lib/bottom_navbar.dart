import 'package:bk_pos/features/auth/presentation/auth_login_screen.dart';
import 'package:bk_pos/features/auth/provider/auth_provider.dart';
import 'package:bk_pos/features/category/profile.dart';
import 'package:bk_pos/features/product/presentation/product_screen.dart';
import 'package:bk_pos/features/profile/presentation/profile_screen.dart';
import 'package:bk_pos/features/transaction/presentation/transaction_screen.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

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
    {"icon": LucideIcons.package, "label": "Product"},
    {"icon": LucideIcons.logs, "label": "Transaction"},
    {"icon": LucideIcons.filePenLine, "label": "Purchase Order"},
    {"icon": LucideIcons.banknoteArrowUp, "label": "Settlement"},
    {"icon": LucideIcons.user, "label": "Profile"},
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _pages = [
      ProductScreen(),
      TransactionScreen(),
      Profile(),
      Profile(),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();  
    super.dispose();
  }

  void _changePage(int index) {
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
      backgroundColor: AppColors.light,

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
        child: CurvedNavigationBar(
          index: _currentIndex,
          height: 70, 
          color: AppColors.primary,
          backgroundColor: AppColors.transparent,
          buttonBackgroundColor: AppColors.dark,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
        
          onTap: (index) {
            _changePage(index);
          },
          items: List.generate(_items.length, (index) {
            final item = _items[index];
        
            return CurvedNavigationBarItem(
              child: Icon(
                item["icon"] as IconData,
                color: _currentIndex == index ? AppColors.primary : AppColors.dark,
              ),
              label: item["label"] as String,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _currentIndex == index ? AppColors.primary : AppColors.dark,
              ),
            );
          }),
         
        ),
      ),
    );
  }
}
