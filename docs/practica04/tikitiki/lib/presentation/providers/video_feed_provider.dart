import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/get_videos.dart';

class VideoFeedProvider extends ChangeNotifier {
  final VideoRepository repository;
  final GetVideos getVideosUseCase;

  List<Video> forYouVideos = [];
  List<Video> discoverVideos = [];
  List<Video> favoriteVideos = [];
  List<Video> likedVideos = [];

  bool isLoading = true;
  bool isMuted = false;

  VideoFeedProvider({
    required this.repository,
    required this.getVideosUseCase,
  }) {
    loadAllFeeds();
  }

  Future<void> loadAllFeeds() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        getVideosUseCase(type: FeedType.forYou),
        getVideosUseCase(type: FeedType.discover),
        getVideosUseCase(type: FeedType.favorites),
        getVideosUseCase(type: FeedType.liked),
      ]);

      forYouVideos = results[0];
      discoverVideos = results[1];
      favoriteVideos = results[2];
      likedVideos = results[3];
    } catch (_) {
      // Manejo de errores
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna el estado de mute global para los reproductores de video
  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  /// Alterna me gusta (+1 / -1) y persiste inmediatamente en Local Storage
  Future<void> toggleLike(Video video) async {
    final updatedLikes = await repository.toggleLike(
      video.id,
      video.likes,
      video.isLiked,
    );
    final newIsLiked = !video.isLiked;

    // Actualizar en las listas principales
    forYouVideos = _updateVideoInList(forYouVideos, video.id, updatedLikes, newIsLiked, null, null);
    discoverVideos = _updateVideoInList(discoverVideos, video.id, updatedLikes, newIsLiked, null, null);
    favoriteVideos = _updateVideoInList(favoriteVideos, video.id, updatedLikes, newIsLiked, null, null);

    // Mantener sincronizada la lista de videos con Me Gusta (para Perfil)
    if (newIsLiked) {
      final updatedVideo = video.copyWith(likes: updatedLikes, isLiked: true);
      if (!likedVideos.any((v) => v.id == video.id)) {
        likedVideos.insert(0, updatedVideo);
      } else {
        likedVideos = _updateVideoInList(likedVideos, video.id, updatedLikes, newIsLiked, null, null);
      }
    } else {
      likedVideos.removeWhere((v) => v.id == video.id);
    }

    notifyListeners();
  }

  /// Alterna si el video está en Favoritos y persiste en Local Storage
  Future<void> toggleFavorite(Video video) async {
    final isFav = await repository.toggleFavorite(video.id);

    forYouVideos = _updateVideoInList(forYouVideos, video.id, null, null, isFav, null);
    discoverVideos = _updateVideoInList(discoverVideos, video.id, null, null, isFav, null);
    likedVideos = _updateVideoInList(likedVideos, video.id, null, null, isFav, null);

    if (isFav) {
      if (!favoriteVideos.any((v) => v.id == video.id)) {
        favoriteVideos.add(video.copyWith(isFavorite: true));
      }
    } else {
      favoriteVideos.removeWhere((v) => v.id == video.id);
    }

    notifyListeners();
  }

  /// Obtiene los comentarios de un video
  Future<List<String>> getComments(String videoId) async {
    return repository.getComments(videoId);
  }

  /// Agrega un comentario interactivo y actualiza el contador
  Future<void> addComment(Video video, String text) async {
    final newCount = await repository.addComment(video.id, text, video.comentarios);

    forYouVideos = _updateVideoInList(forYouVideos, video.id, null, null, null, newCount);
    discoverVideos = _updateVideoInList(discoverVideos, video.id, null, null, null, newCount);
    favoriteVideos = _updateVideoInList(favoriteVideos, video.id, null, null, null, newCount);
    likedVideos = _updateVideoInList(likedVideos, video.id, null, null, null, newCount);

    notifyListeners();
  }

  List<Video> _updateVideoInList(
    List<Video> list,
    String videoId,
    int? likes,
    bool? isLiked,
    bool? isFavorite,
    int? comentarios,
  ) {
    return list.map((v) {
      if (v.id == videoId) {
        return v.copyWith(
          likes: likes ?? v.likes,
          isLiked: isLiked ?? v.isLiked,
          isFavorite: isFavorite ?? v.isFavorite,
          comentarios: comentarios ?? v.comentarios,
        );
      }
      return v;
    }).toList();
  }
}
