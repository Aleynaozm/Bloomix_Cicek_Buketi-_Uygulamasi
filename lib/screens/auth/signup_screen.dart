import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await SupabaseService.signUp(
        email: _email.text,
        password: _password.text,
        fullName: _name.text.trim(),
      );

      if (!mounted) return;

      // Eğer email confirmation kapalıysa, signUp aynı zamanda session açar.
      // Açıksa, kullanıcının e-postasını onaylaması beklenir.
      if (res.session != null) {
        // AuthGate otomatik MainShell'e geçirecek; sadece bu ekranı kapat.
        Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              'Kayıt başarılı! E-posta adresine gelen doğrulama bağlantısına tıkla.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.of(context).pop(); // login'e dön
      }
    } on AuthException catch (e) {
      _showError(_friendlyError(e));
    } catch (e) {
      _showError('Kayıt başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('already registered') || msg.contains('user already')) {
      return 'Bu e-posta zaten kayıtlı. Giriş yap.';
    }
    if (msg.contains('password')) {
      return 'Şifre yeterince güçlü değil (en az 6 karakter).';
    }
    if (msg.contains('invalid email')) {
      return 'Geçersiz e-posta adresi.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Center(child: BloomixLogo(size: 32)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Hesap oluştur ve buketini hazırla',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ad soyad gerekli'
                      : null,
                ),
                const SizedBox(height: 14),
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
                  autofillHints: const [AutofillHints.newPassword],
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
                  validator: (v) => v == null || v.length < 6
                      ? 'En az 6 karakter'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password2,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                  validator: (v) =>
                      v != _password.text ? 'Şifreler eşleşmiyor' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Kayıt Ol',
                  onPressed: _signUp,
                  loading: _loading,
                ),
                const SizedBox(height: 24),

                // Zaten hesabı varsa
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Zaten bir hesabım var',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Giriş Yap',
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
