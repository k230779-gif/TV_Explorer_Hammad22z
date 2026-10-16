import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

class SearchApi {
  final ApiClient _client;

  SearchApi(this._client);

  // Search shows: /search/shows?q=... returns [{score, show}]
  Future<List<Show>> searchShows(String query) async {
    final data = await _client
        .get('/search/shows?q=${Uri.encodeQueryComponent(query)}');
    return (data as List)
        .map((e) => Show.fromJson(
            (e as Map<String, dynamic>)['show'] as Map<String, dynamic>))
        .toList();
  }
}