import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/auth/auth_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'core/database/database_service.dart';
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

  runApp(const ProviderScope(child: ForgeVaultRoot()));
}

/// Root widget — manages the four-phase launch sequence:
/// 1. Welcome (first launch or fresh install — Initialize or Restore)
/// 2. Onboarding (swipeable tutorial, first launch only)
/// 3. Authentication (PIN / Biometrics)
/// 4. Main application (wrapped in LifecycleGuard)
class ForgeVaultRoot extends StatefulWidget {
  const ForgeVaultRoot({super.key});

  @override
  State<ForgeVaultRoot> createState() => _ForgeVaultRootState();
}

class _ForgeVaultRootState extends State<ForgeVaultRoot> {
  bool _loading = true;
  bool _needsWelcome = false;
  bool _needsOnboarding = false;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('hasCompletedOnboarding') ?? false;
    final pinConfigured = await DatabaseService.instance.isPinConfigured();

    if (mounted) {
      setState(() {
        // Show Welcome if the user has never set up a vault
        _needsWelcome = !onboardingDone && !pinConfigured;
        // Show Onboarding if it hasn't been completed but vault IS set up
        // (e.g., after a restore that bootstraps the PIN)
        _needsOnboarding = !onboardingDone && pinConfigured;
        _loading = false;
      });
    }
  }

  void _handleWelcomeInitialize() {
    // Route to Onboarding (which leads to PIN setup in Auth)
    setState(() {
      _needsWelcome = false;
      _needsOnboarding = true;
    });
  }

  void _handleWelcomeRestore() {
    // Restore completed — PIN/salt already configured by importCapsule.
    // Skip onboarding, go straight to Auth.
    setState(() {
      _needsWelcome = false;
      _needsOnboarding = false;
    });
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
      title: 'ForgeVault',
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
          : _needsWelcome
          ? WelcomeScreen(
              onInitialize: _handleWelcomeInitialize,
              onRestoreComplete: _handleWelcomeRestore,
            )
          : _needsOnboarding
          ? OnboardingScreen(onComplete: _handleOnboardingComplete)
          : _authenticated
          ? LifecycleGuard(child: const ForgeVaultApp())
          : AuthScreen(onAuthenticated: _handleAuthenticated),
    );
  }
}
