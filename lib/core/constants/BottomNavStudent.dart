import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BottomNavStudent extends StatelessWidget {
  final int currentIndex;

  const BottomNavStudent({
    super.key,
    required this.currentIndex,
  });

  static const _items = [
    _NavItem(
      icon:        Icons.home_outlined,
      activeIcon:  Icons.home_rounded,
      label:       'Accueil',
      route:       '/student-dashboard',
    ),
    _NavItem(
      icon:        Icons.play_circle_outline_rounded,
      activeIcon:  Icons.play_circle_rounded,
      label:       'Cours',
      route:       '/student-courses',
    ),
    _NavItem(
      icon:        Icons.explore_outlined,
      activeIcon:  Icons.explore_rounded,
      label:       'Explorer',
      route:       '/explorer',
    ),
    _NavItem(
      icon:        Icons.workspace_premium_outlined,
      activeIcon:  Icons.workspace_premium_rounded,
      label:       'Certificats',
      route:       '/certificates',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) => _NavBarItem(
                item:     _items[index],
                isActive: index == currentIndex,
                onTap: () {
                  if (index == currentIndex) return;
                  Navigator.pushReplacementNamed(
                    context,
                    _items[index].route,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// Item widget
// ══════════════════════════════════════
class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool     isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primarySoft
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize:   11,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// Modèle données
// ══════════════════════════════════════
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  final String   route;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}