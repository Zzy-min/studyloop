import 'package:flutter/material.dart';
import '../colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.homeLabel,
    required this.recordsLabel,
    required this.insightsLabel,
    required this.profileLabel,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String homeLabel;
  final String recordsLabel;
  final String insightsLabel;
  final String profileLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StudyLoopColors.surface,
        border: Border(
          top: BorderSide(color: StudyLoopColors.border, width: 0.8),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: StudyLoopColors.surface,
        indicatorColor: StudyLoopColors.primaryLight,
        elevation: 0,
        height: 64,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(
              Icons.home_rounded,
              color: StudyLoopColors.primary,
            ),
            label: homeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(
              Icons.assignment_rounded,
              color: StudyLoopColors.primary,
            ),
            label: recordsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(
              Icons.menu_book_rounded,
              color: StudyLoopColors.primary,
            ),
            label: insightsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(
              Icons.person_rounded,
              color: StudyLoopColors.primary,
            ),
            label: profileLabel,
          ),
        ],
      ),
    );
  }
}
