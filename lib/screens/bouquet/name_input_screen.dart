import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../data/flower_data.dart';
import 'bouquet_builder_screen.dart';

/// Çiçek Alfabesi akışı — kullanıcı isim girer, her harfi bir çiçeğe dönüşür.
/// Eski Anasayfa'daki "İsim Gir" kartının ayrı ekran haline gelmiş hali.
class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _go(BuildContext context, String val) {
    final cleaned = val.trim();
    if (cleaned.isEmpty) return;
    context.read<AppProvider>().generateBouquet(cleaned);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const BouquetBuilderScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Çiçek Alfabesi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Açıklama kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.roseLight.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bir İsim Yaz',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 6),
              Text(
                'Yazdığın ismin her harfi bir çiçeğe dönüşür. Doğum günü, sevgililer günü ya da sürpriz hediye için ideal.',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textMid),
              ),
            ]),
          ),
          const SizedBox(height: 22),

          // Input
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.characters,
            style: GoogleFonts.poppins(
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'NIL, ELIF...',
              hintStyle: GoogleFonts.poppins(
                  color: AppColors.textLight.withOpacity(0.5),
                  letterSpacing: 3,
                  fontSize: 18),
              prefixIcon: const Icon(Icons.text_fields_rounded,
                  color: AppColors.rose),
            ),
            onSubmitted: (v) => _go(context, v),
          ),
          const SizedBox(height: 18),

          GradientButton(
              label: 'Buketi Oluştur',
              icon: Icons.auto_awesome_rounded,
              onPressed: () => _go(context, _ctrl.text)),

          const SizedBox(height: 32),

          // Mini alphabet preview
          Text('Türk Alfabesi (29 çiçek)',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flowerAlphabet.entries.map((e) {
              final f = e.value;
              return GestureDetector(
                onTap: () => showFlowerDetail(context, f),
                child: Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    color: f.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: f.color.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text(f.letter,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: f.color)),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
