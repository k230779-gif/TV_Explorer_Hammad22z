import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/watchlist/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/details_page.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/content_width.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/show_list_tile.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/state_views.dart';

class WatchlistPage extends StatelessWidget {
  final VoidCallback onExplore;

  const WatchlistPage({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ContentWidth(
        maxWidth: 800,
        child: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('My Watchlist',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700)),
                      ),
                      if (state.shows.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmClear(context),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WatchlistState state) {
    if (state.status == WatchlistStatus.loading) return const LoadingView();

    if (state.shows.isEmpty) {
      return EmptyView(
        icon: Icons.inventory_2_outlined,
        title: 'Your watchlist is empty',
        subtitle: 'Discover amazing shows and save them here to watch later.',
        actionLabel: 'Explore Shows',
        onAction: onExplore,
      );
    }

    return ListView.builder(
      itemCount: state.shows.length,
      itemBuilder: (context, index) {
        final show = state.shows[index];
        return ShowListTile(
          show: show,
          onTap: () => DetailsPage.open(context, show),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppTheme.danger),
            onPressed: () => context
                .read<WatchlistBloc>()
                .add(WatchlistEvent(WatchlistAction.toggle, show: show)),
          ),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<WatchlistBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear watchlist?'),
        content: const Text('This removes all saved shows.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(const WatchlistEvent(WatchlistAction.clear));
    }
  }
}