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

/// Full-screen slideshow used when [kScreenshotMode] is true.
///
/// • Auto-advances every 4 s
/// • Tap → next slide immediately (timer resets)
/// • Long press → restart from slide 0 (timer resets)
/// • No progress indicators or overlays – pure app UI
class ScreenshotSlideshow extends StatefulWidget {
  const ScreenshotSlideshow({super.key});

  @override
  State<ScreenshotSlideshow> createState() => _ScreenshotSlideshowState();
}

class _ScreenshotSlideshowState extends State<ScreenshotSlideshow> {
  int    _index = 0;
  Timer? _timer;

  // Tab indices: Canvas=0, Schemes=1, Calculate=2, Awards=3, Profile=4
  // -1 means no bottom bar (e.g. pushed screen)
  static const List<int> _tabIndices = [1, 0, 3, 4, -1, 2];

  List<Widget> get _slides => [
    SchemesScreen(onSchemeTap: (_) {}),
    CanvasScreen(
      key:           const ValueKey('demo_canvas'),
      initialScheme: DemoData.schemes.first,
      onSchemeOpened: (_) {},
    ),
    const AchievementsScreen(),
    const ProfileScreen(),
    const TrophiesScreen(),
    const CalculatorScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _advance();
    });
  }

  void _advance() {
    if (!mounted) return;
    setState(() => _index = (_index + 1) % _tabIndices.length);
  }

  void _onTap() {
    _advance();
    _startTimer();
  }

  void _onLongPress() {
    setState(() => _index = 0);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = _tabIndices[_index];
    final slides   = _slides;

    return GestureDetector(
      behavior:    HitTestBehavior.opaque,
      onTap:       _onTap,
      onLongPress: _onLongPress,
      child: AnimatedBackground(
        child: Column(
          children: [
            Expanded(
              child: KeyedSubtree(
                key:   ValueKey(_index),
                child: slides[_index],
              ),
            ),
            if (tabIndex >= 0)
              BottomNavBar(
                selectedIndex: tabIndex,
                onTabChanged:  (_) {},
              ),
          ],
        ),
      ),
    );
  }
}
