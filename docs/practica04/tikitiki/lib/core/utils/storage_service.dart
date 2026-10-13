import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // === Me Gustas (Likes) ===
  int getLikes(String videoId, int defaultLikes) {
    return _prefs?.getInt('likes_$videoId') ?? defaultLikes;
  }

  Future<void> saveLikes(String videoId, int likes) async {
    await _prefs?.setInt('likes_$videoId', likes);
  }

  /// Por defecto ningún video está likeado por el usuario (false)
  bool isLiked(String videoId) {
    return _prefs?.getBool('liked_$videoId') ?? false;
  }

  Future<void> setLiked(String videoId, bool liked) async {
    await _prefs?.setBool('liked_$videoId', liked);
    final likedIds = getLikedVideoIds();
    final updated = List<String>.from(likedIds);
    if (liked) {
      if (!updated.contains(videoId)) updated.add(videoId);
    } else {
      updated.remove(videoId);
    }
    await _prefs?.setStringList('user_liked_video_ids', updated);
  }

  /// Lista de todos los IDs de videos que el usuario ha likeado
  List<String> getLikedVideoIds() {
    return _prefs?.getStringList('user_liked_video_ids') ?? [];
  }

  // === Comentarios Interactivos ===
  List<String> getComments(String videoId) {
    return _prefs?.getStringList('comments_$videoId') ?? [];
  }

  Future<void> addComment(String videoId, String comment) async {
    final list = getComments(videoId);
    final updated = List<String>.from(list)..add(comment);
    await _prefs?.setStringList('comments_$videoId', updated);
  }

  int getCommentCount(String videoId, int defaultCount) {
    final localComments = getComments(videoId);
    return defaultCount + localComments.length;
  }

  // === Favoritos (Favorites) ===
  List<String> getFavoriteIds() {
    return _prefs?.getStringList('favorite_video_ids') ?? [];
  }

  Future<void> setFavoriteIds(List<String> ids) async {
    await _prefs?.setStringList('favorite_video_ids', ids);
  }

  bool isFavorite(String videoId) {
    final list = getFavoriteIds();
    return list.contains(videoId);
  }

  Future<bool> toggleFavorite(String videoId) async {
    final list = getFavoriteIds();
    final updatedList = List<String>.from(list);
    final isFav = updatedList.contains(videoId);
    if (isFav) {
      updatedList.remove(videoId);
    } else {
      updatedList.add(videoId);
    }
    await setFavoriteIds(updatedList);
    return !isFav;
  }

  // === Temporada (Season Override) ===
  String? getSavedSeason() {
    return _prefs?.getString('user_selected_season');
  }

  Future<void> saveSeason(String? seasonName) async {
    if (seasonName == null) {
      await _prefs?.remove('user_selected_season');
    } else {
      await _prefs?.setString('user_selected_season', seasonName);
    }
  }
}
