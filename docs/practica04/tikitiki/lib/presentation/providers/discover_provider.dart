import 'package:flutter/foundation.dart';
import 'package:tikitiki/domain/entities/video_post.dart';
import 'package:tikitiki/shared/data/local_video_posts.dart';

class DiscoverProvider extends ChangeNotifier {
  bool initialLoading = true;
  List<VideoPost> videos = [];

  Future<void> loadVideos() async {
    await Future.delayed(const Duration(seconds: 3));
    videos = videoPosts.map((video) => VideoPost.fromMap(video)).toList();
    initialLoading = false;
    notifyListeners();
  }
}
