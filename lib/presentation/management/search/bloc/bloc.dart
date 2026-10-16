import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/data/search_api.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

part 'event.dart';
part 'state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchApi _api;

  static const SearchState _initial = SearchState(
    status: SearchStatus.initial,
    query: '',
    results: [],
    errorMessage: '',
  );

  SearchBloc(this._api) : super(_initial) {
    // restartable: a new event cancels the previous one, which gives the debounce
    on<SearchEvent>(_onEvent, transformer: restartable());
  }

  Future<void> _onEvent(SearchEvent event, Emitter<SearchState> emit) async {
    switch (event.action) {
      case SearchAction.clear:
        emit(_initial);
        break;
      case SearchAction.query:
        await _search(event.query.trim(), emit);
        break;
    }
  }

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    if (query.isEmpty) {
      emit(_initial);
      return;
    }

    // Debounce: if the user types again within 500 ms this handler is cancelled
    await Future.delayed(const Duration(milliseconds: 500));
    if (emit.isDone) return;

    emit(SearchState(
      status: SearchStatus.loading,
      query: query,
      results: const [],
      errorMessage: '',
    ));

    try {
      final results = await _api.searchShows(query);
      emit(SearchState(
        status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
        query: query,
        results: results,
        errorMessage: '',
      ));
    } on ApiException catch (e) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: query,
        results: const [],
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: query,
        results: const [],
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}