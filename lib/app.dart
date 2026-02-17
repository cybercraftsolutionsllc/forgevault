import 'package:flutter/material.dart';

import 'core/config/environment_config.dart';
import 'features/home/home_screen.dart';
import 'features/vacuum/vacuum_screen.dart';
import 'features/bio/bio_viewer_screen.dart';
import 'features/oracle/oracle_chat_screen.dart';
import 'features/engine_room/engine_room_screen.dart';
import 'theme/theme.dart';

/// Navigation Shell — bottom navigation with 5 destinations.
class VitaVaultApp extends StatelessWidget {
  const VitaVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaVault',
      debugShowCheckedModeBanner: false,
      theme: VaultTheme.darkTheme,
      home: const _NavigationShell(),
    );
  }
}

class _NavigationShell extends StatefulWidget {
  const _NavigationShell();

  @override
  State<_NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<_NavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    VacuumScreen(),
    BioViewerScreen(),
    OracleChatScreen(),
    EngineRoomScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // ── Blast Shield Watermark ──
          if (isSafeMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SAFE MODE',
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_upload_outlined),
            selectedIcon: Icon(Icons.file_upload_rounded),
            label: 'Vacuum',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Bio',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat_rounded),
            label: 'Oracle',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_suggest_outlined),
            selectedIcon: Icon(Icons.settings_suggest_rounded),
            label: 'Engine',
          ),
        ],
      ),
    );
  }
}
