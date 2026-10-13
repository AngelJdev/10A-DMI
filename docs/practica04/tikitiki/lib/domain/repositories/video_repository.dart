import '../entities/video.dart';

abstract class VideoRepository {
  /// Obtiene los videos del feed principal ("Para ti / For You")
  Future<List<Video>> getForYouVideos();

  /// Obtiene los videos de la sección "Discover / Explorar"
  Future<List<Video>> getDiscoverVideos();

  /// Obtiene los videos guardados en "Favorites / Favoritos"
  Future<List<Video>> getFavoriteVideos();

  /// Obtiene los videos que el usuario ha marcado con "Me gusta" (para Perfil)
  Future<List<Video>> getLikedVideos();

  /// Alterna el estado de me gusta y retorna la nueva cantidad de likes (+1 / -1)
  Future<int> toggleLike(String videoId, int currentLikes, bool currentlyLiked);

  /// Alterna el estado de favorito y retorna si quedó marcado como favorito
  Future<bool> toggleFavorite(String videoId);

  /// Obtiene los comentarios de un video
  Future<List<String>> getComments(String videoId);

  /// Agrega un nuevo comentario a un video y retorna el nuevo conteo
  Future<int> addComment(String videoId, String text, int currentCount);

  /// Verifica si un video está marcado como favorito en Local Storage
  Future<bool> isVideoFavorite(String videoId);

  /// Verifica si un video está marcado con like en Local Storage (por defecto false)
  Future<bool> isVideoLiked(String videoId);

  /// Obtiene el conteo de likes persistido en Local Storage
  int getPersistedLikes(String videoId, int defaultLikes);
}
