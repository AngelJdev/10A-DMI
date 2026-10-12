import '../../core/utils/storage_service.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/local_video_datasource.dart';
import '../datasources/youtube_video_datasource.dart';
import '../datasources/online_stream_datasource.dart';
import '../mappers/video_mapper.dart';
import '../models/video_model.dart';

class VideoRepositoryImpl implements VideoRepository {
  final LocalVideoDatasource localDatasource;
  final YouTubeVideoDatasource youtubeDatasource;
  final OnlineStreamDatasource onlineStreamDatasource;
  final StorageService storageService;

  VideoRepositoryImpl({
    required this.localDatasource,
    required this.youtubeDatasource,
    required this.onlineStreamDatasource,
    required this.storageService,
  });

  @override
  Future<List<Video>> getForYouVideos() async {
    // Para Ti combina videos locales (incluyendo los de MrKolinz) con videos online
    final localModels = await localDatasource.getVideos();
    final streamModels = await onlineStreamDatasource.getVideos();

    final List<VideoModel> combined = [...localModels, ...streamModels];
    return _mapModelsToEntities(combined);
  }

  @override
  Future<List<Video>> getDiscoverVideos() async {
    // Discover explora videos de YouTube y streams online en formato vertical completo
    final ytModels = await youtubeDatasource.getVideos();
    final streamModels = await onlineStreamDatasource.getVideos();

    final List<VideoModel> combined = [...ytModels, ...streamModels];
    return _mapModelsToEntities(combined);
  }

  @override
  Future<List<Video>> getFavoriteVideos() async {
    final favoriteIds = storageService.getFavoriteIds();

    final localModels = await localDatasource.getVideos();
    final ytModels = await youtubeDatasource.getVideos();
    final streamModels = await onlineStreamDatasource.getVideos();

    final allModels = [...localModels, ...ytModels, ...streamModels];
    final favoriteModels = allModels.where((m) => favoriteIds.contains(m.id)).toList();

    return _mapModelsToEntities(favoriteModels);
  }

  @override
  Future<List<Video>> getLikedVideos() async {
    final likedIds = storageService.getLikedVideoIds();

    final localModels = await localDatasource.getVideos();
    final ytModels = await youtubeDatasource.getVideos();
    final streamModels = await onlineStreamDatasource.getVideos();

    final allModels = [...localModels, ...ytModels, ...streamModels];
    final likedModels = allModels.where((m) => likedIds.contains(m.id)).toList();

    return _mapModelsToEntities(likedModels);
  }

  List<Video> _mapModelsToEntities(List<VideoModel> models) {
    return models.map((model) => _mapSingleModel(model)).toList();
  }

  Video _mapSingleModel(VideoModel model, {bool forceFavorite = false}) {
    // Por defecto ningún video está likeado salvo que el usuario lo haya pulsado
    final isLiked = storageService.isLiked(model.id);
    final persistedLikes = storageService.getLikes(model.id, model.likes);
    final isFavorite = forceFavorite || storageService.isFavorite(model.id);
    final commentCount = storageService.getCommentCount(model.id, model.comentarios);

    final mapped = VideoMapper.videoModelToEntity(
      model,
      customLikes: persistedLikes,
      isLiked: isLiked,
      isFavorite: isFavorite,
    );

    return mapped.copyWith(comentarios: commentCount);
  }

  @override
  Future<int> toggleLike(String videoId, int currentLikes, bool currentlyLiked) async {
    final newLiked = !currentlyLiked;
    // Si se activa like -> suma 1; si se desactiva -> resta 1
    final newLikes = newLiked ? currentLikes + 1 : (currentLikes > 0 ? currentLikes - 1 : 0);

    await storageService.setLiked(videoId, newLiked);
    await storageService.saveLikes(videoId, newLikes);

    return newLikes;
  }

  @override
  Future<bool> toggleFavorite(String videoId) async {
    return await storageService.toggleFavorite(videoId);
  }

  @override
  Future<List<String>> getComments(String videoId) async {
    return storageService.getComments(videoId);
  }

  @override
  Future<int> addComment(String videoId, String text, int currentCount) async {
    await storageService.addComment(videoId, text);
    final newCount = currentCount + 1;
    return newCount;
  }

  @override
  Future<bool> isVideoFavorite(String videoId) async {
    return storageService.isFavorite(videoId);
  }

  @override
  Future<bool> isVideoLiked(String videoId) async {
    return storageService.isLiked(videoId);
  }

  @override
  int getPersistedLikes(String videoId, int defaultLikes) {
    return storageService.getLikes(videoId, defaultLikes);
  }
}
