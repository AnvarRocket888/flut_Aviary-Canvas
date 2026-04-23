import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// First-launch onboarding tutorial (4 pages).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      emoji:    '🐦',
      title:    'Welcome to Aviary Canvas',
      subtitle: 'Plan, design and optimise your bird enclosure with precision '
                'drawing tools and smart aviary calculations.',
    ),
    _PageData(
      emoji:    '🎨',
      title:    'Draw Your Layout',
      subtitle: 'Use the pencil, rectangle, fill and move tools to paint '
                'zones on the canvas grid. Undo/redo keeps you in control. '
                'Pinch to zoom in for detail work.',
    ),
    _PageData(
      emoji:    '🧮',
      title:    'Smart Calculator',
      subtitle: 'Enter bird species and counts, then run the calculator '
                'to get space, feeder, water and perch recommendations. '
                'Export results as a PDF.',
    ),
    _PageData(
      emoji:    '🏆',
      title:    'Earn Achievements',
      subtitle: 'Gain XP, climb ranks from Egg to Master Aviarist, and '
                'unlock achievements as you design. Check your progress '
                'on the Profile tab.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                onPressed: _finish,
                child: Text('Skip', style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount:  _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width:  active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:        active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: CupertinoButton(
                onPressed: isLast
                    ? _finish
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve:    Curves.easeInOut,
                        ),
                padding: EdgeInsets.zero,
                child: Container(
                  width:      double.infinity,
                  padding:    const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient:     const LinearGradient(
                        colors: [AppColors.primary, AppColors.gold]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:      AppColors.primary.withOpacity(0.4),
                        blurRadius: 14,
                        offset:     const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isLast ? 'Get Started 🚀' : 'Next',
                      style: AppTextStyles.button.copyWith(
                          color: const Color(0xFF0D1B2A)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Single onboarding page ────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin:    const Offset(1, 1),
                end:      const Offset(1.08, 1.08),
                duration: 2000.ms,
                curve:    Curves.easeInOut,
              ),
          const SizedBox(height: 32),
          Text(
            data.title,
            style:     AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style:     AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _PageData {
  final String emoji, title, subtitle;
  const _PageData({required this.emoji, required this.title, required this.subtitle});
}
