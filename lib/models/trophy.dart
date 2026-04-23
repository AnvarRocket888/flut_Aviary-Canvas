import 'package:flutter/cupertino.dart';

/// Trophy definition – milestone awards shown on the Trophies screen.
class Trophy {
  final String     id;
  final String     title;
  final String     description;
  final String     emoji;
  final TrophyTier tier;
  final int        xpReward;

  const Trophy({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.tier,
    required this.xpReward,
  });

  static const List<Trophy> all = [
    Trophy(
      id:          'bronze_nest',
      title:       'Bronze Nest',
      description: 'Complete your first 5 aviary schemes.',
      emoji:       '🪹',
      tier:        TrophyTier.bronze,
      xpReward:    50,
    ),
    Trophy(
      id:          'silver_wing',
      title:       'Silver Wing',
      description: 'Reach the Falcon rank.',
      emoji:       '🪶',
      tier:        TrophyTier.silver,
      xpReward:    100,
    ),
    Trophy(
      id:          'golden_feather',
      title:       'Golden Feather',
      description: 'Reach the Eagle rank.',
      emoji:       '✨',
      tier:        TrophyTier.gold,
      xpReward:    200,
    ),
    Trophy(
      id:          'diamond_aviary',
      title:       'Diamond Aviary',
      description: 'Reach the Master Aviarist rank.',
      emoji:       '💎',
      tier:        TrophyTier.diamond,
      xpReward:    500,
    ),
    Trophy(
      id:          'streak_champion',
      title:       'Streak Champion',
      description: 'Maintain a 30-day login streak.',
      emoji:       '🔥',
      tier:        TrophyTier.gold,
      xpReward:    150,
    ),
    Trophy(
      id:          'grand_designer',
      title:       'Grand Designer',
      description: 'Create 20 aviary schemes.',
      emoji:       '🏛️',
      tier:        TrophyTier.silver,
      xpReward:    100,
    ),
    Trophy(
      id:          'calculation_master',
      title:       'Calculation Master',
      description: 'Run 50 calculations in the aviary calculator.',
      emoji:       '📊',
      tier:        TrophyTier.silver,
      xpReward:    100,
    ),
  ];
}

enum TrophyTier { bronze, silver, gold, diamond }

extension TrophyTierX on TrophyTier {
  String get label {
    switch (this) {
      case TrophyTier.bronze:  return 'Bronze';
      case TrophyTier.silver:  return 'Silver';
      case TrophyTier.gold:    return 'Gold';
      case TrophyTier.diamond: return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
      case TrophyTier.bronze:  return const Color(0xFFCD7F32);
      case TrophyTier.silver:  return const Color(0xFFC0C0C0);
      case TrophyTier.gold:    return const Color(0xFFFFD166);
      case TrophyTier.diamond: return const Color(0xFF9BFCFE);
    }
  }
}
