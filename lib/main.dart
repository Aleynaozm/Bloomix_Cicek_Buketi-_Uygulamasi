import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/supabase_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Supabase'i runApp'ten ÖNCE başlat
  await SupabaseService.init();

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

/// Splash → Onboarding → AuthGate akışı.
///
/// Splash ve onboarding sadece UI flow için lokal stage tutuyor.
/// Auth durumu artık Supabase tarafından yönetiliyor (AuthGate içinde).
class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  // 0 = splash, 1 = onboarding, 2 = auth gate (login veya main)
  int _stage = 0;

  void _showOnboardingAgain() {
    setState(() => _stage = 1);
  }

  void _onSplashDone() {
    setState(() => _stage = 1);
  }

  void _onOnboardingDone() {
    setState(() => _stage = 2);
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case 0:
        return SplashScreen(onDone: _onSplashDone);
      case 1:
        return OnboardingScreen(onDone: _onOnboardingDone);
      default:
        return AuthGate(onShowOnboarding: _showOnboardingAgain);
    }
  }
}
