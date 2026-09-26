import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/domain_screen.dart';
import 'screens/topic_screen.dart';
import 'screens/model_info_screen.dart';
import 'screens/viewer_3d_screen.dart';
import 'screens/ar_screens.dart';
import 'screens/quiz_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const LearnARApp(),
    ),
  );
}

class LearnARApp extends StatelessWidget {
  const LearnARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Learn AR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainShell(),
        '/domain': (context) => const DomainScreen(),
        '/topic': (context) => const TopicScreen(),
        '/model_info': (context) => const ModelInfoScreen(),
        '/viewer_3d': (context) => const Viewer3DScreen(),
        '/ar_start': (context) => const ARModeStartScreen(),
        '/ar_scanning': (context) => const ARScanningScreen(),
        '/ar_placement': (context) => const ARPlacementScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
