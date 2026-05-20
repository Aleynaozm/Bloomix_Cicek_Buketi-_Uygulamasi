import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'supabase_service.dart';

class AiImageResult {
  final String imageBase64;
  final String prompt;

  const AiImageResult({
    required this.imageBase64,
    required this.prompt,
  });
}

class AiImageService {
  static Future<AiImageResult> generateBouquetImage({
    required Bouquet bouquet,
    required AiPreviewStyle style,
    required String prompt,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'generate-bouquet-image',
      body: {
        'style': style.name,
        'prompt': prompt,
        'flowers': _flowerCounts(bouquet),
        'ribbon': bouquet.ribbon.label,
        'size': bouquet.size.label,
        'template': bouquet.template.name,
        'flowerLayout': _flowerLayout(bouquet),
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const FunctionException(
        status: 500,
        details: 'AI servisi beklenmeyen cevap döndürdü.',
      );
    }

    final imageBase64 = data['imageBase64'] as String?;
    if (imageBase64 == null || imageBase64.isEmpty) {
      throw FunctionException(
        status: response.status,
        details: data['error'] ?? 'AI görseli üretilemedi.',
      );
    }

    return AiImageResult(
      imageBase64: imageBase64,
      prompt: (data['prompt'] as String?) ?? prompt,
    );
  }

  static Map<String, int> _flowerCounts(Bouquet bouquet) {
    final counts = <String, int>{};
    for (final flower in bouquet.flowers) {
      counts[flower.nameTr] = (counts[flower.nameTr] ?? 0) + 1;
    }
    return counts;
  }

  static List<Map<String, dynamic>> _flowerLayout(Bouquet bouquet) {
    return bouquet.placedFlowers
        .map((placed) => {
              'flower': placed.flower.nameTr,
              'x': placed.position.dx.toStringAsFixed(2),
              'y': placed.position.dy.toStringAsFixed(2),
              'scale': placed.scale.toStringAsFixed(2),
            })
        .toList();
  }
}
