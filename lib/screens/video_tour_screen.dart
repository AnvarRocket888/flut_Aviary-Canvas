import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../demo/demo_data.dart';
import '../screens/schemes_screen.dart';
import '../screens/canvas_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trophies_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/animated_background.dart';

/// Automated video tour used when [kVideoTourMode] is true.
///
/// • 7 screens, ~8 s each → ~56 s total
/// • Crossfade transition (AnimatedSwitcher, 500 ms)
/// • Auto-scroll 2 s after each screen switch via PrimaryScrollController
class VideoTourScreen extends StatefulWidget {
  const VideoTourScreen({super.key});

  @override
  State<VideoTourScreen> createState() => _VideoTourScreenState();
}

class _VideoTourScreenState extends State<VideoTourScreen> {
  int              _index          = 0;
  Timer?           _advanceTimer;
  Timer?           _scrollTimer;
  ScrollController _scrollCtrl     = ScrollController();

  // Tab indices – matches slide order below. -1 = no bottom bar.
  static const List<int> _tabIndices = [1, 0, 3, 4, -1, 2, 1];

  /// How long each slide stays on screen.
  static const _slideDuration = Duration(seconds: 8);
  /// Delay before the auto-scroll starts.
  static const _scrollDelay   = Duration(seconds: 2);
  /// Duration of the auto-scroll animation.
  static const _scrollDuration = Duration(seconds: 5);

  // Build slide widgets lazily – each call constructs a fresh widget tree
  // with its own keys so Flutter can cleanly replace states.
  List<Widget> _buildSlides() => [
    SchemesScreen(onSchemeTap: (_) {}),
    CanvasScreen(
      key:            const ValueKey('tour_canvas'),
      initialScheme:  DemoData.schemes.first,
      onSchemeOpened: (_) {},
    ),
    const AchievementsScreen(),
    const ProfileScreen(),
    const TrophiesScreen(),
    const CalculatorScreen(),
    // Second pass of Schemes shows a different scheme selected for variety.
    SchemesScreen(key: const ValueKey('schemes_2'), onSchemeTap: (_) {}),
  ];

  @override
  void initState() {
    super.initState();
    _scheduleAdvance();
    _scheduleScroll();
  }

  // ── Scheduling ────────────────────────────────────────────

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(_slideDuration, _nextSlide);
  }

  void _scheduleScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(_scrollDelay, _autoScroll);
  }

  void _nextSlide() {
    if (!mounted) return;
    final nextIndex = (_index + 1) % _tabIndices.length;
    setState(() {
      _index = nextIndex;
      // Fresh controller for the new slide.
      _scrollCtrl.dispose();
      _scrollCtrl = ScrollController();
    });
    _scheduleAdvance();
    _scheduleScroll();
  }

  void _autoScroll() {
    if (!mounted) return;
    if (!_scrollCtrl.hasClients) return;
    final maxExt = _scrollCtrl.position.maxScrollExtent;
    if (maxExt <= 0) return;
    _scrollCtrl.animateTo(
      maxExt,
      duration: _scrollDuration,
      curve:    Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _scrollTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tabIndex = _tabIndices[_index];
    final slide    = _buildSlides()[_index];

    return AnimatedBackground(
      child: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration:       const Duration(milliseconds: 500),
              switchInCurve:  Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child:   child,
              ),
              child: PrimaryScrollController(
                key:        ValueKey(_index),
                controller: _scrollCtrl,
                child:      slide,
              ),
            ),
          ),
          if (tabIndex >= 0)
            BottomNavBar(
              selectedIndex: tabIndex,
              onTabChanged:  (_) {},
            ),
        ],
      ),
    );
  }
}
