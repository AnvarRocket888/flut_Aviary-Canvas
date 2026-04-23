/// App-wide constants.
class AppConstants {
  AppConstants._();

  // ── App identity ──────────────────────────────────────────
  static const String appName    = 'Aviary Canvas';
  static const String appTagline = 'Design your perfect bird sanctuary';
  static const String splashDesc =
      'Plan, design and optimise your bird enclosure with precision drawing tools and smart aviary calculations.';

  // ── Grid ──────────────────────────────────────────────────
  static const int    defaultGridWidth  = 15;
  static const int    defaultGridHeight = 15;
  static const double cellAreaM2        = 0.25; // each cell = 0.5 m × 0.5 m

  // ── Timings ───────────────────────────────────────────────
  static const Duration splashHold          = Duration(seconds: 5);
  static const Duration fadeOutDuration     = Duration(milliseconds: 700);
  static const Duration toastDuration       = Duration(seconds: 3);
  static const Duration pageTransition      = Duration(milliseconds: 380);
  static const Duration cardEntrance        = Duration(milliseconds: 350);
  static const Duration xpAnimDuration      = Duration(milliseconds: 750);
  static const Duration celebrationDuration = Duration(seconds: 3);

  // ── XP rewards ────────────────────────────────────────────
  static const int xpCreateScheme  = 50;
  static const int xpSaveScheme    = 10;
  static const int xpRunCalc       = 20;
  static const int xpDailyLogin    = 15;
  static const int xpStreakBonus   = 25;
  static const int xpExportScheme  = 15;

  // ── Bird species – min space per bird (m²) ────────────────
  static const Map<String, double> minSpacePerBird = {
    'Chicken':     0.50,
    'Duck':        0.75,
    'Goose':       1.50,
    'Turkey':      2.00,
    'Quail':       0.20,
    'Pigeon':      0.40,
    'Parrot':      0.60,
    'Canary':      0.15,
    'Pheasant':    2.50,
    'Guinea Fowl': 1.00,
  };

  // ── Birds per one feeder unit ─────────────────────────────
  static const Map<String, int> feedersPerBirds = {
    'Chicken':     10,
    'Duck':         8,
    'Goose':        5,
    'Turkey':       6,
    'Quail':       15,
    'Pigeon':      12,
    'Parrot':       3,
    'Canary':       5,
    'Pheasant':     5,
    'Guinea Fowl':  8,
  };

  // ── Perch length needed per bird (m, 0 = doesn't perch) ──
  static const Map<String, double> perchLengthPerBird = {
    'Chicken':     0.25,
    'Duck':        0.00,
    'Goose':       0.00,
    'Turkey':      0.45,
    'Quail':       0.15,
    'Pigeon':      0.20,
    'Parrot':      0.30,
    'Canary':      0.10,
    'Pheasant':    0.35,
    'Guinea Fowl': 0.30,
  };

  // ── Zone type names (index 0-8) ───────────────────────────
  static const Map<int, String> zoneLabels = {
    0: 'Empty',
    1: 'Feeding Area',
    2: 'Water Source',
    3: 'Nesting Box',
    4: 'Perch',
    5: 'Dust Bath',
    6: 'Exercise Zone',
    7: 'Storage',
    8: 'Entry / Exit',
  };

  static const Map<int, String> zoneEmojis = {
    0: '⬜',
    1: '🌾',
    2: '💧',
    3: '🥚',
    4: '🪵',
    5: '🌿',
    6: '🏃',
    7: '📦',
    8: '🚪',
  };

  static const List<String> allSpecies = [
    'Chicken', 'Duck', 'Goose', 'Turkey', 'Quail',
    'Pigeon', 'Parrot', 'Canary', 'Pheasant', 'Guinea Fowl',
  ];
}
