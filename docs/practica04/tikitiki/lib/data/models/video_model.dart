class VideoModel {
  final String id;
  final String url;
  final String usuario;
  final String descripcion;
  final String cancion;
  final int likes;
  final int comentarios;
  final int compartidos;
  final String source;
  final String? thumbnailUrl;

  VideoModel({
    required this.id,
    required this.url,
    required this.usuario,
    required this.descripcion,
    required this.cancion,
    this.likes = 0,
    this.comentarios = 0,
    this.compartidos = 0,
    this.source = 'local',
    this.thumbnailUrl,
  }) : assert(id.isNotEmpty, 'El id no puede estar vacío'),
       assert(url.isNotEmpty, 'La url no puede estar vacía'),
       assert(usuario.isNotEmpty, 'El usuario no puede estar vacío'),
       assert(descripcion.isNotEmpty, 'La descripción no puede estar vacía'),
       assert(cancion.isNotEmpty, 'La canción no puede estar vacía'),
       assert(likes >= 0, 'Los likes no pueden ser negativos'),
       assert(comentarios >= 0, 'Los comentarios no pueden ser negativos'),
       assert(compartidos >= 0, 'Los compartidos no pueden ser negativos');

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      url: json['url'] as String,
      usuario: json['usuario'] as String,
      descripcion: json['descripcion'] as String,
      cancion: json['cancion'] as String,
      likes: (json['likes'] as int?) ?? 0,
      comentarios: (json['comentarios'] as int?) ?? 0,
      compartidos: (json['compartidos'] as int?) ?? 0,
      source: (json['source'] as String?) ?? 'local',
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'usuario': usuario,
      'descripcion': descripcion,
      'cancion': cancion,
      'likes': likes,
      'comentarios': comentarios,
      'compartidos': compartidos,
      'source': source,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
