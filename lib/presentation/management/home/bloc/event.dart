part of 'bloc.dart';

enum ShowsAction { load, loadMore, retryLoadMore }

class ShowsEvent extends Equatable {
  final ShowsAction action;

  const ShowsEvent(this.action);

  @override
  List<Object?> get props => [action];
}