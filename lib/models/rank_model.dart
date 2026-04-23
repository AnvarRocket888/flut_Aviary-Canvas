/// Rank progression model for the gamification system.
class RankModel {
  final int    level;
  final String title;
  final String emoji;
  final int    xpRequired;
  final String description;

  const RankModel({
    required this.level,
    required this.title,
    required this.emoji,
    required this.xpRequired,
    required this.description,
  });

  // ── All ranks ─────────────────────────────────────────────
  static const List<RankModel> allRanks = [
    RankModel(level: 1,  title: 'Egg',              emoji: '🥚', xpRequired: 0,    description: 'Just starting out'),
    RankModel(level: 2,  title: 'Hatchling',        emoji: '🐣', xpRequired: 100,  description: 'Breaking out of the shell'),
    RankModel(level: 3,  title: 'Fledgling',        emoji: '🐥', xpRequired: 300,  description: 'Learning to fly'),
    RankModel(level: 4,  title: 'Nestling',         emoji: '🐤', xpRequired: 600,  description: 'Building the nest'),
    RankModel(level: 5,  title: 'Sparrow',          emoji: '🐦', xpRequired: 1000, description: 'A capable keeper'),
    RankModel(level: 6,  title: 'Robin',            emoji: '🪺', xpRequired: 1500, description: 'Expert nest builder'),
    RankModel(level: 7,  title: 'Jay',              emoji: '🦜', xpRequired: 2200, description: 'Intelligent and resourceful'),
    RankModel(level: 8,  title: 'Falcon',           emoji: '🦅', xpRequired: 3100, description: 'Swift and precise'),
    RankModel(level: 9,  title: 'Eagle',            emoji: '🦁', xpRequired: 4200, description: 'Soaring to new heights'),
    RankModel(level: 10, title: 'Master Aviarist',  emoji: '👑', xpRequired: 6000, description: 'The pinnacle of aviary mastery'),
  ];

  /// Returns the rank matching the given XP total.
  static RankModel forXP(int xp) {
    RankModel current = allRanks.first;
    for (final rank in allRanks) {
      if (xp >= rank.xpRequired) {
        current = rank;
      } else {
        break;
      }
    }
    return current;
  }

  /// Returns the next rank above [currentLevel], or null if max rank.
  static RankModel? nextRank(int currentLevel) {
    final idx = allRanks.indexWhere((r) => r.level == currentLevel);
    if (idx < 0 || idx >= allRanks.length - 1) return null;
    return allRanks[idx + 1];
  }

  @override
  String toString() => '$emoji $title';
}
