part of 'bloc.dart';

enum WatchlistStatus { loading, success }

class WatchlistState extends Equatable {
  final WatchlistStatus status;
  final List<Show> shows;
  final Set<int> savedIds;
  final String message;
  final int messageId; // increases for every new message (SnackBar)

  const WatchlistState({
    required this.status,
    required this.shows,
    required this.savedIds,
    required this.message,
    required this.messageId,
  });

  @override
  List<Object?> get props => [status, shows, savedIds, message, messageId];
}