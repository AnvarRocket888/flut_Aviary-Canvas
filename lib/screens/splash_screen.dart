import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';
import 'main_screen.dart';

/// Welcome / Splash screen shown on every app launch.
/// Auto-dismisses after 5 seconds with a fade-out animation.
/// Tapping anywhere triggers the same fade-out early.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: AppConstants.fadeOutDuration,
      value:    1.0,
    );
    // Auto-dismiss after splashHold
    Future.delayed(AppConstants.splashHold, _dismiss);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    await _fadeCtrl.reverse();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      _FadePageRoute(child: const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:    _dismiss,
      child:    FadeTransition(
        opacity: _fadeCtrl,
        child:   AnimatedBackground(
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Bird logo
                _AnimatedBirdLogo()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1),
                           duration: 900.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                // App name
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize:      36,
                    letterSpacing: 2,
                    color:         AppColors.primary,
                    shadows: const [
                      Shadow(color: Color(0xFFF4A261), blurRadius: 20),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, delay: 400.ms),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms),
                const Spacer(),
                // Description card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child:   Container(
                    padding:    const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:        AppColors.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('🐦🏗️🌿', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 12),
                        Text(
                          AppConstants.splashDesc,
                          style:     AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms),
                const Spacer(flex: 2),
                // Tap hint
                Text(
                  'Tap anywhere to continue',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(delay: 1200.ms, duration: 600.ms)
                    .then()
                    .fadeOut(duration: 1000.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated bird logo ────────────────────────────────────────────────────────

class _AnimatedBirdLogo extends StatefulWidget {
  @override
  State<_AnimatedBirdLogo> createState() => _AnimatedBirdLogoState();
}

class _AnimatedBirdLogoState extends State<_AnimatedBirdLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _bob;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bob = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder:   (_, __) => Transform.translate(
        offset: Offset(0, _bob.value),
        child:  Container(
          width:  120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF1F3147), Color(0xFF0D1B2A)],
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:      AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text('🦜', style: TextStyle(fontSize: 60)),
          ),
        ),
      ),
    );
  }
}

// ── Custom fade page route ────────────────────────────────────────────────────

class _FadePageRoute extends PageRouteBuilder {
  final Widget child;
  _FadePageRoute({required this.child})
      : super(
          pageBuilder:       (_, __, ___) => child,
          transitionDuration: AppConstants.fadeOutDuration,
          transitionsBuilder: (_, anim, __, c) =>
              FadeTransition(opacity: anim, child: c),
        );
}
