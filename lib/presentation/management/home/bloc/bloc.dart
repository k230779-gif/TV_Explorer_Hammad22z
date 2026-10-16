import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/data/shows_api.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

part 'event.dart';
part 'state.dart';

class ShowsBloc extends Bloc<ShowsEvent, ShowsState> {
  final ShowsApi _api;

  ShowsBloc(this._api)
      : super(const ShowsState(
          status: ShowsStatus.loading,
          shows: [],
          trending: [],
          nextPage: 0,
          hasReachedMax: false,
          isLoadingMore: false,
          loadMoreFailed: false,
          errorMessage: '',
        )) {
    // droppable: while one request runs, extra scroll events are ignored
    on<ShowsEvent>(_onEvent, transformer: droppable());
    add(const ShowsEvent(ShowsAction.load));
  }

  // Builds the next state from the current one (all rules live in the bloc)
  ShowsState _build({
    ShowsStatus? status,
    List<Show>? shows,
    List<Show>? trending,
    int? nextPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    String? errorMessage,
  }) {
    return ShowsState(
      status: status ?? state.status,
      shows: shows ?? state.shows,
      trending: trending ?? state.trending,
      nextPage: nextPage ?? state.nextPage,
      hasReachedMax: hasReachedMax ?? state.hasReachedMax,
      isLoadingMore: isLoadingMore ?? state.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? state.loadMoreFailed,
      errorMessage: errorMessage ?? state.errorMessage,
    );
  }

  Future<void> _onEvent(ShowsEvent event, Emitter<ShowsState> emit) async {
    switch (event.action) {
      case ShowsAction.load:
        await _loadFirstPage(emit);
        break;
      case ShowsAction.loadMore:
        await _loadMore(emit, isRetry: false);
        break;
      case ShowsAction.retryLoadMore:
        await _loadMore(emit, isRetry: true);
        break;
    }
  }

  Future<void> _loadFirstPage(Emitter<ShowsState> emit) async {
    emit(_build(status: ShowsStatus.loading, errorMessage: ''));

    try {
      final shows = await _api.getShows(0);
      emit(_build(
        status: ShowsStatus.success,
        shows: shows,
        trending: _pickTrending(shows),
        nextPage: 1,
        hasReachedMax: shows.isEmpty,
        isLoadingMore: false,
        loadMoreFailed: false,
      ));
    } on ApiException catch (e) {
      emit(_build(status: ShowsStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(_build(
        status: ShowsStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _loadMore(Emitter<ShowsState> emit,
      {required bool isRetry}) async {
    if (state.status != ShowsStatus.success) return;
    if (state.hasReachedMax || state.isLoadingMore) return;
    // After a failure, only the retry button may try again (no scroll loop)
    if (state.loadMoreFailed && !isRetry) return;

    emit(_build(isLoadingMore: true, loadMoreFailed: false));

    try {
      final more = await _api.getShows(state.nextPage);
      emit(_build(
        shows: [...state.shows, ...more],
        nextPage: state.nextPage + 1,
        hasReachedMax: more.isEmpty,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(_build(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  // "Trending Now": the 10 best-rated shows with a poster from the loaded page
  List<Show> _pickTrending(List<Show> shows) {
    final rated = shows
        .where((s) => s.rating != null && s.posterMedium != null)
        .toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.take(10).toList();
  }
} 