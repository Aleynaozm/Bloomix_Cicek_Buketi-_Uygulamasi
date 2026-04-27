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
      e.key.contains(turkishUpperCase(_search)) ||
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
              crossAxisCount: 3, childAspectRatio: 0.7,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                          child: Image.asset(
                            f.assetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                f.letter,
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: f.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: f.color.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              f.letter,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: f.color),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              f.nameTr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 9.5, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
