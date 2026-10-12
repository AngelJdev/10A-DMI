enum VideoSource { local, youtube, dailymotion, vimeo }

class Video {
  final String id;
  final String url;
  final String usuario;
  final String descripcion;
  final String cancion;
  final int likes;
  final int comentarios;
  final int compartidos;
  final VideoSource source;
  final String? thumbnailUrl;
  final bool isLiked;
  final bool isFavorite;

  Video({
    required this.id,
    required this.url,
    required this.usuario,
    required this.descripcion,
    required this.cancion,
    this.likes = 0,
    this.comentarios = 0,
    this.compartidos = 0,
    this.source = VideoSource.local,
    this.thumbnailUrl,
    this.isLiked = false,
    this.isFavorite = false,
  }) : assert(id.isNotEmpty, 'El id no puede estar vacío'),
       assert(url.isNotEmpty, 'La url no puede estar vacía'),
       assert(usuario.isNotEmpty, 'El usuario no puede estar vacío'),
       assert(descripcion.isNotEmpty, 'La descripción no puede estar vacía'),
       assert(cancion.isNotEmpty, 'La canción no puede estar vacía'),
       assert(likes >= 0, 'Los likes no pueden ser negativos'),
       assert(comentarios >= 0, 'Los comentarios no pueden ser negativos'),
       assert(compartidos >= 0, 'Los compartidos no pueden ser negativos');

  Video copyWith({
    String? id,
    String? url,
    String? usuario,
    String? descripcion,
    String? cancion,
    int? likes,
    int? comentarios,
    int? compartidos,
    VideoSource? source,
    String? thumbnailUrl,
    bool? isLiked,
    bool? isFavorite,
  }) {
    return Video(
      id: id ?? this.id,
      url: url ?? this.url,
      usuario: usuario ?? this.usuario,
      descripcion: descripcion ?? this.descripcion,
      cancion: cancion ?? this.cancion,
      likes: likes ?? this.likes,
      comentarios: comentarios ?? this.comentarios,
      compartidos: compartidos ?? this.compartidos,
      source: source ?? this.source,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isLiked: isLiked ?? this.isLiked,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
