import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import '../services/gamification_service.dart';
import '../services/appsflyer_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full achievements browser — all 17 achievements grouped by category.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    AppsFlyerService.instance.trackAchievementsViewed();
  }

  int get _unlockedCount => Achievement.all
      .where((a) => GamificationService.instance.isAchievementUnlocked(a.id))
      .length;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final grouped = <AchievementCategory, List<Achievement>>{};
    for (final a in Achievement.all) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    return Column(
      children: [
        SizedBox(height: safeTop),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child:   Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Achievements', style: AppTextStyles.heading2),
                  Text(
                    '$_unlockedCount / ${Achievement.all.length} unlocked',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              _ProgressBadge(
                unlocked: _unlockedCount,
                total:    Achievement.all.length,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms),
        // Progress bar
        _GlobalProgressBar(unlocked: _unlockedCount, total: Achievement.all.length)
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 8),
        // Grouped list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: grouped.entries
                .toList()
                .asMap()
                .entries
                .map((outer) {
              final groupIdx = outer.key;
              final cat      = outer.value.key;
              final items    = outer.value.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:   _CategorySection(
                  category:   cat,
                  items:      items,
                  groupIndex: groupIdx,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Global progress ───────────────────────────────────────────────────────────

class _GlobalProgressBar extends StatelessWidget {
  final int unlocked, total;
  const _GlobalProgressBar({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height:  8,
              color:   AppColors.surfaceElevated,
              child:   FractionallySizedBox(
                alignment:   Alignment.centerLeft,
                widthFactor: pct.clamp(0.0, 1.0),
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
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).round()}% complete',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int unlocked, total;
  const _ProgressBadge({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) => Container(
    padding:    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color:        AppColors.gold.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border:       Border.all(color: AppColors.gold.withOpacity(0.4)),
    ),
    child: Text(
      '🏆 $unlocked/$total',
      style: AppTextStyles.gameStat.copyWith(color: AppColors.gold),
    ),
  );
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final AchievementCategory category;
  final List<Achievement>   items;
  final int                 groupIndex;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.groupIndex,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = items
        .where((a) => GamificationService.instance.isAchievementUnlocked(a.id))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${category.emoji} ${category.label}',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(width: 8),
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:        AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$unlocked/${items.length}',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          final isUnlocked = GamificationService.instance.isAchievementUnlocked(a.id);
          return _AchievementCard(
            achievement: a,
            isUnlocked:  isUnlocked,
            index:       groupIndex * 10 + i,
          );
        }),
      ],
    );
  }
}

// ── Achievement card ──────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool        isUnlocked;
  final int         index;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        isUnlocked
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(
          color: isUnlocked
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.border,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color:      AppColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset:     const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width:  52,
            height: 52,
            decoration: BoxDecoration(
              color:        isUnlocked
                  ? AppColors.primary.withOpacity(0.18)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 26,
                  color:    isUnlocked ? null : const Color(0x66FFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTextStyles.achievementTitle.copyWith(
                          color: isUnlocked ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: AppColors.primary,
                        size:  16,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: AppTextStyles.achievementDesc.copyWith(
                    color: isUnlocked ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // XP badge
          Column(
            children: [
              Container(
                padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        isUnlocked
                      ? AppColors.gold.withOpacity(0.2)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${achievement.xpReward}',
                  style: AppTextStyles.xpValue.copyWith(
                    color: isUnlocked ? AppColors.gold : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text('XP', style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 40).ms, duration: 350.ms)
        .slideX(begin: 0.05, end: 0, delay: (index * 40).ms);
  }
}
