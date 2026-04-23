import '../models/user_profile.dart';
import '../models/achievement.dart';
import '../models/trophy.dart';
import '../models/rank_model.dart';
import '../utils/constants.dart';
import 'storage_service.dart';
import 'appsflyer_service.dart';

/// Central XP / rank / achievement / trophy manager.
/// Holds the single source of truth for [UserProfile].
class GamificationService {
  static final GamificationService instance = GamificationService._();
  GamificationService._();

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  // ── UI callbacks ──────────────────────────────────────────
  void Function(Achievement)?  onAchievementUnlocked;
  void Function(RankModel)?    onRankUp;
  void Function(Trophy)?       onTrophyEarned;

  // ── Init ──────────────────────────────────────────────────

  Future<void> init() async {
    _profile = await StorageService.instance.loadUserProfile();
    _handleDailyLogin();
  }

  // ── Daily login / streak ──────────────────────────────────

  void _handleDailyLogin() {
    final today = _dateStr(DateTime.now());
    if (_profile.lastLoginDate == today) return;

    int newStreak = _profile.streakDays;
    if (_profile.lastLoginDate != null) {
      final last = DateTime.parse(_profile.lastLoginDate!);
      final diff = DateTime.now().difference(last).inDays;
      newStreak  = (diff == 1) ? newStreak + 1 : 1;
    } else {
      newStreak = 1;
    }

    _profile = _profile.copyWith(
      lastLoginDate: today,
      streakDays:    newStreak,
    );
    // Award daily login XP without recursing into rank check yet
    _profile = _profile.copyWith(xp: _profile.xp + AppConstants.xpDailyLogin);

    AppsFlyerService.instance.trackDailyLogin({
      'streak':     newStreak,
      'xp_earned':  AppConstants.xpDailyLogin,
    });

    if (newStreak % 7 == 0) {
      _profile = _profile.copyWith(xp: _profile.xp + AppConstants.xpStreakBonus);
      AppsFlyerService.instance.trackStreakMilestone({'streak': newStreak});
    }

    _checkAchievements();
    _checkTrophies();
    _checkRankUp(0);
    _save();
  }

  // ── Public event methods ──────────────────────────────────

  void addXP(int amount, {String reason = ''}) {
    final oldLevel = RankModel.forXP(_profile.xp).level;
    _profile = _profile.copyWith(xp: _profile.xp + amount);
    final newRank = RankModel.forXP(_profile.xp);

    AppsFlyerService.instance.trackXPEarned({
      'amount': amount,
      'reason': reason,
      'total':  _profile.xp,
    });

    if (newRank.level > oldLevel) {
      onRankUp?.call(newRank);
      AppsFlyerService.instance.trackRankUp({
        'new_rank': newRank.title,
        'level':    newRank.level,
      });
    }
    _save();
  }

  void onSchemeCreated({required int totalBirds}) {
    _profile = _profile.copyWith(
      totalSchemesCreated: _profile.totalSchemesCreated + 1,
    );
    addXP(AppConstants.xpCreateScheme, reason: 'scheme_created');
    _checkAchievements();
    _checkTrophies();
    AppsFlyerService.instance.trackSchemeCreated({
      'total': _profile.totalSchemesCreated,
      'birds': totalBirds,
    });
  }

  void onSchemeSaved({
    required int     coveredCells,
    required Set<int> zoneTypes,
    required Map<String, int> birdCounts,
  }) {
    addXP(AppConstants.xpSaveScheme, reason: 'scheme_saved');

    // Award birds-added stats
    int total = birdCounts.values.fold(0, (a, b) => a + b);
    if (total > 0) {
      final newSpecies = birdCounts.keys
          .where((s) => !_profile.usedBirdSpecies.contains(s))
          .toList();
      _profile = _profile.copyWith(
        totalBirdsAdded: _profile.totalBirdsAdded + total,
        usedBirdSpecies: [..._profile.usedBirdSpecies, ...newSpecies],
      );
    }

    if (coveredCells >= 50)  _unlock('space_planner');
    if (zoneTypes.length == 8) _unlock('zone_expert');
    if (total >= 10)         _unlock('flock_master');
    if (_profile.totalBirdsAdded >= 100) _unlock('century_club');
    if (_profile.usedBirdSpecies.length >= 5) _unlock('bird_encyclopedia');

    _checkAchievements();
    _checkTrophies();
    AppsFlyerService.instance.trackSchemeSaved({
      'covered_cells': coveredCells,
      'zone_types':    zoneTypes.length,
    });
  }

