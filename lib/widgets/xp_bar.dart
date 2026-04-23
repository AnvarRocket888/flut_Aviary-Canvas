import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Animated XP progress bar with current XP, next rank info, and
/// a smooth fill animation triggered on value change.
class XPBar extends StatefulWidget {
  final int    currentXP;
  final double progress;    // 0.0 – 1.0
  final String rankTitle;
  final String rankEmoji;
  final String? nextRankTitle;
  final int     xpToNext;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.progress,
    required this.rankTitle,
    required this.rankEmoji,
    this.nextRankTitle,
    required this.xpToNext,
  });

  @override
  State<XPBar> createState() => _XPBarState();
}

class _XPBarState extends State<XPBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fillAnim;
  double _prevProgress = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _fillAnim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _prevProgress = widget.progress;
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(XPBar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _fillAnim = Tween<double>(
        begin: _prevProgress,
        end:   widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _prevProgress = widget.progress;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank info row
        Row(
          children: [
            Text('${widget.rankEmoji} ', style: const TextStyle(fontSize: 18)),
            Text(widget.rankTitle, style: AppTextStyles.rankTitle),
            const Spacer(),
            Text(
              '${widget.currentXP} XP',
              style: AppTextStyles.xpValue,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 10,
            color:  AppColors.border,
            child:  AnimatedBuilder(
              animation: _fillAnim,
              builder:   (_, __) => FractionallySizedBox(
                alignment:   Alignment.centerLeft,
                widthFactor: _fillAnim.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.gold],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.nextRankTitle != null)
          Text(
            '${widget.xpToNext} XP to ${widget.nextRankTitle}',
            style: AppTextStyles.caption,
          )
        else
          Text('Maximum rank reached', style: AppTextStyles.caption),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}
