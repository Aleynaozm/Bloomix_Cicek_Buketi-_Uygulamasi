import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const AuthScreen({super.key, required this.onSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loading = false;

  // Login
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();
  final _loginForm = GlobalKey<FormState>();
  bool _loginObscure = true;

  // Register
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regPass2 = TextEditingController();
  final _regForm = GlobalKey<FormState>();
  bool _regObscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [_loginEmail, _loginPass, _regName, _regEmail, _regPass, _regPass2]) c.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await context.read<AppProvider>().login(_loginEmail.text.trim(), _loginPass.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      widget.onSuccess();
    } else {
      _showError(err);
      // Kullanıcı yoksa Kayıt Ol sekmesine geçirelim
      if (err.contains('kayıtlı kullanıcı yok')) {
        _tab.animateTo(1);
        _regEmail.text = _loginEmail.text.trim();
      }
    }
  }

  Future<void> _register() async {
    if (!_regForm.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await context.read<AppProvider>().register(
      _regName.text.trim(),
      _regEmail.text.trim(),
      _regPass.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      _showSuccess('Kayıt başarılı! Hoş geldin 🌸');
      widget.onSuccess();
    } else {
      _showError(err);
      // E-posta zaten kayıtlıysa Giriş Yap sekmesine geçirelim
      if (err.contains('zaten kayıtlı')) {
        _tab.animateTo(0);
        _loginEmail.text = _regEmail.text.trim();
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const BloomixLogo(size: 32),
              const SizedBox(height: 8),
              Text('İsminden bir buket yarat', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),

              // Tab bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.rose,
                  unselectedLabelColor: AppColors.textLight,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [Tab(text: 'Giriş Yap'), Tab(text: 'Kayıt Ol')],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tab,
                  children: [_loginForm_(context), _registerForm_(context)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm_(BuildContext context) {
    return Form(
      key: _loginForm,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined, size: 20)),
            validator: (v) => v == null || !v.contains('@') ? 'Geçerli e-posta girin' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPass,
            obscureText: _loginObscure,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_loginObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _loginObscure = !_loginObscure),
              ),
            ),
            validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPassword(context),
              child: Text('Şifremi Unuttum', style: TextStyle(color: AppColors.rose, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Giriş Yap', onPressed: _login, loading: _loading),
          const SizedBox(height: 20),
          _Divider(),
          const SizedBox(height: 20),
          _GoogleButton(),
        ],
      ),
    );
  }

  Widget _registerForm_(BuildContext context) {
    return Form(
      key: _regForm,
      child: Column(
        children: [
          TextFormField(
            controller: _regName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline, size: 20)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Ad soyad gerekli' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined, size: 20)),
            validator: (v) => v == null || !v.contains('@') ? 'Geçerli e-posta girin' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPass,
            obscureText: _regObscure,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_regObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _regObscure = !_regObscure),
              ),
            ),
            validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPass2,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Şifre Tekrar', prefixIcon: Icon(Icons.lock_outline, size: 20)),
            validator: (v) => v != _regPass.text ? 'Şifreler eşleşmiyor' : null,
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Kayıt Ol', onPressed: _register, loading: _loading),
        ],
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Şifreni Sıfırla', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('E-posta adresine sıfırlama bağlantısı göndereceğiz.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined, size: 20))),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Bağlantı Gönder',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Sıfırlama bağlantısı gönderildi (temsili)'),
                  backgroundColor: AppColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('veya', style: TextStyle(color: AppColors.textLight, fontSize: 13))),
      const Expanded(child: Divider()),
    ]);
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Google ile giriş (temsili)'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.red.shade600)),
          const SizedBox(width: 10),
          const Text('Google ile Devam Et'),
        ]),
      ),
    );
  }
}
