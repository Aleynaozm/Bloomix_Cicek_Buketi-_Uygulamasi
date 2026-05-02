import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  bool _loading = false;

  final _deliveryForm = GlobalKey<FormState>();
  final _paymentForm = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardNumCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  int _payMethod = 0;
  bool _obscureCvv = true;

  @override
  void dispose() {
    for (final c in [_nameCtrl,_addressCtrl,_phoneCtrl,_emailCtrl,_msgCtrl,_cardNameCtrl,_cardNumCtrl,_cardExpCtrl,_cvvCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      // Sepet kaynaklı checkout — cart boşsa kullanıcı bir önceki ekrana döner.
      if (prov.cart.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sipariş Ver')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🛒', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Sepetin boş', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Önce bir buket tasarlayıp sepete ekle.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
          ),
        );
      }
      final cartItems = prov.cart;
      final cartTotal = prov.cartTotal;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sipariş Ver'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _StepBar(step: _step),
          ),
        ),
        body: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _step == 0
                  ? _DeliveryForm(
                      formKey: _deliveryForm,
                      nameCtrl: _nameCtrl, addressCtrl: _addressCtrl,
                      phoneCtrl: _phoneCtrl, emailCtrl: _emailCtrl, msgCtrl: _msgCtrl)
                  : _step == 1
                      ? _PaymentForm(
                          formKey: _paymentForm,
                          method: _payMethod,
                          onMethodChanged: (v) => setState(() => _payMethod = v),
                          cardNameCtrl: _cardNameCtrl, cardNumCtrl: _cardNumCtrl,
                          cardExpCtrl: _cardExpCtrl, cvvCtrl: _cvvCtrl,
                          obscureCvv: _obscureCvv,
                          onToggleCvv: () => setState(() => _obscureCvv = !_obscureCvv))
                      : _ReviewStep(items: cartItems, total: cartTotal, name: _nameCtrl.text, address: _addressCtrl.text),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
            child: Row(children: [
              if (_step > 0) ...[
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20)),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(child: PrimaryButton(
                label: _step == 0 ? 'Ödeme Adımı' : _step == 1 ? 'İncele' : 'Siparişi Onayla',
                loading: _loading,
                onPressed: () => _next(prov),
              )),
            ]),
          ),
        ]),
      );
    });
  }

  Future<void> _next(AppProvider prov) async {
    if (_step == 0) {
      if (_deliveryForm.currentState!.validate()) setState(() => _step = 1);
    } else if (_step == 1) {
      final valid = _payMethod == 0 ? _paymentForm.currentState!.validate() : true;
      if (valid) setState(() => _step = 2);
    } else {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final order = prov.placeOrder(
        recipientName: _nameCtrl.text, address: _addressCtrl.text,
        phone: _phoneCtrl.text, email: _emailCtrl.text,
        giftMessage: _msgCtrl.text.isEmpty ? null : _msgCtrl.text,
      );
      setState(() => _loading = false);
      if (order == null) return; // cart boştu — bir şey yapma
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)));
    }
  }
}

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) {
    final steps = ['Teslimat', 'Ödeme', 'Onay'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final done = i < step;
          final active = i == step;
          return Expanded(
            child: Row(children: [
              Container(width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || active ? AppColors.rose : AppColors.beige,
                ),
                child: Center(child: done
                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.white)
                    : Text('${i+1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: active ? AppColors.white : AppColors.textLight)))),
              const SizedBox(width: 6),
              Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: active ? AppColors.rose : AppColors.textLight)),
              if (i < steps.length - 1) ...[
                const SizedBox(width: 6),
                Expanded(child: Container(height: 0.5, color: AppColors.border)),
              ],
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, addressCtrl, phoneCtrl, emailCtrl, msgCtrl;
  const _DeliveryForm({required this.formKey, required this.nameCtrl, required this.addressCtrl,
    required this.phoneCtrl, required this.emailCtrl, required this.msgCtrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Teslimat Bilgileri', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Buketi kime gönderelim?', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        _Field(ctrl: nameCtrl, label: 'Ad Soyad', icon: Icons.person_outline,
          validator: (v) => v == null || v.trim().isEmpty ? 'Zorunlu alan' : null),
        const SizedBox(height: 12),
        _Field(ctrl: phoneCtrl, label: 'Telefon', icon: Icons.phone_outlined,
          type: TextInputType.phone,
          validator: (v) => v == null || v.length < 10 ? 'Geçerli telefon' : null),
        const SizedBox(height: 12),
        _Field(ctrl: emailCtrl, label: 'E-posta', icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
          validator: (v) => v == null || !v.contains('@') ? 'Geçerli e-posta' : null),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressCtrl, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Teslimat Adresi',
            alignLabelWithHint: true,
            prefixIcon: Padding(padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on_outlined, size: 20, color: AppColors.textLight))),
          validator: (v) => v == null || v.trim().isEmpty ? 'Adres zorunlu' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: msgCtrl, maxLines: 2,
          decoration: const InputDecoration(labelText: 'Hediye Mesajı (opsiyonel)',
            alignLabelWithHint: true,
            prefixIcon: Padding(padding: EdgeInsets.only(bottom: 20),
              child: Icon(Icons.card_giftcard_outlined, size: 20, color: AppColors.textLight))),
        ),
      ]),
    );
  }
}

