import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Slides in from the top when an achievement is unlocked.
/// Auto-dismisses after [AppConstants.toastDuration].
class AchievementToast extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismissed;

  const AchievementToast({
    super.key,
    required this.achievement,
    required this.onDismissed,
  });

  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
    // Auto-dismiss
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top:   MediaQuery.of(context).padding.top + 12,
      left:  20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child:   GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration:   BoxDecoration(
                color:        AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.gold.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.gold.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pulsing emoji
                  Text(widget.achievement.emoji, style: const TextStyle(fontSize: 32))
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin:    const Offset(1, 1),
                        end:      const Offset(1.2, 1.2),
                        duration: 600.ms,
                        curve:    Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin:    const Offset(1.2, 1.2),
                        end:      const Offset(1, 1),
                        duration: 600.ms,
                        curve:    Curves.easeInOut,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievement Unlocked!',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.title,
                          style: AppTextStyles.achievementTitle,
                        ),
                        Text(
                          '+${widget.achievement.xpReward} XP',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textMuted,
                    size:  18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
