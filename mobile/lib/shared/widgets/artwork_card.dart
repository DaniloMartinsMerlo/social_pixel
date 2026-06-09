import 'package:flutter/material.dart';

import 'package:mobile/features/feed/models/artwork_model.dart';
import 'package:mobile/shared/widgets/pixel_grid.dart';

class ArtworkCard extends StatelessWidget {
  const ArtworkCard({super.key, required this.artwork, this.onTap});

  final ArtworkModel artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(artwork.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              PixelGrid(
                width: artwork.width,
                height: artwork.height,
                pixels: artwork.pixels,
                selectedColor: '#000000',
                readOnly: true,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('@${artwork.author?.username ?? 'unknown'}'),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16),
                      const SizedBox(width: 4),
                      Text('${artwork.likeCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}