import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../main/main_shell.dart';
import 'welcome_screen.dart';

/// Uygulamanın kök yönlendiricisi.
///
/// Supabase auth state stream'ini dinler:
/// - Session varsa → MainShell (anasayfa)
/// - Yoksa → WelcomeScreen (kullanıcı oradan Login veya Signup'a push'lar)
///
/// İlk başta mevcut session kontrol edilir (cold start). Sonra her auth
/// değişikliği (login, logout, token refresh) anlık olarak yansır;
/// auth başarılı olduğunda Welcome → Login/Signup üstüne pop edilir,
/// AuthGate yeniden build olunca MainShell render edilir.
class AuthGate extends StatelessWidget {
  /// Onboarding'i tekrar göstermek için callback (home'da help button).
  final VoidCallback? onShowOnboarding;

  const AuthGate({super.key, this.onShowOnboarding});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.onAuthStateChange,
      builder: (context, snapshot) {
        // Cold start: snapshot henüz event almadıysa doğrudan currentSession'a bak.
        final session = snapshot.data?.session ?? SupabaseService.currentSession;

        if (session != null) {
          return MainShell(onShowOnboarding: onShowOnboarding);
        }
        return WelcomeScreen(onBack: onShowOnboarding);
      },
    );
  }
}
