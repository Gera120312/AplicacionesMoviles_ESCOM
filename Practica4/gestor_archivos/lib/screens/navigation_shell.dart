import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'recent_files_screen.dart';
import 'settings_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: 'Inicio',
      ),
      NavigationDestination(icon: Icon(Icons.history), label: 'Recientes'),
      NavigationDestination(
        icon: Icon(Icons.star_outline),
        selectedIcon: Icon(Icons.star),
        label: 'Favoritos',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Configuración',
      ),
    ];
    final pages = <Widget>[
      HomeScreen(appState: widget.appState),
      RecentFilesScreen(appState: widget.appState),
      FavoritesScreen(appState: widget.appState),
      SettingsScreen(appState: widget.appState),
    ];

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final content = IndexedStack(
              index: _selectedIndex,
              children: pages,
            );
            if (wide) {
              return Scaffold(
                body: Row(
                  children: <Widget>[
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) =>
                          setState(() => _selectedIndex = index),
                      labelType: NavigationRailLabelType.all,
                      destinations: destinations
                          .map(
                            (destination) => NavigationRailDestination(
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              label: Text(destination.label),
                            ),
                          )
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                ),
              );
            }
            return Scaffold(
              body: content,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                destinations: destinations,
              ),
            );
          },
        );
      },
    );
  }
}
