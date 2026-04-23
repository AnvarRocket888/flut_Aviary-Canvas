import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/rank_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-screen rank-up celebration overlay.
/// Shows a burst of confetti particles, rank badge zoom-in, and
/// auto-dismisses after [AppConstants.celebrationDuration].
class RankUpCelebration extends StatefulWidget {
  final RankModel    newRank;
  final VoidCallback onDismissed;

  const RankUpCelebration({
    super.key,
    required this.newRank,
    required this.onDismissed,
  });

  @override
  State<RankUpCelebration> createState() => _RankUpCelebrationState();
}

class _RankUpCelebrationState extends State<RankUpCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Confetti>      _confetti;

  @override
  void initState() {
    super.initState();
    final rng  = Random();
    _confetti  = List.generate(80, (_) => _Confetti.random(rng));
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..forward().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onDismissed,
      child: Container(
        color: AppColors.background.withOpacity(0.92),
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _ctrl,
              builder:   (_, __) => CustomPaint(
                painter: _ConfettiPainter(_confetti, _ctrl.value, size),
                child:   const SizedBox.expand(),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('RANK UP!',
                    style: AppTextStyles.heading1.copyWith(
                      color:       AppColors.gold,
                      fontSize:    14,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 24),
                  Text(
                    widget.newRank.emoji,
                    style: const TextStyle(fontSize: 96),
                  )
                      .animate()
                      .scale(
                        begin:    const Offset(0.2, 0.2),
                        end:      const Offset(1, 1),
                        duration: 600.ms,
                        curve:    Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),
                  Text(
                    widget.newRank.title,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.gold,
                      fontSize: 32,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0, delay: 400.ms),
                  const SizedBox(height: 12),
                  Text(
                    widget.newRank.description,
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: widget.onDismissed,
                    child: Container(
                      padding:      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration:   BoxDecoration(
                        gradient:     const LinearGradient(
                          colors: [AppColors.primary, AppColors.gold],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('Awesome!', style: AppTextStyles.button),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0, delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Confetti {
  final double x, y, size, angle, speed, rotSpeed;
  final Color  color;

  const _Confetti({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.speed,
    required this.rotSpeed,
    required this.color,
  });

  static const List<Color> _colors = [
    AppColors.gold,
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    Color(0xFFFF6B6B),
    Color(0xFFC678DD),
  ];

  factory _Confetti.random(Random rng) => _Confetti(
    x:        rng.nextDouble(),
    y:        rng.nextDouble() * 0.3,
    size:     rng.nextDouble() * 6 + 3,
    angle:    rng.nextDouble() * 2 * pi,
    speed:    rng.nextDouble() * 0.6 + 0.2,
    rotSpeed: rng.nextDouble() * 4 - 2,
    color:    _colors[rng.nextInt(_colors.length)],
  );
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> items;
  final double          t;
  final Size            screenSize;

  _ConfettiPainter(this.items, this.t, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final c in items) {
      final progress = (t * c.speed * 2).clamp(0.0, 1.0);
      final x = c.x * size.width + sin(t * 3 + c.angle) * 30;
      final y = c.y * size.height + progress * size.height * 1.2;
      final opacity = (1.0 - progress * 0.8).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.angle + c.rotSpeed * t * 10);
      paint.color = c.color.withOpacity(opacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.5),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
