import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/player/presentation/widgets/mini_player.dart';

/// Primary application shell hosting the persistent Material 3 NavigationBar
/// and the persistent floating MiniPlayer.
class AppScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent Floating MiniPlayer above bottom navigation
          const MiniPlayer(),

          // Material 3 Navigation Bar
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: AppConstants.navHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: AppConstants.navSearch,
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: AppConstants.navLibrary,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: AppConstants.navProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
