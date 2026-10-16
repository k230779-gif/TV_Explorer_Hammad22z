import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  final int id;
  final String name;
  final int season;
  final int? number; // specials have no number
  final String? airdate;
  final int? runtime;
  final String? imageUrl;

  const Episode({
    required this.id,
    required this.name,
    required this.season,
    required this.number,
    required this.airdate,
    required this.runtime,
    required this.imageUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;

    return Episode(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Untitled',
      season: (json['season'] as int?) ?? 0,
      number: json['number'] as int?,
      airdate: json['airdate'] as String?,
      runtime: json['runtime'] as int?,
      imageUrl: image?['medium'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, season, number];
}