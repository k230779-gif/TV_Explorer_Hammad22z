import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/watchlist_storage.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

part 'event.dart';
part 'state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistStorage _storage;

  WatchlistBloc(this._storage)
      : super(const WatchlistState(
          status: WatchlistStatus.loading,
          shows: [],
          savedIds: {},
          message: '',
          messageId: 0,
        )) {
    // sequential: load finishes before any toggle, and saves never overlap
    on<WatchlistEvent>(_onEvent, transformer: sequential());
    add(const WatchlistEvent(WatchlistAction.load)); // restore saved shows
  }

  WatchlistState _build(List<Show> shows, {String? message}) {
    return WatchlistState(
      status: WatchlistStatus.success,
      shows: shows,
      savedIds: shows.map((s) => s.id).toSet(),
      message: message ?? '',
      messageId: message == null ? state.messageId : state.messageId + 1,
    );
  }

  Future<void> _onEvent(
      WatchlistEvent event, Emitter<WatchlistState> emit) async {
    switch (event.action) {
      case WatchlistAction.load:
        await _load(emit);
        break;
      case WatchlistAction.toggle:
        await _toggle(event.show, emit);
        break;
      case WatchlistAction.clear:
        await _clear(emit);
        break;
    }
  }

  Future<void> _load(Emitter<WatchlistState> emit) async {
    final saved = await _storage.load();
    emit(_build(saved));
  }

  Future<void> _toggle(Show? show, Emitter<WatchlistState> emit) async {
    if (show == null) return;

    final shows = List<Show>.from(state.shows);
    final exists = shows.any((s) => s.id == show.id);

    if (exists) {
      shows.removeWhere((s) => s.id == show.id);
    } else {
      shows.insert(0, show); // newest first
    }

    // Update the screen first, then save
    emit(_build(
      shows,
      message: exists ? 'Removed from watchlist' : 'Added to watchlist',
    ));
    await _storage.save(shows);
  }

  Future<void> _clear(Emitter<WatchlistState> emit) async {
    emit(_build(const [], message: 'Watchlist cleared'));
    await _storage.save(const []);
  }
}