import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const BloomixApp(),
    ),
  );
}

class BloomixApp extends StatelessWidget {
  const BloomixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloomix',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  // 0 = splash, 1 = onboarding, 2 = auth, 3 = main
  int _stage = 0;

  void _showOnboardingAgain() {
    setState(() => _stage = 1);
  }

  void _onSplashDone() {
    setState(() => _stage = 1);
  }

  void _onOnboardingDone() {
    final loggedIn = context.read<AppProvider>().isLoggedIn;
    setState(() => _stage = loggedIn ? 3 : 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == 0) {
      return SplashScreen(onDone: _onSplashDone);
    }
    if (_stage == 1) {
      return OnboardingScreen(onDone: _onOnboardingDone);
    }
    if (_stage == 2) {
      return AuthScreen(onSuccess: () => setState(() => _stage = 3));
    }
    return MainShell(onShowOnboarding: _showOnboardingAgain);
  }
}
