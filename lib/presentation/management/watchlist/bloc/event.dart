part of 'bloc.dart';

enum WatchlistAction { load, toggle, clear }

class WatchlistEvent extends Equatable {
  final WatchlistAction action;
  final Show? show; // only used by toggle

  const WatchlistEvent(this.action, {this.show});

  @override
  List<Object?> get props => [action, show];
}