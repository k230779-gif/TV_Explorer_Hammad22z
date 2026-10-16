import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/data/details_api.dart';
import 'package:assignment_2_k230779_hammad/domain/cast_member.dart';
import 'package:assignment_2_k230779_hammad/domain/episode.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

part 'event.dart';
part 'state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final DetailsApi _api;

  // Starts with the show we already have, so the header shows instantly
  DetailsBloc(this._api, Show show)
      : super(DetailsState(
          status: DetailsStatus.loading,
          show: show,
          cast: const [],
          episodesBySeason: const {},
          selectedSeason: 1,
          errorMessage: '',
        )) {
    on<DetailsEvent>(_onEvent);
  }

  DetailsState _build({
    DetailsStatus? status,
    Show? show,
    List<CastMember>? cast,
    Map<int, List<Episode>>? episodesBySeason,
    int? selectedSeason,
    String? errorMessage,
  }) {
    return DetailsState(
      status: status ?? state.status,
      show: show ?? state.show,
      cast: cast ?? state.cast,
      episodesBySeason: episodesBySeason ?? state.episodesBySeason,
      selectedSeason: selectedSeason ?? state.selectedSeason,
      errorMessage: errorMessage ?? state.errorMessage,
    );
  }

  Future<void> _onEvent(DetailsEvent event, Emitter<DetailsState> emit) async {
    switch (event.action) {
      case DetailsAction.load:
        await _load(emit);
        break;
      case DetailsAction.selectSeason:
        final season = event.season;
        if (season != null && state.episodesBySeason.containsKey(season)) {
          emit(_build(selectedSeason: season));
        }
        break;
    }
  }

  Future<void> _load(Emitter<DetailsState> emit) async {
    emit(_build(status: DetailsStatus.loading, errorMessage: ''));

    try {
      final id = state.show.id;

      // Details, cast and episodes are fetched at the same time
      final results = await Future.wait<dynamic>(
        [
          _api.getShow(id),
          _api.getCast(id),
          _api.getEpisodes(id),
        ],
        eagerError: true,
      );

      final show = results[0] as Show;
      final cast = results[1] as List<CastMember>;
      final episodes = results[2] as List<Episode>;
      final grouped = _groupBySeason(episodes);

      emit(_build(
        status: DetailsStatus.success,
        show: show,
        cast: cast,
        episodesBySeason: grouped,
        selectedSeason: grouped.isEmpty ? 1 : grouped.keys.first,
      ));
    } on ApiException catch (e) {
      emit(_build(status: DetailsStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(_build(
        status: DetailsStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  // {1: [episodes of season 1], 2: [...]}, sorted by season number
  Map<int, List<Episode>> _groupBySeason(List<Episode> episodes) {
    final map = <int, List<Episode>>{};
    for (final episode in episodes) {
      map.putIfAbsent(episode.season, () => []).add(episode);
    }
    final seasons = map.keys.toList()..sort();
    return {for (final s in seasons) s: map[s]!};
  }
}