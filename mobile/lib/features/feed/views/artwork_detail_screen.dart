import 'package:flutter/material.dart';

import 'package:mobile/features/feed/models/artwork_model.dart';
import 'package:mobile/shared/widgets/pixel_grid.dart';

class ArtworkDetailScreen extends StatelessWidget {
  const ArtworkDetailScreen({super.key, required this.artwork});

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(artwork.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PixelGrid(
            width: artwork.width,
            height: artwork.height,
            pixels: artwork.pixels,
            selectedColor: '#000000',
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Text(artwork.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('@${artwork.author?.username ?? 'unknown'}'),
          const SizedBox(height: 8),
          Text('${artwork.likeCount} curtidas'),
        ],
      ),
    );
  }
}