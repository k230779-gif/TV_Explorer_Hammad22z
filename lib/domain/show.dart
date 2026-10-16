import 'package:equatable/equatable.dart';

class Show extends Equatable {
  final int id;
  final String name;
  final List<String> genres;
  final double? rating;
  final String? posterMedium;
  final String? posterOriginal;
  final String summary;
  final String? premiered;
  final String? ended;
  final String? status;
  final String? network;
  final String? language;
  final int? runtime;

  const Show({
    required this.id,
    required this.name,
    required this.genres,
    required this.rating,
    required this.posterMedium,
    required this.posterOriginal,
    required this.summary,
    required this.premiered,
    required this.ended,
    required this.status,
    required this.network,
    required this.language,
    required this.runtime,
  });

  // Reads the TVMaze JSON shape (also used to read back the saved watchlist)
  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final network =
        (json['network'] ?? json['webChannel']) as Map<String, dynamic>?;

    return Show(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unknown',
      genres: List<String>.from(json['genres'] ?? const []),
      rating: (rating?['average'] as num?)?.toDouble(),
      posterMedium: image?['medium'] as String?,
      posterOriginal: image?['original'] as String?,
      summary: _stripHtml(json['summary'] as String?),
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      status: json['status'] as String?,
      network: network?['name'] as String?,
      language: json['language'] as String?,
      runtime: (json['runtime'] ?? json['averageRuntime']) as int?,
    );
  }

  // Same shape as the API, so fromJson can read it back
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genres': genres,
        'rating': {'average': rating},
        'image': (posterMedium == null && posterOriginal == null)
            ? null
            : {'medium': posterMedium, 'original': posterOriginal},
        'summary': summary,
        'premiered': premiered,
        'ended': ended,
        'status': status,
        'network': network == null ? null : {'name': network},
        'language': language,
        'runtime': runtime,
      };

  // "2008 - 2013", "2023 - Present" or a single year
  String get years {
    final start = premiered?.split('-').first;
    if (start == null || start.isEmpty) return '';
    final end = ended?.split('-').first;
    if (end != null && end.isNotEmpty) {
      return start == end ? start : '$start - $end';
    }
    return '$start - Present';
  }

  static String _stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  @override
  List<Object?> get props =>
      [id, name, rating, summary, status, network, language, runtime];
}