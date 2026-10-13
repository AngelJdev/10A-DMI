import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/video_feed_provider.dart';
import '../widgets/video_player_item.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoFeedProvider = context.watch<VideoFeedProvider>();

    if (videoFeedProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (videoFeedProvider.forYouVideos.isEmpty) {
      return const Center(
        child: Text(
          'No hay videos disponibles en Para Ti',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Mantiene solo el item actual + 1 adyacente vivo para liberar memoria
      itemCount: videoFeedProvider.forYouVideos.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        final video = videoFeedProvider.forYouVideos[index];
        // Solo renderiza los items cercanos al actual (±1)
        final isNearby = (index - _currentPage).abs() <= 1;
        return isNearby
            ? VideoPlayerItem(
                key: ValueKey(video.id),
                video: video,
                isCurrentInFeed: index == _currentPage,
              )
            : Container(color: Colors.black);
      },
    );
  }
}
