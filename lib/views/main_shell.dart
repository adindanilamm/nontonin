import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'app_nav.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'recommendation_page.dart';
import 'search_page.dart';

/// Kerangka utama aplikasi dengan bottom navigation 4 tab.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = [
    HomePage(),
    RecommendationPage(),
    SearchPage(),
    FavoritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNav.tab,
      builder: (context, index, _) {
        return PopScope(
          // Tombol kembali Android di tab selain Beranda akan kembali ke Beranda.
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) AppNav.tab.value = 0;
          },
          child: Scaffold(
            body: IndexedStack(index: index, children: _pages),
            bottomNavigationBar: _BottomNav(
              index: index,
              onTap: (i) {
                FocusManager.instance.primaryFocus?.unfocus();
                AppNav.tab.value = i;
              },
            ),
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Rekomendasi'),
    (Icons.search_rounded, Icons.search_rounded, 'Cari'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favorit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFF2A2A34))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == index;
              final color = active ? AppColors.primary : AppColors.textSecondary;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(active ? item.$2 : item.$1, color: color, size: 26),
                      const SizedBox(height: 4),
                      Text(item.$3,
                          style: TextStyle(fontSize: 11, color: color)),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 18 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
