import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/season_provider.dart';
import '../../providers/video_feed_provider.dart';
import '../../widgets/video_player_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<VideoFeedProvider>();
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;

    if (feedProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (feedProvider.favoriteVideos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border, size: 70, color: seasonTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Tu colección de Favoritos está vacía',
                textAlign: TextAlign.center,
                style: seasonTheme.headingStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Guarda videos tocando el ícono de marcador en la barra lateral para verlos sin conexión o tenerlos siempre a mano.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: feedProvider.favoriteVideos.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        final video = feedProvider.favoriteVideos[index];
        return VideoPlayerItem(
          video: video,
          isCurrentInFeed: index == _currentPage,
        );
      },
    );
  }
}
