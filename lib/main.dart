import 'package:flutter/cupertino.dart';
import 'screens/splash_screen.dart';
import 'services/gamification_service.dart';
import 'services/storage_service.dart';
import 'services/appsflyer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await GamificationService.instance.init();
  AppsFlyerService.instance.trackAppLaunch();
  runApp(const AviaryCanvasApp());
}

class AviaryCanvasApp extends StatelessWidget {
  const AviaryCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Aviary Canvas',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFF4A261),
        scaffoldBackgroundColor: Color(0xFF0D1B2A),
      ),
      home: SplashScreen(),
    );
  }
}
