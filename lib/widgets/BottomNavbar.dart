import 'package:atlas/pages/FavoritePage.dart';
import 'package:atlas/pages/HomePage.dart';
import 'package:atlas/pages/ProfilePage.dart';
import 'package:atlas/providers/NavigationProvider.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final currentIndex = navigationProvider.currentIndex;

    return Scaffold(
      extendBody: true,
      body: _pages[currentIndex],
      
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, Icons.home, Icons.home_outlined, 0, currentIndex),
              _buildNavItem(context, Icons.favorite, Icons.favorite_border, 1, currentIndex),
              _buildNavItem(context, Icons.person, Icons.person_outline, 2, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData activeIcon, IconData inactiveIcon, int index, int currentIndex) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        context.read<NavigationProvider>().setIndex(index);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: isSelected ? 20 : 0, 
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 4),
            ),
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}