class VideoPost {
  final String caption;
  final String videoUrl;
  final int likes;
  final int views;

  VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
  });

  factory VideoPost.fromMap(Map<String, dynamic> map) {
    return VideoPost(
      caption: map['name'] as String,
      videoUrl: map['videoUrl'] as String,
      likes: (map['likes'] as int?) ?? 0,
      views: (map['views'] as int?) ?? 0,
    );
  }
}
