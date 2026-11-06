class CastMember {
  const CastMember({required this.name, required this.character, this.photo});
  final String name;
  final String character;
  final String? photo;

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
    name: json['name'] as String? ?? '',
    character: json['character'] as String? ?? '',
    photo: json['profile_path'] is String
        ? 'https://image.tmdb.org/t/p/w185${json['profile_path']}'
        : null,
  );
}
