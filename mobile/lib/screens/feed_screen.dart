// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/artwork_card.dart';
import 'notifications_screen.dart';

class FeedScreen extends StatefulWidget {
  final String userId;
  const FeedScreen({super.key, required this.userId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final ApiService _api;
  List<Artwork> _artworks = [];
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _api = ApiService(userId: widget.userId);
    _loadFeed();
    _loadUnread();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getFeed();
      if (mounted) setState(() => _artworks = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadUnread() async {
    try {
      final count = await _api.getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  Future<void> _toggleLike(Artwork artwork) async {
    final wasLiked = artwork.liked;
    setState(() {
      artwork.liked = !wasLiked;
      artwork.likeCount += wasLiked ? -1 : 1;
    });
    try {
      if (wasLiked) {
        await _api.unlikeArtwork(artwork.id);
      } else {
        await _api.likeArtwork(artwork.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          artwork.liked = wasLiked;
          artwork.likeCount += wasLiked ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PixelShare',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.textSecondary),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  NotificationsScreen(userId: widget.userId),
                            ),
                          );
                          _loadUnread();
                        },
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadFeed,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onRefresh: _loadFeed,
                          child: _artworks.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma arte ainda.\nSeja o primeiro a publicar!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _artworks.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (_, i) => ArtworkCard(
                                    artwork: _artworks[i],
                                    onLike: _toggleLike,
                                  ),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
