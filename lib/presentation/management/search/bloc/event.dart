part of 'bloc.dart';

enum SearchAction { query, clear }

class SearchEvent extends Equatable {
  final SearchAction action;
  final String query;

  const SearchEvent(this.action, {this.query = ''});

  @override
  List<Object?> get props => [action, query];
}