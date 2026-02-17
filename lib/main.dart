import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/auth/auth_screen.dart';
import 'core/services/lifecycle_guard.dart';
import 'core/services/security_flags_service.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark system chrome overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: VaultColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable screenshot prevention (FLAG_SECURE on Android, capture prevention on iOS).
  SecurityFlagsService.enableAll();

  runApp(const ProviderScope(child: VitaVaultRoot()));
}

/// Root widget — shows [AuthScreen] until authenticated,
/// then transitions to [VitaVaultApp] (navigation shell)
/// wrapped in [LifecycleGuard] for panic blur protection.
class VitaVaultRoot extends StatefulWidget {
  const VitaVaultRoot({super.key});

  @override
  State<VitaVaultRoot> createState() => _VitaVaultRootState();
}

class _VitaVaultRootState extends State<VitaVaultRoot> {
  bool _authenticated = false;

  void _handleAuthenticated() {
    setState(() => _authenticated = true);
  }

  void _handleForceReauth() {
    setState(() => _authenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaVault',
      debugShowCheckedModeBanner: false,
      theme: VaultTheme.darkTheme,
      home: _authenticated
          ? LifecycleGuard(
              onForceReauth: _handleForceReauth,
              child: const VitaVaultApp(),
            )
          : AuthScreen(onAuthenticated: _handleAuthenticated),
    );
  }
}
