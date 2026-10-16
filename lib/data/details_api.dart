import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/domain/cast_member.dart';
import 'package:assignment_2_k230779_hammad/domain/episode.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

class DetailsApi {
  final ApiClient _client;

  DetailsApi(this._client);

  // Show details: /shows/{id}
  Future<Show> getShow(int id) async {
    final data = await _client.get('/shows/$id');
    return Show.fromJson(data as Map<String, dynamic>);
  }

  // Show cast: /shows/{id}/cast
  Future<List<CastMember>> getCast(int id) async {
    final data = await _client.get('/shows/$id/cast');
    return (data as List)
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Show episodes: /shows/{id}/episodes
  Future<List<Episode>> getEpisodes(int id) async {
    final data = await _client.get('/shows/$id/episodes');
    return (data as List)
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}