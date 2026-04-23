/// Achievement definition and category.
class Achievement {
  final String              id;
  final String              title;
  final String              description;
  final String              emoji;
  final AchievementCategory category;
  final int                 xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.xpReward,
  });

  // ── 17 achievements ───────────────────────────────────────
  static const List<Achievement> all = [
    Achievement(
      id:          'first_blueprint',
      title:       'First Blueprint',
      description: 'Create your very first aviary scheme.',
      emoji:       '📐',
      category:    AchievementCategory.design,
      xpReward:    30,
    ),
    Achievement(
      id:          'flock_master',
      title:       'Flock Master',
      description: 'Add 10 or more birds to a single scheme.',
      emoji:       '🐦',
      category:    AchievementCategory.design,
      xpReward:    30,
    ),
    Achievement(
      id:          'zone_expert',
      title:       'Zone Expert',
      description: 'Use all 8 zone types in one scheme.',
      emoji:       '🗺️',
      category:    AchievementCategory.design,
      xpReward:    50,
    ),
    Achievement(
      id:          'calculator_pro',
      title:       'Calculator Pro',
      description: 'Run 10 calculations in the aviary calculator.',
      emoji:       '🧮',
      category:    AchievementCategory.calculation,
      xpReward:    30,
    ),
    Achievement(
      id:          'streak_3',
      title:       'Dedicated Keeper',
      description: 'Log in 3 days in a row.',
      emoji:       '🔥',
      category:    AchievementCategory.streak,
      xpReward:    30,
    ),
    Achievement(
      id:          'streak_7',
      title:       'Veteran Keeper',
      description: 'Maintain a 7-day login streak.',
      emoji:       '⚡',
      category:    AchievementCategory.streak,
      xpReward:    50,
    ),
    Achievement(
      id:          'streak_30',
      title:       'Grand Master Keeper',
      description: 'Maintain a 30-day login streak.',
      emoji:       '🌟',
      category:    AchievementCategory.streak,
      xpReward:    100,
    ),
    Achievement(
      id:          'architect',
      title:       'Architect',
      description: 'Create 5 different aviary schemes.',
      emoji:       '🏗️',
      category:    AchievementCategory.design,
      xpReward:    30,
    ),
    Achievement(
      id:          'master_architect',
      title:       'Master Architect',
      description: 'Create 20 different aviary schemes.',
      emoji:       '🏛️',
      category:    AchievementCategory.design,
      xpReward:    80,
    ),
    Achievement(
      id:          'eagle_eye',
      title:       'Eagle Eye',
      description: 'Detect and resolve 5 zone conflicts.',
      emoji:       '🦅',
      category:    AchievementCategory.calculation,
      xpReward:    40,
    ),
    Achievement(
      id:          'space_planner',
      title:       'Space Planner',
      description: 'Cover 50 or more cells in a single scheme.',
      emoji:       '📏',
      category:    AchievementCategory.design,
      xpReward:    30,
    ),
    Achievement(
      id:          'bird_encyclopedia',
      title:       'Bird Encyclopedia',
      description: 'Add 5 different bird species across your schemes.',
      emoji:       '📚',
      category:    AchievementCategory.collection,
      xpReward:    40,
    ),
    Achievement(
      id:          'perfect_balance',
      title:       'Perfect Balance',
      description: 'Create a scheme with all green (optimal) calculations.',
      emoji:       '⚖️',
      category:    AchievementCategory.calculation,
      xpReward:    60,
    ),
    Achievement(
      id:          'perch_whisperer',
      title:       'The Perch Whisperer',
      description: 'Use the perch calculator for at least one scheme.',
      emoji:       '🪵',
      category:    AchievementCategory.calculation,
      xpReward:    20,
    ),
    Achievement(
      id:          'digital_aviarist',
      title:       'Digital Aviarist',
      description: 'Reach the Master Aviarist rank.',
      emoji:       '🎖️',
      category:    AchievementCategory.rank,
      xpReward:    50,
    ),
    Achievement(
      id:          'century_club',
      title:       'Century Club',
      description: 'Add a total of 100 birds across all schemes.',
      emoji:       '💯',
      category:    AchievementCategory.collection,
      xpReward:    60,
    ),
    Achievement(
      id:          'falcon_rank',
      title:       'Feather Weight Champion',
      description: 'Reach the Falcon rank.',
      emoji:       '🏆',
      category:    AchievementCategory.rank,
      xpReward:    50,
    ),
  ];
}

enum AchievementCategory { design, calculation, streak, collection, rank }

extension AchievementCategoryX on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.design:      return 'Design';
      case AchievementCategory.calculation: return 'Calculation';
      case AchievementCategory.streak:      return 'Streak';
      case AchievementCategory.collection:  return 'Collection';
      case AchievementCategory.rank:        return 'Rank';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementCategory.design:      return '🎨';
      case AchievementCategory.calculation: return '🧮';
      case AchievementCategory.streak:      return '🔥';
      case AchievementCategory.collection:  return '📚';
      case AchievementCategory.rank:        return '🏅';
    }
  }
}
