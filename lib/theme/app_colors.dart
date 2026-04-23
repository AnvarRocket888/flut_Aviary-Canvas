import 'package:flutter/cupertino.dart';

/// Central colour palette for Aviary Canvas.
/// All values mirror additional info/color_scheme.css.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const Color background       = Color(0xFF0D1B2A);
  static const Color surface          = Color(0xFF162333);
  static const Color surfaceElevated  = Color(0xFF1F3147);

  // ── Primary – warm amber (golden feathers) ───────────────
  static const Color primary     = Color(0xFFF4A261);
  static const Color primaryDark = Color(0xFFC87941);

  // ── Secondary – forest green (foliage) ───────────────────
  static const Color secondary     = Color(0xFF52B788);
  static const Color secondaryDark = Color(0xFF3A8D68);

  // ── Accent – open sky blue ────────────────────────────────
  static const Color accent     = Color(0xFF90E0EF);
  static const Color accentDark = Color(0xFF48CAE4);

  // ── Gold – achievements / trophies ────────────────────────
  static const Color gold     = Color(0xFFFFD166);
  static const Color goldDark = Color(0xFFE6B800);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EAD6);
  static const Color textSecondary = Color(0xFF9BAFBE);
  static const Color textMuted     = Color(0xFF5C7A8A);

  // ── UI chrome ─────────────────────────────────────────────
  static const Color border  = Color(0xFF2E4560);
  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF52B788);
  static const Color streak  = Color(0xFFFF6B6B);

  // ── Grid ──────────────────────────────────────────────────
  static const Color gridLine       = Color(0xFF2E4560);
  static const Color gridBackground = Color(0xFF0F2035);

  // ── Zone colours (zone type index 1-8) ────────────────────
  static const Color zoneFeed     = Color(0xFFFFB347); // 1
  static const Color zoneWater    = Color(0xFF5BB8D4); // 2
  static const Color zoneNest     = Color(0xFF98C379); // 3
  static const Color zonePerch    = Color(0xFFC678DD); // 4
  static const Color zoneDust     = Color(0xFFD4A574); // 5
  static const Color zoneExercise = Color(0xFF61AFEF); // 6
  static const Color zoneStorage  = Color(0xFFABB2BF); // 7
  static const Color zoneEntry    = Color(0xFFE06C75); // 8

  /// Returns the fill colour for a given zone type index (0 = transparent).
  static Color zoneColor(int type) {
    switch (type) {
      case 1: return zoneFeed;
      case 2: return zoneWater;
      case 3: return zoneNest;
      case 4: return zonePerch;
      case 5: return zoneDust;
      case 6: return zoneExercise;
      case 7: return zoneStorage;
      case 8: return zoneEntry;
      default: return const Color(0x00000000);
    }
  }
}
