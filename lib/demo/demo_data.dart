import '../models/aviary_scheme.dart';
import '../models/user_profile.dart';
import '../services/gamification_service.dart';
import '../services/storage_service.dart';

/// Rich in-memory demo state used for screenshot and video-tour modes.
/// Nothing here is ever saved to SharedPreferences.
class DemoData {
  DemoData._();

  // ── User profile ─────────────────────────────────────────

  static final UserProfile profile = UserProfile(
    xp:                    5340,
    streakDays:            28,
    lastLoginDate:         _daysAgo(0),
    totalSchemesCreated:   22,
    totalCalculationsRun:  47,
    totalBirdsAdded:       183,
    conflictsResolved:     9,
    unlockedAchievementIds: const [
      'first_blueprint', 'flock_master', 'zone_expert', 'calculator_pro',
      'streak_3', 'streak_7', 'streak_30', 'architect', 'master_architect',
      'eagle_eye', 'space_planner', 'bird_encyclopedia', 'perfect_balance',
      'perch_whisperer', 'digital_aviarist', 'century_club',
    ],
    unlockedTrophyIds: const [
      'bronze_nest', 'silver_wing', 'golden_feather', 'streak_champion',
      'grand_designer', 'calculation_master',
    ],
    usedBirdSpecies: const [
      'Chicken', 'Duck', 'Goose', 'Turkey', 'Quail',
      'Pigeon', 'Parrot', 'Canary', 'Pheasant', 'Guinea Fowl',
    ],
  );

  // ── Schemes ───────────────────────────────────────────────

