part of 'bloc.dart';

enum DetailsStatus { loading, success, failure }

class DetailsState extends Equatable {
  final DetailsStatus status;
  final Show show;
  final List<CastMember> cast;
  final Map<int, List<Episode>> episodesBySeason;
  final int selectedSeason;
  final String errorMessage;

  const DetailsState({
    required this.status,
    required this.show,
    required this.cast,
    required this.episodesBySeason,
    required this.selectedSeason,
    required this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [status, show, cast, episodesBySeason, selectedSeason, errorMessage];
}