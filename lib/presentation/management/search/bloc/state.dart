part of 'bloc.dart';

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<Show> results;
  final String errorMessage;

  const SearchState({
    required this.status,
    required this.query,
    required this.results,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [status, query, results, errorMessage];
}