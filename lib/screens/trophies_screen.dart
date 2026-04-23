import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/trophy.dart';
import '../services/gamification_service.dart';
import '../services/appsflyer_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-screen trophy showcase pushed from ProfileScreen.
class TrophiesScreen extends StatefulWidget {
  const TrophiesScreen({super.key});

  @override
  State<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends State<TrophiesScreen> {
  @override
  void initState() {
    super.initState();
    AppsFlyerService.instance.trackTrophiesViewed();
  }

  int get _unlockedCount => Trophy.all
      .where((t) => GamificationService.instance.isTrophyUnlocked(t.id))
      .length;

  @override
  Widget build(BuildContext context) {
    final safeTop    = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          SizedBox(height: safeTop),
          // Nav bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                CupertinoButton(
                  padding:   EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child:     const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.chevron_left, color: AppColors.primary, size: 20),
                      Text('Back', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
                const Spacer(),
                Text('Trophies', style: AppTextStyles.heading3),
                const Spacer(),
                const SizedBox(width: 70),
              ],
            ),
          ),
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child:   _SummaryBar(unlocked: _unlockedCount, total: Trophy.all.length),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottom + 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   2,
                mainAxisSpacing:  14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount:   Trophy.all.length,
              itemBuilder: (_, i) {
                final t          = Trophy.all[i];
                final isUnlocked = GamificationService.instance.isTrophyUnlocked(t.id);
                return _TrophyCard(trophy: t, isUnlocked: isUnlocked, index: i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary ───────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int unlocked, total;
  const _SummaryBar({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:     const LinearGradient(
          colors: [
            Color(0x22F4A261),
            Color(0x22FFD166),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$unlocked of $total trophies earned',
                style: AppTextStyles.heading3,
              ),
              Text(
                unlocked == total
                    ? '🎉 Complete collection!'
                    : '${total - unlocked} remaining',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trophy card ───────────────────────────────────────────────────────────────

class _TrophyCard extends StatefulWidget {
  final Trophy trophy;
  final bool   isUnlocked;
  final int    index;

  const _TrophyCard({
    required this.trophy,
    required this.isUnlocked,
    required this.index,
  });

  @override
  State<_TrophyCard> createState() => _TrophyCardState();
}

class _TrophyCardState extends State<_TrophyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isUnlocked) {
      _glowCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Color get _tierColor => widget.trophy.tier.color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, child) {
        final glow = widget.isUnlocked
            ? _glowCtrl.value * 0.4
            : 0.0;
        return Container(
          decoration: BoxDecoration(
            color:        widget.isUnlocked
                ? _tierColor.withOpacity(0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border:       Border.all(
              color: widget.isUnlocked
                  ? _tierColor.withOpacity(0.5 + glow * 0.4)
                  : AppColors.border,
              width: widget.isUnlocked ? 1.5 : 1,
            ),
            boxShadow: widget.isUnlocked
                ? [
                    BoxShadow(
                      color:      _tierColor.withOpacity(0.15 + glow * 0.2),
                      blurRadius: 16 + glow * 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:   Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tier badge
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:        _tierColor.withOpacity(widget.isUnlocked ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.trophy.tier.label,
                style: AppTextStyles.caption.copyWith(
                  color: widget.isUnlocked ? _tierColor : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Emoji
            Text(
              widget.trophy.emoji,
              style: TextStyle(
                fontSize: 42,
                color:    widget.isUnlocked ? null : const Color(0x44FFFFFF),
              ),
            )
                .animate(
                  onPlay: widget.isUnlocked
                      ? (c) => c.repeat(reverse: true)
                      : null,
                )
                .scale(
                  begin:    const Offset(1.0, 1.0),
                  end:      const Offset(1.06, 1.06),
                  duration: 1600.ms,
                  curve:    Curves.easeInOut,
                ),
            const SizedBox(height: 10),
            // Title
            Text(
              widget.trophy.title,
              style: AppTextStyles.achievementTitle.copyWith(
                color: widget.isUnlocked ? _tierColor : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines:  2,
              overflow:  TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.trophy.description,
              style: AppTextStyles.achievementDesc.copyWith(
                color:    widget.isUnlocked ? AppColors.textSecondary : AppColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines:  3,
              overflow:  TextOverflow.ellipsis,
            ),
            if (widget.isUnlocked) ...[
              const SizedBox(height: 8),
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: AppColors.primary,
                size:  18,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (widget.index * 60).ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end:   const Offset(1, 1),
          delay: (widget.index * 60).ms,
          curve: Curves.elasticOut,
        );
  }
}
