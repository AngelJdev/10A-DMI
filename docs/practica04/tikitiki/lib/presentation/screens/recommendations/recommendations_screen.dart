import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_feed_provider.dart';
import '../../widgets/video_player_item.dart';

/// Pantalla de Recomendaciones en el MISMO FORMATO exacto que Para Ti (pantalla completa,
/// video vertical deslizable, sin enlaces externos ni tarjetas)
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
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

    if (feedProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final videos = feedProvider.discoverVideos;

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No hay recomendaciones disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoPlayerItem(
          video: video,
          isCurrentInFeed: index == _currentPage,
        );
      },
    );
  }
}