class _PaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int method;
  final Function(int) onMethodChanged;
  final TextEditingController cardNameCtrl, cardNumCtrl, cardExpCtrl, cvvCtrl;
  final bool obscureCvv;
  final VoidCallback onToggleCvv;

  const _PaymentForm({required this.formKey, required this.method, required this.onMethodChanged,
    required this.cardNameCtrl, required this.cardNumCtrl, required this.cardExpCtrl,
    required this.cvvCtrl, required this.obscureCvv, required this.onToggleCvv});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'icon': '💳', 'title': 'Kredi / Banka Kartı', 'sub': 'Visa, Mastercard, Troy'},
      {'icon': '🏦', 'title': 'Havale / EFT', 'sub': 'Banka havalesi ile öde'},
      {'icon': '🚪', 'title': 'Kapıda Ödeme', 'sub': 'Teslimatta nakit veya kart'},
    ];

    return Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ödeme Yöntemi', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Bu temsili bir ödemedir — gerçek işlem yapılmaz.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.green, fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),

        ...methods.asMap().entries.map((e) {
          final i = e.key; final m = e.value; final sel = method == i;
          return GestureDetector(
            onTap: () => onMethodChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sel ? AppColors.rose.withOpacity(0.06) : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? AppColors.rose : AppColors.border, width: sel ? 1.5 : 1),
              ),
              child: Row(children: [
                Text(m['icon']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: sel ? AppColors.rose : AppColors.textDark)),
                  Text(m['sub']!, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ])),
                AnimatedContainer(duration: const Duration(milliseconds: 180),
                  width: 20, height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: sel ? AppColors.rose : AppColors.textLight, width: sel ? 6 : 1.5))),
              ]),
            ),
          );
        }),

        if (method == 0) ...[
          const SizedBox(height: 20),
          Text('Kart Bilgileri', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _Field(ctrl: cardNameCtrl, label: 'Kart Sahibinin Adı', icon: Icons.person_outline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Zorunlu' : null),
          const SizedBox(height: 12),
          TextFormField(
            controller: cardNumCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _CardFmt()],
            decoration: const InputDecoration(labelText: 'Kart Numarası', hintText: '0000 0000 0000 0000',
              prefixIcon: Icon(Icons.credit_card_outlined, size: 20, color: AppColors.textLight)),
            validator: (v) => (v?.replaceAll(' ', '').length ?? 0) < 16 ? 'Geçerli kart numarası girin' : null,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(
              controller: cardExpCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), _ExpFmt()],
              decoration: const InputDecoration(labelText: 'AA/YY', hintText: '09/27'),
              validator: (v) => v == null || v.length < 5 ? 'Son kullanma tarihi' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: cvvCtrl,
              keyboardType: TextInputType.number,
              obscureText: obscureCvv,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              decoration: InputDecoration(
                labelText: 'CVV', hintText: '•••',
                suffixIcon: IconButton(icon: Icon(obscureCvv ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                  onPressed: onToggleCvv),
              ),
              validator: (v) => v == null || v.length < 3 ? 'CVV giriniz' : null,
            )),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green.withOpacity(0.3))),
            child: Row(children: [
              Icon(Icons.lock_outline, size: 16, color: AppColors.green),
              const SizedBox(width: 8),
              Expanded(child: Text('Kart bilgilerin işlenmez. Bu okul projesidir.',
                style: TextStyle(fontSize: 11, color: AppColors.green))),
            ]),
          ),
        ],

        if (method == 1) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Banka Bilgileri', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _BankRow('Banka', 'Bloomix Bank (Temsili)'),
              _BankRow('IBAN', 'TR00 0000 0000 0000 0000 00'),
              _BankRow('Ad', 'Bloomix Teknoloji A.Ş.'),
              _BankRow('Açıklama', 'Sipariş no ile havale yapınız'),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label, value;
  const _BankRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _ReviewStep extends StatelessWidget {
  final List<CartItem> items;
  final double total;
  final String name, address;
  const _ReviewStep({required this.items, required this.total, required this.name, required this.address});

  @override
  Widget build(BuildContext context) {
    final totalLego = items.fold<int>(0, (s, it) => s + it.lineLegoCount);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Sipariş Özeti', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20),

      // Cart items
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border)),
        child: Column(children: [
          ...items.map((it) {
            final b = it.bouquet;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.roseLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('💐', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.name, style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.rose, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text('${b.size.label} • ${b.ribbon.label} kurdele',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('${b.legoCount} brick × ${it.qty} adet',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ])),
                Text('₺${it.lineTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
            );
          }),
          const Divider(height: 20),
          _Row('Teslim', name),
          _Row('Brick', '$totalLego adet'),
          _Row('Toplam', '₺${total.toStringAsFixed(0)}', bold: true),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.rose),
          const SizedBox(width: 10),
          Expanded(child: Text('Bu temsili bir siparişdir. Gerçek ödeme veya teslimat yapılmaz.',
            style: TextStyle(fontSize: 12, color: AppColors.rose, fontStyle: FontStyle.italic))),
        ]),
      ),
    ]);
  }
}

class _Row extends StatelessWidget {
  final String l, v;
  final bool bold;
  const _Row(this.l, this.v, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: bold ? 14 : 13, color: bold ? AppColors.textDark : AppColors.textLight,
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      Text(v, style: TextStyle(fontSize: bold ? 17 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: bold ? AppColors.rose : AppColors.textDark)),
    ]),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final String? Function(String?)? validator;
  const _Field({required this.ctrl, required this.label, required this.icon, this.type, this.validator});
  @override
  Widget build(BuildContext ctx) => TextFormField(
    controller: ctrl, keyboardType: type,
    decoration: InputDecoration(labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textLight)),
    validator: validator,
  );
}

class _CardFmt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final t = n.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < t.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(t[i]);
    }
    final s = buf.toString();
    return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpFmt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final t = n.text.replaceAll('/', '');
    if (t.length <= 2) return n.copyWith(text: t);
    final s = '${t.substring(0, 2)}/${t.substring(2)}';
    return n.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
