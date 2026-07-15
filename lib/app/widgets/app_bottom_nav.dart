import 'package:flutter/material.dart';
import 'package:pe/app/route_names.dart';
import 'package:pe/app/theme.dart';

/// Bottom navigation matching the mockups. Explore is the equipment flow;
/// Saved opens the compare/watchlist screen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.currentIndex = 1});

  /// 0 Home · 1 Explore · 2 Saved · 3 Profile
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => _goHome(context),
                ),
                _NavItem(
                  label: 'Explore',
                  selected: currentIndex == 1,
                  onTap: () => _goExplore(context),
                ),
                _NavItem(
                  label: 'Saved',
                  selected: currentIndex == 2,
                  onTap: () => Navigator.pushNamed(context, RouteNames.compare),
                ),
                _NavItem(
                  label: 'Profile',
                  selected: currentIndex == 3,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile is not available in this build.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _goExplore(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
