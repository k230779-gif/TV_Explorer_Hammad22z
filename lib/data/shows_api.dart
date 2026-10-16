import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

class ShowsApi {
  final ApiClient _client;

  ShowsApi(this._client);

  // Get TV shows + load more: /shows?page=0, page=1, ...
  Future<List<Show>> getShows(int page) async {
    final data = await _client.get('/shows?page=$page', allowNotFound: true);
    if (data == null) return []; // 404 = no more pages
    return (data as List)
        .map((e) => Show.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}