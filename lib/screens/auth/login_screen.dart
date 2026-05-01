import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loadingEmail = false;
  bool _loadingGoogle = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loadingEmail = true);
    try {
      await SupabaseService.signInWithPassword(
        email: _email.text,
        password: _password.text,
      );
      // AuthGate stream'i otomatik olarak yönlendirir; burada navigation yok.
    } on AuthException catch (e) {
      _showError(_friendlyError(e));
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _loadingEmail = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loadingGoogle = true);
    try {
      await SupabaseService.signInWithGoogle();
    } on AuthException catch (e) {
      _showError(_friendlyError(e));
    } catch (e) {
      _showError('Google girişi başarısız: $e');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  String _friendlyError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('email not confirmed')) {
      return 'E-postanı doğrulaman gerekiyor. Gelen kutunu kontrol et.';
    }
    if (msg.contains('user not found')) {
      return 'Bu e-posta ile kayıtlı kullanıcı yok.';
    }
    return e.message;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController(text: _email.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Şifreni Sıfırla',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('E-posta adresine sıfırlama bağlantısı göndereceğiz.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Bağlantı Gönder',
              onPressed: () async {
                final email = ctrl.text.trim();
                if (!email.contains('@')) {
                  ScaffoldMessenger.of(sheetCtx).showSnackBar(
                    const SnackBar(content: Text('Geçerli bir e-posta gir.')),
                  );
                  return;
                }
                Navigator.pop(sheetCtx);
                try {
                  await SupabaseService.sendPasswordReset(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Sıfırlama bağlantısı gönderildi.'),
                      backgroundColor: AppColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                } catch (e) {
                  _showError('Bağlantı gönderilemedi: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Center(child: BloomixLogo(size: 32)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Hoş geldin, devam etmek için giriş yap',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 36),

                // ─ OAuth butonu — web'de Client ID gerektiği için gizliyoruz ─
                if (!kIsWeb) ...[
                  _SocialButton(
                    label: 'Google ile Devam Et',
                    loading: _loadingGoogle,
                    icon: const _GoogleIcon(),
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(height: 24),
                  _OrDivider(),
                  const SizedBox(height: 24),
                ],

                // ─ Email / şifre ─
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Geçerli e-posta girin'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'En az 6 karakter' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    child: Text('Şifremi Unuttum',
                        style: TextStyle(color: AppColors.rose, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Giriş Yap',
                  onPressed: _signInWithEmail,
                  loading: _loadingEmail,
                ),

                const SizedBox(height: 24),

                // ─ Kayıt yönlendirme ─
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabın yok mu?',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 14)),
                    TextButton(
                      onPressed: _goToSignup,
                      child: Text('Kayıt Ol',
                          style: TextStyle(
                              color: AppColors.rose,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Yardımcı widget'lar ─────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool loading;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    // Basit Google "G" — istersen bir SVG ile değiştir.
    return SizedBox(
      width: 22, height: 22,
      child: Center(
        child: Text('G',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.red.shade600,
              height: 1,
            )),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('veya',
            style: TextStyle(color: AppColors.textLight, fontSize: 13)),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
