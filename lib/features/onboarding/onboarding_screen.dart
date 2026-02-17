import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme.dart';

/// First-Launch Onboarding — 4-page swipeable tutorial.
///
/// Shown once before PIN creation. Uses Dark Forest theme throughout.
/// Persists `hasCompletedOnboarding` via SharedPreferences.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _totalPages = 4;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.security_rounded,
      title: 'Welcome to the Vault.',
      subtitle: 'YOUR DATA. YOUR DEVICE. ZERO CLOUD.',
      body:
          'VitaVault is a 100% offline personal data vault. '
          'Nothing ever leaves your device — no accounts, no servers, no tracking. '
          'Your entire life biography is encrypted and stored solely on hardware you control.',
    ),
    _OnboardingPage(
      icon: Icons.cyclone_rounded,
      title: 'The Vacuum & The Purge.',
      subtitle: 'INGEST. EXTRACT. SHRED.',
      body:
          'Drag in messy files — photos, PDFs, documents. '
          'The Vacuum ingests and encrypts them locally. '
          'After extraction, the originals are mathematically shredded '
          'using cryptographic overwrite — absolute, irreversible privacy.',
    ),
    _OnboardingPage(
      icon: Icons.bolt_rounded,
      title: 'The Forge.',
      subtitle: 'BRING YOUR OWN KEY (BYOK)',
      body:
          'Connect your personal API keys for Grok, Claude, or Gemini. '
          'The Forge sends encrypted text to YOUR cloud AI for deep synthesis. '
          'Your keys are stored in your device\'s hardware keychain, never in our code.',
    ),
    _OnboardingPage(
      icon: Icons.auto_stories_rounded,
      title: 'The Mint.',
      subtitle: 'EXTRACT. MINT. EXPORT.',
      body:
          'Your Living Bio accumulates over time — identity, health, finances, relationships. '
          'The Mint lets you export AI-ready context files and generate polished resumes, '
          'all built from your own verified data.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Page Indicators ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                children: List.generate(_totalPages, (index) {
                  final isActive = index == _currentPage;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isActive
                            ? VaultColors.phosphorGreen
                            : VaultColors.surface,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    VaultColors.phosphorGreen.withValues(
                                      alpha: _glowAnimation.value * 0.12,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: VaultColors.phosphorGreen.withValues(
                                      alpha: _glowAnimation.value * 0.06,
                                    ),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF2A2A2A),
                                        Color(0xFF1A1A1A),
                                        Color(0xFF0F0F0F),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: VaultColors.phosphorGreenDim,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size: 28,
                                    color: VaultColors.phosphorGreen,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: VaultColors.textPrimary,
                            letterSpacing: 1,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: VaultColors.phosphorGreen,
                            letterSpacing: 3,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Body
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: VaultColors.textSecondary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Bottom Actions ──
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: isLastPage
                  ? AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: VaultColors.phosphorGreen.withValues(
                                  alpha: _glowAnimation.value * 0.15,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _completeOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VaultColors.primary,
                                foregroundColor: VaultColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: VaultColors.phosphorGreenDim,
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'INITIALIZE VAULT',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: VaultColors.textMuted,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: VaultColors.phosphorGreenDim,
                                width: 1,
                              ),
                              color: VaultColors.surface,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: VaultColors.phosphorGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}
