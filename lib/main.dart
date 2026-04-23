import 'package:flutter/cupertino.dart';
import 'screens/splash_screen.dart';
import 'screens/screenshot_slideshow.dart';
import 'screens/video_tour_screen.dart';
import 'services/gamification_service.dart';
import 'services/storage_service.dart';
import 'services/appsflyer_service.dart';
import 'demo/demo_data.dart';

/// Set to [true] to launch the screenshot slideshow instead of the normal app.
/// Inject rich demo data and auto-advance through all main screens every 4 s.
/// Tap = next slide, long press = restart from beginning.
const bool kScreenshotMode = false;

/// Set to [true] to launch the video-tour player instead of the normal app.
/// Crossfade transitions, ~8 s per screen, auto-scroll on lists.
const bool kVideoTourMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await GamificationService.instance.init();
  if (kScreenshotMode || kVideoTourMode) DemoData.inject();
  AppsFlyerService.instance.trackAppLaunch();
  runApp(const AviaryCanvasApp());
}

class AviaryCanvasApp extends StatelessWidget {
  const AviaryCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Aviary Canvas',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness:              Brightness.dark,
        primaryColor:            Color(0xFFF4A261),
        scaffoldBackgroundColor: Color(0xFF0D1B2A),
      ),
      home: kScreenshotMode
          ? const ScreenshotSlideshow()
          : kVideoTourMode
              ? const VideoTourScreen()
              : const SplashScreen(),
    );
  }
}
