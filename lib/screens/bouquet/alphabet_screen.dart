import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/flower_data.dart';
import '../../widgets/widgets.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});
  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = flowerAlphabet.entries.where((e) =>
      _search.isEmpty ||
      e.key.contains(_search.toUpperCase()) ||
      e.value.nameTr.toLowerCase().contains(_search.toLowerCase()) ||
      e.value.meaning.toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Çiçek Alfabesi')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Harf veya çiçek ara...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _search = ''))
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.75,
              crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final f = filtered[i].value;
              return GestureDetector(
                onTap: () => showFlowerDetail(context, f),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: f.color.withOpacity(0.25)),
                  ),
                  child: Column(children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
                      child: FlowerCard(flower: f, size: 65),
                    )),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: f.color.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                      ),
                      child: Column(children: [
                        Text(f.letter, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: f.color)),
                        Text(f.nameTr, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
