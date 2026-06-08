import 'package:mobile/core/services/api_service.dart';
import 'package:mobile/features/feed/models/artwork_model.dart';

class FeedRepository {
  const FeedRepository({this.apiService = const ApiService()});

  final ApiService apiService;

  Future<List<ArtworkModel>> getFeed({required String userId, int limit = 20, int offset = 0}) async {
    final response = await apiService.getJson(
      '/artworks/feed',
      queryParameters: {'limit': limit, 'offset': offset},
      headers: {'X-User-Id': userId},
    );
    return _extractList(response);
  }

  Future<ArtworkModel> getArtworkById({required String artworkId, required String userId}) async {
    final response = await apiService.getJson(
      '/artworks/$artworkId',
      headers: {'X-User-Id': userId},
    );
    return _extractSingle(response);
  }

  Future<void> likeArtwork({required String artworkId, required String userId}) async {
    await apiService.postJson('/artworks/$artworkId/like', headers: {'X-User-Id': userId});
  }

  Future<void> unlikeArtwork({required String artworkId, required String userId}) async {
    await apiService.deleteJson('/artworks/$artworkId/like', headers: {'X-User-Id': userId});
  }

  List<ArtworkModel> _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(ArtworkModel.fromJson).toList();
    }
    return const [];
  }

  ArtworkModel _extractSingle(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return ArtworkModel.fromJson(data);
    }
    throw const FormatException('Unexpected artwork response');
  }
}