import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/auth/auth_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
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

/// Root widget — manages the three-phase launch sequence:
/// 1. Onboarding (first launch only)
/// 2. Authentication (PIN / Biometrics)
/// 3. Main application (wrapped in LifecycleGuard)
class VitaVaultRoot extends StatefulWidget {
  const VitaVaultRoot({super.key});

  @override
  State<VitaVaultRoot> createState() => _VitaVaultRootState();
}

class _VitaVaultRootState extends State<VitaVaultRoot> {
  bool _loading = true;
  bool _needsOnboarding = false;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (mounted) {
      setState(() {
        _needsOnboarding = !completed;
        _loading = false;
      });
    }
  }

  void _handleOnboardingComplete() {
    setState(() => _needsOnboarding = false);
  }

  void _handleAuthenticated() {
    setState(() => _authenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaVault',
      debugShowCheckedModeBanner: false,
      theme: VaultTheme.darkTheme,
      home: _loading
          ? const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: VaultColors.phosphorGreen,
                ),
              ),
            )
          : _needsOnboarding
          ? OnboardingScreen(onComplete: _handleOnboardingComplete)
          : _authenticated
          ? LifecycleGuard(child: const VitaVaultApp())
          : AuthScreen(onAuthenticated: _handleAuthenticated),
    );
  }
}
