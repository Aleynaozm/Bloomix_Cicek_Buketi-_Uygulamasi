import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase yapılandırması ve auth helper'ları.
///
/// İlk açılışta `SupabaseService.init()` çağrılmalı (main'de runApp'ten önce).
/// Sonra `SupabaseService.client` ile her yerde erişilebilir.
class SupabaseService {
  // ══════════════════════════════════════════════════════════════════════════
  // YAPILANDIRMA — Bu iki değeri Supabase Dashboard → Project Settings → API'den al.
  // İdeal olarak --dart-define ile build-time'da geçirilir; aşağıda fallback default var.
  // Build sırasında: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // ══════════════════════════════════════════════════════════════════════════
  static const String _url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://imuhreosceixmnefwdqt.supabase.co',
  );
  static const String _anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImltdWhyZW9zY2VpeG1uZWZ3ZHF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MzMxOTAsImV4cCI6MjA5MzIwOTE5MH0.vY-itExVeI9qwTbwNYJ0vE0b19MopNQwHFOSsGFH4go',
  );

  // Google Sign-In iOS OAuth client ID — Info.plist GIDClientID ile eşleşmeli.
  // Reverse client ID (URL scheme): com.googleusercontent.apps.{id}
  // Client ID: {id}.apps.googleusercontent.com
  static const String _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '540154424800-jggniav15br88p1cbkdaglcbccfn755j.apps.googleusercontent.com',
  );

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  /// `main()` içinde runApp'ten ÖNCE çağır.
  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // ── Session getters ──────────────────────────────────────────────────────
  static Session? get currentSession => auth.currentSession;
  static User? get currentUser => auth.currentUser;
  static bool get isLoggedIn => currentSession != null;

  /// Auth durumu değişimleri (giriş, çıkış, token yenileme) için stream.
  static Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;

  // ── Email / Password ─────────────────────────────────────────────────────

  /// E-posta + şifre ile giriş. Hata varsa AuthException fırlatır.
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// E-posta + şifre ile kayıt. Başarılı olursa profiles tablosuna da ekler.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName},
    );
    final user = res.user;
    if (user != null) {
      await _upsertProfile(userId: user.id, email: user.email ?? email, fullName: fullName);
    }
    return res;
  }

  /// Şifre sıfırlama bağlantısı gönder.
  static Future<void> sendPasswordReset(String email) async {
    await auth.resetPasswordForEmail(email.trim());
  }

  // ── Google ───────────────────────────────────────────────────────────────

  /// Google ile giriş — native flow (google_sign_in + signInWithIdToken).
  ///
  static Future<AuthResponse> signInWithGoogle() async {
    // Önceki oturumu temizle — state karışmaması için
    final googleSignIn = GoogleSignIn(
      clientId: _googleIosClientId,
    );
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // Kullanıcı popup'ı kapattı — sessizce çık
      throw const AuthException('Google girişi iptal edildi.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken    = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException(
        'Google ID token alınamadı. '
        'Supabase Dashboard → Auth → Providers → Google\'da '
        'iOS Client ID\'nin eklendiğinden emin ol.',
      );
    }

    final res = await auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = res.user;
    if (user != null) {
      await _upsertProfile(
        userId: user.id,
        email: user.email ?? googleUser.email,
        fullName: googleUser.displayName ?? '',
      );
    }
    return res;
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await auth.signOut();
  }

  // ── Profiles tablosu ─────────────────────────────────────────────────────

  /// `profiles` tablosuna upsert. Tablonun şeması SETUP_AUTH.md'de.
  static Future<void> _upsertProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await client.from('profiles').upsert({
        'id': userId,
        'email': email,
        if (fullName.isNotEmpty) 'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // RLS veya ağ hatasını sessizce yut — auth zaten başarılı.
      if (kDebugMode) print('Profile upsert hatası: $e');
    }
  }

  /// Mevcut kullanıcının profilini getir (yoksa null).
  static Future<Map<String, dynamic>?> fetchCurrentProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final res = await client.from('profiles').select().eq('id', uid).maybeSingle();
    return res;
  }

  /// Profil güncelle (örn. ad).
  static Future<void> updateProfile({String? fullName}) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await client.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }
}