  static final List<AviaryScheme> schemes = [
    _makeScheme(
      id:         'demo_heritage',
      name:       'Heritage Farm',
      w: 20, h: 15,
      cellAreaM2: 0.5,
      daysAgo:    2,
      birdCounts: {
        'Chicken': 12, 'Duck': 8, 'Goose': 4,
        'Turkey': 3, 'Guinea Fowl': 6,
      },
      zones: [
        // Perimeter – Entry/Exit
        _Z(8,  0,  0, 19,  0),
        _Z(8,  0, 14, 19, 14),
        _Z(8,  0,  0,  0, 14),
        _Z(8, 19,  0, 19, 14),
        // Top-left – Feeding Area
        _Z(1,  1,  1,  8,  4),
        // Top-right – Water Source
        _Z(2, 10,  1, 18,  4),
        // Mid-left – Perch
        _Z(4,  1,  5,  5,  9),
        // Mid-center – Nesting Box
        _Z(3,  6,  5, 13,  9),
        // Mid-right – Dust Bath
        _Z(5, 14,  5, 18,  9),
        // Bottom-left – Exercise Zone
        _Z(6,  1, 10,  9, 13),
        // Bottom-center – Storage
        _Z(7, 10, 10, 13, 13),
        // Bottom-right – Exercise Zone
        _Z(6, 14, 10, 18, 13),
      ],
    ),
    _makeScheme(
      id:         'demo_garden',
      name:       'Garden Sanctuary',
      w: 15, h: 15,
      cellAreaM2: 0.25,
      daysAgo:    9,
      birdCounts: {'Chicken': 8, 'Duck': 5, 'Quail': 12, 'Canary': 4},
      zones: [
        _Z(8,  0,  0, 14,  0),
        _Z(8,  0, 14, 14, 14),
        _Z(8,  0,  0,  0, 14),
        _Z(8, 14,  0, 14, 14),
        _Z(1,  1,  1,  7,  5),
        _Z(2,  8,  1, 13,  3),
        _Z(4,  8,  4, 13,  7),
        _Z(3,  1,  6,  5,  9),
        _Z(6,  6,  6, 13,  9),
        _Z(5,  1, 10,  5, 12),
        _Z(7,  6, 10,  9, 12),
        _Z(6, 10, 10, 13, 12),
      ],
    ),
    _makeScheme(
      id:         'demo_tropical',
      name:       'Tropical Paradise',
      w: 18, h: 12,
      cellAreaM2: 0.3,
      daysAgo:    18,
      birdCounts: {'Parrot': 15, 'Canary': 8, 'Pigeon': 6},
      zones: [
        _Z(8,  0,  0, 17,  0),
        _Z(8,  0, 11, 17, 11),
        _Z(8,  0,  0,  0, 11),
        _Z(8, 17,  0, 17, 11),
        _Z(6,  1,  1,  5,  5),
        _Z(1,  6,  1, 11,  4),
        _Z(2, 12,  1, 16,  4),
        _Z(4,  1,  6,  5, 10),
        _Z(3,  6,  5, 10,  8),
        _Z(5, 11,  5, 16,  8),
        _Z(3,  6,  9, 10, 10),
        _Z(6, 11,  9, 16, 10),
      ],
    ),
    _makeScheme(
      id:         'demo_urban',
      name:       'Compact Urban Coop',
      w: 10, h: 10,
      cellAreaM2: 0.25,
      daysAgo:    32,
      birdCounts: {'Chicken': 18, 'Quail': 10},
      zones: [
        _Z(8,  0,  0,  9,  0),
        _Z(8,  0,  9,  9,  9),
        _Z(8,  0,  0,  0,  9),
        _Z(8,  9,  0,  9,  9),
        _Z(1,  1,  1,  4,  4),
        _Z(2,  5,  1,  8,  3),
        _Z(4,  5,  4,  8,  6),
        _Z(3,  1,  5,  4,  8),
        _Z(6,  5,  7,  8,  8),
        _Z(7,  1,  7,  2,  8),
      ],
    ),
    _makeScheme(
      id:         'demo_rooftop',
      name:       'Rooftop Garden',
      w: 12, h: 14,
      cellAreaM2: 0.25,
      daysAgo:    55,
      birdCounts: {'Pigeon': 12, 'Quail': 8, 'Canary': 5, 'Pheasant': 3},
      zones: [
        _Z(8,  0,  0, 11,  0),
        _Z(8,  0, 13, 11, 13),
        _Z(8,  0,  0,  0, 13),
        _Z(8, 11,  0, 11, 13),
        _Z(1,  1,  1,  5,  4),
        _Z(2,  6,  1, 10,  3),
        _Z(4,  1,  5,  4,  8),
        _Z(3,  5,  5, 10,  8),
        _Z(5,  6,  4, 10,  4),
        _Z(6,  1,  9,  5, 12),
        _Z(7,  6,  9,  9, 12),
        _Z(4, 10,  9, 10, 12),
      ],
    ),
  ];

  // ── Injection ─────────────────────────────────────────────

  /// Loads demo state into the service singletons (in-memory, no disk I/O).
  static void inject() {
    GamificationService.instance.injectDemoProfile(profile);
    StorageService.instance.injectDemoSchemes(schemes);
  }

  // ── Helpers ───────────────────────────────────────────────

  static String _daysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static AviaryScheme _makeScheme({
    required String id,
    required String name,
    required int w,
    required int h,
    required double cellAreaM2,
    required int daysAgo,
    required Map<String, int> birdCounts,
    required List<_Z> zones,
  }) {
    final now      = DateTime.now();
    final created  = now.subtract(Duration(days: daysAgo + 3));
    final updated  = now.subtract(Duration(days: daysAgo));
    final grid     = List.generate(h, (_) => List.filled(w, 0));
    for (final z in zones) {
      for (var y = z.y1; y <= z.y2 && y < h; y++) {
        for (var x = z.x1; x <= z.x2 && x < w; x++) {
          grid[y][x] = z.type;
        }
      }
    }
    return AviaryScheme(
      id:         id,
      name:       name,
      gridWidth:  w,
      gridHeight: h,
      grid:       grid,
      birdCounts: birdCounts,
      cellAreaM2: cellAreaM2,
      createdAt:  created,
      updatedAt:  updated,
    );
  }
}

/// Compact zone rectangle descriptor.
class _Z {
  final int type, x1, y1, x2, y2;
  const _Z(this.type, this.x1, this.y1, this.x2, this.y2);
}
