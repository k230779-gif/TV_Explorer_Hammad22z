import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  final String name;
  final String character;
  final String? imageUrl;

  const CastMember({
    required this.name,
    required this.character,
    required this.imageUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = (json['person'] as Map<String, dynamic>?) ?? {};
    final character = (json['character'] as Map<String, dynamic>?) ?? {};
    final image = person['image'] as Map<String, dynamic>?;

    return CastMember(
      name: (person['name'] as String?) ?? 'Unknown',
      character: (character['name'] as String?) ?? '',
      imageUrl: image?['medium'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, character, imageUrl];
}