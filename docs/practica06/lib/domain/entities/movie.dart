enum MediaType { movie, series }

class Movie {
  const Movie({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    this.mediaType = MediaType.movie,
    this.seasons,
    this.episodes,
  });

  final bool adult;
  final String backdropPath;
  final List<String> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime? releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;
  final MediaType mediaType;
  final int? seasons;
  final int? episodes;
  String get contentKey => '${mediaType.name}:$id';
  String get location =>
      '/${mediaType == MediaType.series ? 'series' : 'movie'}/$id';
  Map<String, dynamic> toJson() => {
    'adult': adult,
    'backdropPath': backdropPath,
    'genreIds': genreIds,
    'id': id,
    'originalLanguage': originalLanguage,
    'originalTitle': originalTitle,
    'overview': overview,
    'popularity': popularity,
    'posterPath': posterPath,
    'releaseDate': releaseDate?.toIso8601String(),
    'title': title,
    'video': video,
    'voteAverage': voteAverage,
    'voteCount': voteCount,
    'mediaType': mediaType.name,
    'seasons': seasons,
    'episodes': episodes,
  };

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    adult: json['adult'] as bool,
    backdropPath: json['backdropPath'] as String,
    genreIds: (json['genreIds'] as List).cast<String>(),
    id: json['id'] as int,
    originalLanguage: json['originalLanguage'] as String,
    originalTitle: json['originalTitle'] as String,
    overview: json['overview'] as String,
    popularity: (json['popularity'] as num).toDouble(),
    posterPath: json['posterPath'] as String,
    releaseDate: DateTime.tryParse(json['releaseDate'] as String? ?? ''),
    title: json['title'] as String,
    video: json['video'] as bool,
    voteAverage: (json['voteAverage'] as num).toDouble(),
    voteCount: json['voteCount'] as int,
    mediaType: json['mediaType'] == 'series'
        ? MediaType.series
        : MediaType.movie,
    seasons: json['seasons'] as int?,
    episodes: json['episodes'] as int?,
  );
}
