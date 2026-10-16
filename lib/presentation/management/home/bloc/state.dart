part of 'bloc.dart';

enum ShowsStatus { loading, success, failure }

class ShowsState extends Equatable {
  final ShowsStatus status;
  final List<Show> shows;
  final List<Show> trending;
  final int nextPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final String errorMessage;

  const ShowsState({
    required this.status,
    required this.shows,
    required this.trending,
    required this.nextPage,
    required this.hasReachedMax,
    required this.isLoadingMore,
    required this.loadMoreFailed,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
        status,
        shows,
        trending,
        nextPage,
        hasReachedMax,
        isLoadingMore,
        loadMoreFailed,
        errorMessage,
      ];
}