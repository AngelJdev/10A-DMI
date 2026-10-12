import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_feed_provider.dart';
import '../../widgets/video_player_item.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final videos = feedProvider.discoverVideos;

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No hay videos disponibles en Discover',
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
