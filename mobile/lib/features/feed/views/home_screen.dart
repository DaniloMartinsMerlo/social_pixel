import 'package:flutter/material.dart';

import 'package:mobile/features/canvas/views/canvas_screen.dart';
import 'package:mobile/features/feed/viewmodels/feed_viewmodel.dart';
import 'package:mobile/features/feed/views/artwork_detail_screen.dart';
import 'package:mobile/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:mobile/features/profile/views/profile_screen.dart';
import 'package:mobile/shared/widgets/app_bottom_nav.dart';
import 'package:mobile/shared/widgets/artwork_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _feedViewModel = FeedViewModel();
  final _profileViewModel = ProfileViewModel();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _feedViewModel.loadFeed();
    _profileViewModel.loadProfile();
  }

  @override
  void dispose() {
    _feedViewModel.dispose();
    _profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _FeedTab(feedViewModel: _feedViewModel),
      const CanvasScreen(),
      ProfileScreen(profileViewModel: _profileViewModel),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Pixel'),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({required this.feedViewModel});

  final FeedViewModel feedViewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: feedViewModel,
      builder: (context, _) {
        if (feedViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (feedViewModel.errorMessage != null) {
          return Center(child: Text(feedViewModel.errorMessage!));
        }

        return RefreshIndicator(
          onRefresh: feedViewModel.loadFeed,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: feedViewModel.artworks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final artwork = feedViewModel.artworks[index];
              return ArtworkCard(
                artwork: artwork,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArtworkDetailScreen(artwork: artwork),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}