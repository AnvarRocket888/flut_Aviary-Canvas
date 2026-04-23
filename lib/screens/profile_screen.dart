import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/rank_model.dart';
import '../models/user_profile.dart';
import '../services/gamification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/xp_bar.dart';
import 'help_screen.dart';
import 'privacy_policy_screen.dart';
import 'trophies_screen.dart';

/// User profile tab – rank, XP, streak, stats, trophies link.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameCtrl;

  @override
  void initState() {
    super.initState();
    _flameCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    super.dispose();
  }

  UserProfile get _profile => GamificationService.instance.profile;
  RankModel   get _rank    => GamificationService.instance.getCurrentRank();

  void _openTrophies() => Navigator.of(context).push(
    CupertinoPageRoute(builder: (_) => const TrophiesScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: safeTop, bottom: 24),
      child: Column(
        children: [
          // Header
          const SizedBox(height: 14),
          _RankHero(rank: _rank, xp: _profile.xp)
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.elasticOut),
          const SizedBox(height: 20),
          // XP bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: XPBar(
              currentXP:     _profile.xp,
              progress:      GamificationService.instance.getXPProgress(),
              rankTitle:     _rank.title,
              rankEmoji:     _rank.emoji,
              nextRankTitle: GamificationService.instance.getNextRank()?.title,
              xpToNext:      GamificationService.instance.getXPToNext(),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Streak
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   _StreakCard(
              streakDays: _profile.streakDays,
              flameCtrl:  _flameCtrl,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Stats grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   _StatsGrid(profile: _profile),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Trophies button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   _TrophiesButton(onTap: _openTrophies),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Bird species list
          if (_profile.usedBirdSpecies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:   _SpeciesCard(species: _profile.usedBirdSpecies),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Help / Tutorial button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   _HelpButton(onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const HelpScreen()),
            )),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 20),
          // Privacy Policy button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:   _PrivacyButton(onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            )),
          ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Rank hero ─────────────────────────────────────────────────────────────────

class _RankHero extends StatelessWidget {
  final RankModel rank;
  final int       xp;
  const _RankHero({required this.rank, required this.xp});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(rank.emoji, style: const TextStyle(fontSize: 72))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin:    const Offset(1, 1),
            end:      const Offset(1.08, 1.08),
            duration: 2000.ms,
            curve:    Curves.easeInOut,
          ),
      const SizedBox(height: 10),
      Text(rank.title, style: AppTextStyles.rankTitle),
      const SizedBox(height: 4),
      Text(rank.description, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Container(
        padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:        AppColors.gold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.gold.withOpacity(0.4)),
        ),
        child: Text(
          '⭐ $xp XP total',
          style: AppTextStyles.xpValue,
        ),
      ),
    ],
  );
}

// ── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int                streakDays;
  final AnimationController flameCtrl;
  const _StreakCard({required this.streakDays, required this.flameCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:     LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.gold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: flameCtrl,
            builder: (_, __) => Transform.scale(
              scale: 1.0 + flameCtrl.value * 0.12,
              child: const Text('🔥', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$streakDays',
                    style: AppTextStyles.gameStat.copyWith(
                      fontSize: 32,
                      color:    AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('day streak', style: AppTextStyles.heading3),
                ],
              ),
              Text(
                streakDays >= 7
                    ? '🏅 On fire! Keep it up!'
                    : streakDays >= 3
                        ? '💪 Building momentum!'
                        : 'Come back daily to grow your streak',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final UserProfile profile;
  const _StatsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('📋', 'Schemes', '${profile.totalSchemesCreated}'),
      ('🧮', 'Calculations', '${profile.totalCalculationsRun}'),
      ('🐦', 'Birds Added', '${profile.totalBirdsAdded}'),
      ('🌿', 'Species Used', '${profile.usedBirdSpecies.length}'),
      ('⚠️', 'Conflicts', '${profile.conflictsResolved}'),
      ('🏆', 'Achievements', '${profile.unlockedAchievementIds.length}'),
    ];

    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistics', style: AppTextStyles.heading3),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount:  3,
            shrinkWrap:      true,
            physics:         const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: items.asMap().entries.map((e) => _StatTile(
              emoji: e.value.$1,
              label: e.value.$2,
              value: e.value.$3,
              index: e.key,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji, label, value;
  final int    index;
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.index,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding:    const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color:        AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.gameStat),
        Text(label,
          style:     AppTextStyles.caption.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines:  1,
          overflow:  TextOverflow.ellipsis,
        ),
      ],
    ),
  )
      .animate()
      .fadeIn(delay: (index * 50).ms, duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), delay: (index * 50).ms);
}

// ── Trophies button ───────────────────────────────────────────────────────────

class _TrophiesButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrophiesButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlocked = GamificationService.instance.profile.unlockedTrophyIds.length;
    return CupertinoButton(
      padding:   EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding:    const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient:     const LinearGradient(
            colors: [Color(0x22FFD166), Color(0x22F4A261)],
          ),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.gold.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trophy Case', style: AppTextStyles.heading3.copyWith(color: AppColors.gold)),
                Text(
                  '$unlocked of ${7} trophies earned',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const Spacer(),
            const Icon(CupertinoIcons.chevron_right, color: AppColors.gold, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Species card ──────────────────────────────────────────────────────────────

class _SpeciesCard extends StatelessWidget {
  final List<String> species;
  const _SpeciesCard({required this.species});

  @override
  Widget build(BuildContext context) => Container(
    padding:    const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🦜 Species Encountered', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing:  8,
          runSpacing: 8,
          children: species.map((s) => Container(
            padding:    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:        AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(color: AppColors.secondary.withOpacity(0.4)),
            ),
            child: Text(s, style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
          )).toList(),
        ),
      ],
    ),
  );
}

// ── Privacy Policy button ────────────────────────────────────────────────────

class _PrivacyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PrivacyButton({required this.onTap});

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding:   EdgeInsets.zero,
    onPressed: onTap,
    child: Container(
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.textMuted.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
              Text('How we handle your data',
                  style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          const Icon(CupertinoIcons.chevron_right,
              color: AppColors.textMuted, size: 18),
        ],
      ),
    ),
  );
}

// ── Help button ───────────────────────────────────────────────────────────────

class _HelpButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HelpButton({required this.onTap});

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding:   EdgeInsets.zero,
    onPressed: onTap,
    child: Container(
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.accent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Text('❓', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to Use',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.accent)),
              Text('Tips, tools & calculator guide',
                  style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          const Icon(CupertinoIcons.chevron_right,
              color: AppColors.accent, size: 18),
        ],
      ),
    ),
  );
}
