part of 'bloc.dart';

enum DetailsAction { load, selectSeason }

class DetailsEvent extends Equatable {
  final DetailsAction action;
  final int? season; // only used by selectSeason

  const DetailsEvent(this.action, {this.season});

  @override
  List<Object?> get props => [action, season];
}