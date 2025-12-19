import 'package:flutter/material.dart';
import '../../../community/presentation/pages/user_communities_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_icon.dart';

/// Main app shell with bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Main app pages
  final List<Widget> _pages = [
    const HomePage(),
    const _SearchPage(),
    const UserCommunitiesPage(),
    const NewsPage(),
    const _AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Home',
                  icon: AppIconNames.home,
                  highlightedIcon: AppIconNames.homeHighlighted,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Search',
                  icon: AppIconNames.search,
                  highlightedIcon: AppIconNames.searchHighlighted,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Community',
                  icon: AppIconNames.community,
                  highlightedIcon: AppIconNames.communityHighlighted,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'News',
                  icon: AppIconNames.news,
                  highlightedIcon: AppIconNames.newsHighlighted,
                ),
                _buildNavItem(
                  index: 4,
                  label: 'Account',
                  icon: AppIconNames.account,
                  highlightedIcon: AppIconNames.accountHighlighted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String icon,
    required String highlightedIcon,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              iconName: isSelected ? highlightedIcon : icon,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primaryYellow : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages - will be replaced with actual implementations

class _SearchPage extends StatelessWidget {
  const _SearchPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Search Page - To be implemented')),
    );
  }
}


class _AccountPage extends StatelessWidget {
  const _AccountPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Account Page - To be implemented')),
    );
  }
}
