import 'package:mobile/core/services/api_service.dart';
import 'package:mobile/features/feed/models/artwork_model.dart';

class CanvasRepository {
  const CanvasRepository({this.apiService = const ApiService()});

  final ApiService apiService;

  Future<ArtworkModel> createArtwork({
    required String userId,
    required String title,
    required int width,
    required int height,
    required Map<String, String> pixels,
  }) async {
    final response = await apiService.postJson(
      '/artworks',
      headers: {'X-User-Id': userId},
      body: {
        'title': title,
        'width': width,
        'height': height,
        'pixels': pixels,
      },
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ArtworkModel.fromJson(data);
    }
    throw const FormatException('Unexpected artwork creation response');
  }
}