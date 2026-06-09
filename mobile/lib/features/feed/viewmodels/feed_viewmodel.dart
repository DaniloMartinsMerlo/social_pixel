import 'package:flutter/foundation.dart';

import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/feed/models/artwork_model.dart';
import 'package:mobile/features/feed/repositories/feed_repository.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel({FeedRepository? feedRepository, LocalStorage? localStorage})
      : _feedRepository = feedRepository ?? const FeedRepository(),
        _localStorage = localStorage ?? const LocalStorage();

  final FeedRepository _feedRepository;
  final LocalStorage _localStorage;

  List<ArtworkModel> artworks = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadFeed() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = await _requireUserId();
      artworks = await _feedRepository.getFeed(userId: userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(ArtworkModel artwork) async {
    final userId = await _requireUserId();
    if (artwork.liked) {
      await _feedRepository.unlikeArtwork(artworkId: artwork.id, userId: userId);
    } else {
      await _feedRepository.likeArtwork(artworkId: artwork.id, userId: userId);
    }
    await loadFeed();
  }

  Future<String> _requireUserId() async {
    final userId = await _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('No user session found');
    }
    return userId;
  }
}