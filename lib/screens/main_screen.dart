import 'package:flutter/cupertino.dart';
import '../models/achievement.dart';
import '../models/aviary_scheme.dart';
import '../models/rank_model.dart';
// ignore: unused_import
import '../models/trophy.dart';
import '../services/gamification_service.dart';
import '../widgets/achievement_toast.dart';
import '../widgets/animated_background.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/rankup_celebration.dart';
import 'achievements_screen.dart';
import 'calculator_screen.dart';
import 'canvas_screen.dart';
import 'profile_screen.dart';
import 'schemes_screen.dart';

/// Root screen with custom bottom navigation and gamification overlays.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabIndex = 0;

  // Current scheme shared between Canvas and Schemes tabs
  AviaryScheme? _activeScheme;

  // Gamification overlays
  Achievement? _pendingAchievement;
  RankModel?   _pendingRank;
  bool         _showRankUp = false;

  @override
  void initState() {
    super.initState();
    final gami = GamificationService.instance;

    gami.onAchievementUnlocked = (a) {
      if (!mounted) return;
      // Queue achievements one at a time; show next after current dismisses
      setState(() {
        if (_pendingAchievement == null) _pendingAchievement = a;
      });
    };

    gami.onRankUp = (r) {
      if (!mounted) return;
      setState(() {
        _pendingRank = r;
        _showRankUp  = true;
      });
    };

    gami.onTrophyEarned = (t) {
      // Trophies are shown on the Trophies screen; just trigger a subtle notification
      // via the achievement toast channel using a synthesised Achievement object
      if (!mounted) return;
      final fakeAch = Achievement(
        id:          t.id,
        title:       t.title,
        description: t.description,
        emoji:       t.emoji,
        category:    AchievementCategory.rank,
        xpReward:    t.xpReward,
      );
      setState(() {
        if (_pendingAchievement == null) _pendingAchievement = fakeAch;
      });
    };
  }

  @override
  void dispose() {
    GamificationService.instance.onAchievementUnlocked = null;
    GamificationService.instance.onRankUp              = null;
    GamificationService.instance.onTrophyEarned        = null;
    super.dispose();
  }

  void _openScheme(AviaryScheme scheme) {
    setState(() {
      _activeScheme = scheme;
      _tabIndex     = 0;
    });
  }

  Widget _buildCurrentTab() {
    switch (_tabIndex) {
      case 0:
        return CanvasScreen(
          key:         ValueKey(_activeScheme?.id ?? 'canvas'),
          initialScheme: _activeScheme,
          onSchemeOpened: (s) => setState(() => _activeScheme = s),
        );
      case 1:
        return SchemesScreen(onSchemeTap: _openScheme);
      case 2:
        return const CalculatorScreen();
      case 3:
        return const AchievementsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const CanvasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      child: Stack(
        children: [
          // Background
          const Positioned.fill(
            child: AnimatedBackground(child: SizedBox.expand()),
          ),
          // Tab content + nav bar
          Column(
            children: [
              Expanded(child: _buildCurrentTab()),
              BottomNavBar(
                selectedIndex: _tabIndex,
                onTabChanged:  (i) => setState(() => _tabIndex = i),
              ),
            ],
          ),
          // Achievement toast
          if (_pendingAchievement != null)
            AchievementToast(
              achievement: _pendingAchievement!,
              onDismissed: () => setState(() => _pendingAchievement = null),
            ),
          // Rank-up celebration
          if (_showRankUp && _pendingRank != null)
            Positioned.fill(
              child: RankUpCelebration(
                newRank:     _pendingRank!,
                onDismissed: () => setState(() {
                  _showRankUp  = false;
                  _pendingRank = null;
                }),
              ),
            ),
        ],
      ),
    );
  }
}
