import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/auth_screen.dart';
import 'features/help/help_screen.dart';
import 'features/home/home_screen.dart';
import 'features/vacuum/vacuum_screen.dart';
import 'features/bio/bio_viewer_screen.dart';
import 'features/nexus/nexus_chat_screen.dart';
import 'features/engine_room/engine_room_screen.dart';
import 'features/backup/backup_screen.dart';
import 'theme/theme.dart';

/// Navigation Shell — bottom navigation with 5 destinations.
class ForgeVaultApp extends StatelessWidget {
  const ForgeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForgeVault',
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

  void _switchTab(int index) {
    if (index >= 0 && index < 6) {
      setState(() => _currentIndex = index);
    }
  }

  late final List<Widget> _screens = [
    HomeScreen(onSwitchTab: _switchTab),
    VacuumScreen(onSwitchTab: _switchTab),
    const BioViewerScreen(),
    const NexusChatScreen(),
    const EngineRoomScreen(),
    const BackupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ForgeVault',
          style: GoogleFonts.inter(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.red, size: 20),
            tooltip: 'Lock Vault',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AuthScreen(onAuthenticated: () {}),
              ),
              (_) => false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [IndexedStack(index: _currentIndex, children: _screens)],
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
            label: 'Nexus',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_suggest_outlined),
            selectedIcon: Icon(Icons.settings_suggest_rounded),
            label: 'Engine',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Backups',
          ),
        ],
      ),
    );
  }
}