  void onCalculationRun({
    bool allGreen     = false,
    bool hasPerchCalc = false,
    bool hadConflict  = false,
  }) {
    _profile = _profile.copyWith(
      totalCalculationsRun: _profile.totalCalculationsRun + 1,
    );
    addXP(AppConstants.xpRunCalc, reason: 'calculation_run');

    if (_profile.totalCalculationsRun >= 10) _unlock('calculator_pro');
    if (allGreen)    _unlock('perfect_balance');
    if (hasPerchCalc) _unlock('perch_whisperer');
    if (hadConflict) {
      _profile = _profile.copyWith(
        conflictsResolved: _profile.conflictsResolved + 1,
      );
      if (_profile.conflictsResolved >= 5) _unlock('eagle_eye');
    }

    _checkTrophies();
    AppsFlyerService.instance.trackCalculationRun({
      'total': _profile.totalCalculationsRun,
    });
  }

  void onSchemeExported() {
    addXP(AppConstants.xpExportScheme, reason: 'export');
    AppsFlyerService.instance.trackSchemeExported({});
  }

  // ── Queries ───────────────────────────────────────────────

  RankModel  getCurrentRank() => RankModel.forXP(_profile.xp);
  RankModel? getNextRank()    => RankModel.nextRank(getCurrentRank().level);

  double getXPProgress() {
    final cur  = getCurrentRank();
    final next = getNextRank();
    if (next == null) return 1.0;
    final inRank  = _profile.xp - cur.xpRequired;
    final toNext  = next.xpRequired - cur.xpRequired;
    return (inRank / toNext).clamp(0.0, 1.0);
  }

  int getXPToNext() {
    final next = getNextRank();
    if (next == null) return 0;
    return (next.xpRequired - _profile.xp).clamp(0, 99999);
  }

  bool isAchievementUnlocked(String id) =>
      _profile.unlockedAchievementIds.contains(id);

  bool isTrophyUnlocked(String id) =>
      _profile.unlockedTrophyIds.contains(id);

  // ── Private helpers ───────────────────────────────────────

  void _checkRankUp(int oldLevel) {
    final newRank = getCurrentRank();
    if (newRank.level > oldLevel) {
      onRankUp?.call(newRank);
      AppsFlyerService.instance.trackRankUp({
        'new_rank': newRank.title,
        'level':    newRank.level,
      });
    }
  }

  void _checkAchievements() {
    final p = _profile;
    if (p.totalSchemesCreated >= 1)  _unlock('first_blueprint');
    if (p.totalSchemesCreated >= 5)  _unlock('architect');
    if (p.totalSchemesCreated >= 20) _unlock('master_architect');
    if (p.streakDays >= 3)           _unlock('streak_3');
    if (p.streakDays >= 7)           _unlock('streak_7');
    if (p.streakDays >= 30)          _unlock('streak_30');

    final rankLevel = getCurrentRank().level;
    if (rankLevel >= 8)  _unlock('falcon_rank');
    if (rankLevel >= 10) _unlock('digital_aviarist');
  }

  void _checkTrophies() {
    final p = _profile;
    if (p.totalSchemesCreated >= 5)   _unlockTrophy('bronze_nest');
    if (p.totalSchemesCreated >= 20)  _unlockTrophy('grand_designer');
    if (p.streakDays >= 30)           _unlockTrophy('streak_champion');
    if (p.totalCalculationsRun >= 50) _unlockTrophy('calculation_master');

    final lvl = getCurrentRank().level;
    if (lvl >= 8)  _unlockTrophy('silver_wing');
    if (lvl >= 9)  _unlockTrophy('golden_feather');
    if (lvl >= 10) _unlockTrophy('diamond_aviary');
  }

  void _unlock(String id) {
    if (_profile.unlockedAchievementIds.contains(id)) return;
    final a = Achievement.all.firstWhere(
      (x) => x.id == id,
      orElse: () => throw StateError('Unknown achievement: $id'),
    );
    _profile = _profile.copyWith(
      unlockedAchievementIds: [..._profile.unlockedAchievementIds, id],
      xp: _profile.xp + a.xpReward,
    );
    onAchievementUnlocked?.call(a);
    AppsFlyerService.instance.trackAchievementUnlocked({
      'id': id, 'title': a.title, 'xp': a.xpReward,
    });
  }

  void _unlockTrophy(String id) {
    if (_profile.unlockedTrophyIds.contains(id)) return;
    final t = Trophy.all.firstWhere(
      (x) => x.id == id,
      orElse: () => throw StateError('Unknown trophy: $id'),
    );
    _profile = _profile.copyWith(
      unlockedTrophyIds: [..._profile.unlockedTrophyIds, id],
      xp: _profile.xp + t.xpReward,
    );
    onTrophyEarned?.call(t);
    AppsFlyerService.instance.trackTrophyEarned({
      'id': id, 'title': t.title,
    });
  }

  Future<void> _save() => StorageService.instance.saveUserProfile(_profile);

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
