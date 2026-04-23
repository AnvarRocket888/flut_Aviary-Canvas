import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

/// Full-screen animated particle background.
/// Floating feather-like dots drift upward slowly.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle>     _particles;

  @override
  void initState() {
    super.initState();
    final rng    = Random();
    _particles   = List.generate(40, (_) => _Particle.random(rng));
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [
                Color(0xFF0D1B2A),
                Color(0xFF0F2035),
                Color(0xFF0A1520),
              ],
            ),
          ),
        ),
        // Particles
        AnimatedBuilder(
          animation: _ctrl,
          builder:   (_, __) => CustomPaint(
            painter: _ParticlePainter(_particles, _ctrl.value),
            child:   const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double baseX;
  final double startY;
  final double size;
  final double speed;
  final double opacity;
  final double sway;
  final double phase;

  const _Particle({
    required this.baseX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.sway,
    required this.phase,
  });

  factory _Particle.random(Random rng) => _Particle(
    baseX:   rng.nextDouble(),
    startY:  rng.nextDouble(),
    size:    rng.nextDouble() * 3.5 + 0.8,
    speed:   rng.nextDouble() * 0.03 + 0.008,
    opacity: rng.nextDouble() * 0.25 + 0.04,
    sway:    rng.nextDouble() * 0.04 + 0.005,
    phase:   rng.nextDouble() * 2 * pi,
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double          t;

  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      // Y rises over time, wraps at 0
      final y = ((p.startY - p.speed * t * 10) % 1.0) * size.height;
      final x = (p.baseX + sin(t * 2 * pi * 2 + p.phase) * p.sway) * size.width;

      // Alternate between amber dots and cyan dots
      final isAmber = p.phase < pi;
      paint.color = (isAmber ? AppColors.primary : AppColors.accent)
          .withOpacity(p.opacity);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
