import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case AppRoutes.news:
        return 0;
      case AppRoutes.comments:
        return 1;
      case AppRoutes.pushLibrary:
        return 2;
      case AppRoutes.assistant:
        return 3;
      case AppRoutes.profile:
        return 4;
      default:
        return 0;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.news);
        break;
      case 1:
        context.go(AppRoutes.comments);
        break;
      case 2:
        context.go(AppRoutes.pushLibrary);
        break;
      case 3:
        context.go(AppRoutes.assistant);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getSelectedIndex(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context, currentIndex),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56, // Standard bottom nav height
          child: Row(
            children: [
              _buildNavItem(
                context,
                index: 0,
                currentIndex: currentIndex,
                icon: LucideIcons.zap,
                label: '新闻',
              ),
              _buildNavItem(
                context,
                index: 1,
                currentIndex: currentIndex,
                icon: LucideIcons.messageSquare,
                label: '短评',
              ),
              _buildNavItem(
                context,
                index: 2,
                currentIndex: currentIndex,
                icon: LucideIcons.send,
                label: '推送库',
              ),
              _buildNavItem(
                context,
                index: 3,
                currentIndex: currentIndex,
                icon: LucideIcons.bot,
                label: '助手',
              ),
              _buildNavItem(
                context,
                index: 4,
                currentIndex: currentIndex,
                icon: LucideIcons.user,
                label: '我的',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
