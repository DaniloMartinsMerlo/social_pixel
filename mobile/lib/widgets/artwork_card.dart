import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../theme.dart';
import 'pixel_grid_painter.dart';
import 'user_avatar.dart';
import 'package:share_plus/share_plus.dart';

class ArtworkCard extends StatefulWidget {
  final Artwork artwork;
  final Future<void> Function(Artwork) onLike;

  const ArtworkCard({
    super.key,
    required this.artwork,
    required this.onLike,
  });

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  bool _loading = false;

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onLike(widget.artwork);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelArtDisplay(
            pixels: artwork.pixels,
            width: artwork.width,
            height: artwork.height,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: artwork.author?.avatarUrl ?? '',
                  username: artwork.author?.username ?? '?',
                  radius: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    artwork.author?.username ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _toggle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        artwork.liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: artwork.liked
                            ? AppColors.like
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${artwork.likeCount}',
                        style: TextStyle(
                          color: artwork.liked
                              ? AppColors.like
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Share.share(
                      '🎨 Confira essa pixel art de ${artwork.author?.username ?? 'alguém'}: "${artwork.title}"\n\nFeita no PixelShare!',
                    );
                  },
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
